import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

enum CameraGuideState {
  loading,
  active,
  permissionDenied,
  offline,
  error,
  stopped,
}

class CameraGuideController extends ChangeNotifier with WidgetsBindingObserver {
  CameraGuideController({CameraController? camera, FlutterTts? tts})
    : _camera = camera,
      _tts = tts ?? FlutterTts();

  CameraController? _camera;
  final FlutterTts _tts;
  ObjectDetector? _detector;
  Timer? _speechCooldown;
  bool _busy = false;
  bool _stopped = false;

  CameraGuideState state = CameraGuideState.loading;
  String message = 'Menyiapkan kamera…';
  CameraController? get camera => _camera;

  Future<void> start() async {
    _stopped = false;
    WidgetsBinding.instance.addObserver(this);
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
    _busy = true;
    try {
      final input = _inputImageFromCameraImage(image);
      if (input == null) return;
      final objects = await _detector!.processImage(input);
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
      state = CameraGuideState.offline;
      message = 'Deteksi lokal terbatas; koneksi AI tidak tersedia.';
      notifyListeners();
    } finally {
      _busy = false;
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
    _stopped = true;
    WidgetsBinding.instance.removeObserver(this);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(stop());
    }
  }

  @override
  void dispose() {
    unawaited(stop());
    _tts.stop();
    super.dispose();
  }
}
