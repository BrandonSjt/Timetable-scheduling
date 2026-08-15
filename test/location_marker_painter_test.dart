import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/shared/widgets/schematic_map_painter.dart';

void main() {
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
