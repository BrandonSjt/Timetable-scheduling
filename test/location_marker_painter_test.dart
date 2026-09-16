import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/shared/widgets/schematic_map_painter.dart';

void main() {
  test('location marker preserves station names and node codes', () async {
    for (final id in [
      'manggarai_bk',
      'manggarai_cb',
      'duri_c',
      'jakarta_kota_bk',
      'bogor',
      'tebet',
    ]) {
      final station = stations.firstWhere((station) => station.id == id);
      final primaryId = kMergedStationPairs.containsKey(id)
          ? id
          : kMergedStationPairs.entries
                .where((pair) => pair.value == id)
                .map((pair) => pair.key)
                .firstOrNull;
      final primary = primaryId == null
          ? null
          : stations.firstWhere((station) => station.id == primaryId);
      final secondary = primary == null
          ? null
          : stations.firstWhere(
              (station) => station.id == kMergedStationPairs[primary.id],
            );
      final interior = primary != null && secondary != null
          ? mergedStationHubRect(primary, secondary).deflate(4)
          : Rect.fromCenter(center: station.position, width: 12, height: 12);
      final center = interior.center;
      final baseline = await _renderStation(center);
      final located = await _renderStation(center, nearestStation: id);
      final localRect = interior.shift(const Offset(120, 60) - center);
      for (var y = localRect.top.ceil(); y < localRect.bottom.floor(); ++y) {
        for (var x = localRect.left.ceil(); x < localRect.right.floor(); ++x) {
          final pixel = (y * 240 + x) * 4;
          expect(
            located.getUint32(pixel),
            baseline.getUint32(pixel),
            reason: '$id: marker must not cover node content at ($x, $y)',
          );
        }
      }
      if (primary != null && secondary != null) {
        for (final edge in [localRect.left - 7, localRect.right + 7]) {
          var foundOutline = false;
          for (var x = edge.floor() - 1; x <= edge.ceil() + 1; ++x) {
            final pixel = (60 * 240 + x) * 4;
            final red = located.getUint8(pixel);
            final green = located.getUint8(pixel + 1);
            final blue = located.getUint8(pixel + 2);
            foundOutline |= blue > 150 && red < 60 && green < 150;
          }
          expect(
            foundOutline,
            isTrue,
            reason: '$id: outline follows pill edge',
          );
        }
      }
    }
  });

  test('nearest station paints a blue location ring', () async {
    final bogor = stations.firstWhere((station) => station.id == 'bogor');
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..translate(30 - bogor.position.dx, 30 - bogor.position.dy);
    SchematicMapPainter(
      nearestStation: 'bogor',
    ).paint(canvas, const Size(kMapWidth, kMapHeight));
    final image = await recorder.endRecording().toImage(60, 60);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();

    var foundBlue = false;
    for (var i = 0; i < bytes!.lengthInBytes; i += 4) {
      final red = bytes.getUint8(i);
      final green = bytes.getUint8(i + 1);
      final blue = bytes.getUint8(i + 2);
      if (blue > 150 && blue > red * 1.3 && blue > green * 1.05) {
        foundBlue = true;
        break;
      }
    }

    expect(foundBlue, isTrue);
  });

  test('nearest station change triggers repaint', () {
    final previous = SchematicMapPainter();
    final current = SchematicMapPainter(nearestStation: 'bogor');

    expect(current.shouldRepaint(previous), isTrue);
  });
}

Future<ByteData> _renderStation(Offset center, {String? nearestStation}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..translate(120 - center.dx, 60 - center.dy);
  SchematicMapPainter(
    nearestStation: nearestStation,
  ).paint(canvas, const Size(kMapWidth, kMapHeight));
  final picture = recorder.endRecording();
  final image = await picture.toImage(240, 120);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  picture.dispose();
  return bytes!;
}
