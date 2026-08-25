import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../../data/datasources/vision_guide_remote_data_source.dart';
import '../utils/nv21_jpeg_encoder.dart';

enum CameraGuideState {
  loading,
  active,
  permissionDenied,
  offline,
  error,
  stopped,
}

class CameraGuideController extends ChangeNotifier with WidgetsBindingObserver {
  CameraGuideController({
    CameraController? camera,
    FlutterTts? tts,
    VisionGuideRemoteDataSource? vision,
  }) : _camera = camera,
       _tts = tts ?? FlutterTts(),
       _vision = vision ?? VisionGuideRemoteDataSource();

  CameraController? _camera;
  final FlutterTts _tts;
  final VisionGuideRemoteDataSource _vision;
  ObjectDetector? _detector;
  Timer? _speechCooldown;
  DateTime? _lastVisionRequest;
  bool _visionBusy = false;
  bool _busy = false;
  bool _stopped = false;
  int _sessionId = 0;
  bool _observingLifecycle = false;
  bool _pausedByLifecycle = false;
  Future<void>? _lifecyclePause;

  CameraGuideState state = CameraGuideState.loading;
  String message = 'Menyiapkan kamera…';
  CameraController? get camera => _camera;

  Future<void> start() async {
    _sessionId += 1;
    _stopped = false;
    _busy = false;
    _visionBusy = false;
    if (!_observingLifecycle) {
      WidgetsBinding.instance.addObserver(this);
      _observingLifecycle = true;
    }
    if (_camera != null) {
      await _startDetectorAndStream();
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('NoCamera', 'Kamera tidak ditemukan.');
      }
      _camera = CameraController(
        cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await _camera!.initialize();
      await _startDetectorAndStream();
    } on CameraException catch (error) {
      await _camera?.dispose();
      _camera = null;
      state =
          error.code == 'CameraAccessDenied' ||
              error.code == 'CameraAccessRestricted'
          ? CameraGuideState.permissionDenied
          : CameraGuideState.error;
      message = error.description ?? 'Kamera tidak dapat digunakan.';
      notifyListeners();
    } catch (_) {
      await _camera?.dispose();
      _camera = null;
      state = CameraGuideState.error;
      message = 'Kamera tidak dapat digunakan.';
      notifyListeners();
    }
  }

  Future<void> restart() async {
    await stop();
    state = CameraGuideState.loading;
    message = 'Menyiapkan kamera…';
    notifyListeners();
    await start();
  }

  Future<void> _startDetectorAndStream() async {
    _detector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
    await _camera!.startImageStream(_processImage);
    state = CameraGuideState.active;
    message = 'Arahkan kamera ke depan. Pemandu aktif.';
    notifyListeners();
  }

  Future<void> _processImage(CameraImage image) async {
    if (_busy || _stopped || _detector == null || _camera == null) return;
    final sessionId = _sessionId;
    _busy = true;
    try {
      _sendRemoteVisionIfDue(image, sessionId: sessionId);
      final input = _inputImageFromCameraImage(image);
      if (input == null) return;
      final objects = await _detector!.processImage(input);
      if (_stopped || sessionId != _sessionId) return;
      if (objects.isEmpty) {
        _announce('Belum ada objek jelas di depan.');
        return;
      }
      final labels = objects
          .expand((object) => object.labels.map((label) => label.text))
          .where((label) => label.isNotEmpty)
          .take(2)
          .toList(growable: false);
      final description = labels.isEmpty
          ? '${objects.length} objek terdeteksi di depan.'
          : '${labels.join(' dan ')} terdeteksi di depan.';
      _announce(description);
    } catch (_) {
      if (_stopped || sessionId != _sessionId) return;
      state = CameraGuideState.offline;
      message = 'Deteksi lokal terbatas; koneksi AI tidak tersedia.';
      notifyListeners();
    } finally {
      if (sessionId == _sessionId) _busy = false;
    }
  }

  void _sendRemoteVisionIfDue(CameraImage image, {required int sessionId}) {
    if (!Platform.isAndroid || _visionBusy || image.planes.length != 1) return;
    final now = DateTime.now();
    if (_lastVisionRequest != null &&
        now.difference(_lastVisionRequest!) < const Duration(seconds: 8)) {
      return;
    }
    final bytes = image.planes.first.bytes;
    if (bytes.isEmpty) return;
    _lastVisionRequest = now;
    _visionBusy = true;
    unawaited(
      _requestRemoteVision(
        Uint8List.fromList(bytes),
        width: image.width,
        height: image.height,
        rotationDegrees: _camera?.description.sensorOrientation ?? 0,
        sessionId: sessionId,
      ),
    );
  }

  Future<void> _requestRemoteVision(
    Uint8List nv21Bytes, {
    required int width,
    required int height,
    required int rotationDegrees,
    required int sessionId,
  }) async {
    try {
      final jpegBytes = await Isolate.run(
        () => encodeNv21ToJpeg(
          nv21Bytes,
          width: width,
          height: height,
          rotationDegrees: rotationDegrees,
        ),
      );
      if (jpegBytes.length > 1_048_576) return;
      final result = await _vision.analyzeJpeg(jpegBytes);
      if (result != null && !_stopped && sessionId == _sessionId) {
        _announce(result.spokenText);
      }
    } catch (_) {
      // Local ML Kit remains active when the backend is unavailable.
    } finally {
      if (sessionId == _sessionId) _visionBusy = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = _camera;
    if (controller == null) return null;
    final rotation = InputImageRotationValue.fromRawValue(
      controller.description.sensorOrientation,
    );
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null || image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _announce(String value) {
    message = value;
    notifyListeners();
    if (_speechCooldown?.isActive ?? false) return;
    _tts.setLanguage('id-ID');
    _tts.speak(value);
    _speechCooldown = Timer(const Duration(seconds: 4), () {});
  }

  Future<void> stop() async {
    _pausedByLifecycle = false;
    await _stopCamera(removeLifecycleObserver: true);
    message = 'Pemandu kamera dihentikan.';
    notifyListeners();
  }

  Future<void> _stopCamera({required bool removeLifecycleObserver}) async {
    _sessionId += 1;
    _stopped = true;
    _busy = false;
    _visionBusy = false;
    if (removeLifecycleObserver && _observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
      _observingLifecycle = false;
    }
    _speechCooldown?.cancel();
    final camera = _camera;
    if (camera?.value.isStreamingImages ?? false) {
      await camera!.stopImageStream();
    }
    await _detector?.close();
    await camera?.dispose();
    _camera = null;
    state = CameraGuideState.stopped;
    notifyListeners();
  }

  Future<void> _resumeAfterLifecyclePause() async {
    await _lifecyclePause;
    if (_pausedByLifecycle) return;
    await restart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (this.state == CameraGuideState.active &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive)) {
      _pausedByLifecycle = true;
      _lifecyclePause = _stopCamera(removeLifecycleObserver: false);
      unawaited(_lifecyclePause);
      return;
    }
    if (state == AppLifecycleState.resumed && _pausedByLifecycle) {
      _pausedByLifecycle = false;
      unawaited(_resumeAfterLifecyclePause());
    }
  }

  @override
  void dispose() {
    unawaited(stop());
    _tts.stop();
    _vision.close();
    super.dispose();
  }
}
