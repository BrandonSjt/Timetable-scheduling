import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/shared/widgets/schematic_map_painter.dart';

Future<ByteData> _renderMapPixels() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..drawColor(Colors.white, BlendMode.src);
  SchematicMapPainter(
    showColors: true,
  ).paint(canvas, const Size(kMapWidth, kMapHeight));
  final image = await recorder.endRecording().toImage(
    kMapWidth.toInt(),
    kMapHeight.toInt(),
  );
  final pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  return pixels!;
}

bool _pixelMatches(ByteData pixels, Offset point, Color target) {
  final x = point.dx.round();
  final y = point.dy.round();
  final index = (y * kMapWidth.toInt() + x) * 4;
  final difference =
      (pixels.getUint8(index) - (target.r * 255).round()).abs() +
      (pixels.getUint8(index + 1) - (target.g * 255).round()).abs() +
      (pixels.getUint8(index + 2) - (target.b * 255).round()).abs();
  return difference < 40;
}

bool _regionContainsColor(ByteData pixels, Rect region, Color target) {
  for (var y = region.top.floor(); y <= region.bottom.ceil(); y++) {
    for (var x = region.left.floor(); x <= region.right.ceil(); x++) {
      if (_pixelMatches(pixels, Offset(x.toDouble(), y.toDouble()), target)) {
        return true;
      }
    }
  }
  return false;
}

void main() {
  StationData station(String id) =>
      stations.firstWhere((item) => item.id == id);

  test(
    'official station labels and public codes match supplied route maps',
    () {
      expect(station('asean').name, 'ASEAN Headquarters');
      expect(station('lebak_bulus').name, 'Lebak Bulus Bank Syariah Indonesia');
      expect(station('dukuh_atas_lrt_bk').name, 'Dukuh Atas BNI');
      expect(station('pancoran_bk').name, 'Pancoran bank bjb');
      expect(station('jatibening_baru').name, 'Jati Bening Baru');
      expect(station('taman_mini').name, 'TMII');

      expect(station('jis').code, isEmpty);
      expect(station('tanjung_priok').code, 'TP04');
      expect(station('parung_panjang').code, 'R12');
      expect(station('cilejit').code, 'R14');
      expect(station('daru').code, 'R15');
      expect(station('tenjo').code, 'R16');
      expect(station('tigaraksa').code, 'R18');
      expect(station('cikoya').code, 'R19');
      expect(station('maja').code, 'R20');
      expect(station('citeras').code, 'R21');
      expect(station('rangkasbitung').code, 'R22');
      expect(station('pondok_rajeg').code, 'b23');
      expect(station('nambo').code, 'b26');
    },
  );

  test('station identity changes preserve schematic topology', () {
    expect(stations, hasLength(177));
    expect(transitLines, hasLength(11));
    expect(stations.map((item) => item.id).toSet(), hasLength(177));
    expect(
      transitLines.map((line) => line.id).toSet(),
      hasLength(transitLines.length),
    );
    expect(
      transitLines.firstWhere((line) => line.id == 'tanjung_priok').stationIds,
      containsAllInOrder(['ancol', 'jis', 'tanjung_priok']),
    );
    expect(station('cawang_krl').position, const Offset(1555, 1575));
    expect(station('cikoko_bk').position, const Offset(1600, 1644));
    expect(station('cikoko_cb').position, const Offset(1600, 1656));
  });

  test('Cikoko to Cawang is a separate black walking overlay', () async {
    expect(walkingConnections, hasLength(1));
    expect(walkingConnections.single.fromStationId, 'cawang_krl');
    expect(walkingConnections.single.toStationId, 'cikoko_bk');
    expect(walkingConnections.single.walkingMinutes, 5);
    expect(
      transitLines.every(
        (line) =>
            !line.stationIds.contains('cawang_krl') ||
            !line.stationIds.contains('cikoko_bk'),
      ),
      isTrue,
    );

    final pixels = await _renderMapPixels();
    expect(
      _regionContainsColor(
        pixels,
        const Rect.fromLTRB(1585, 1590, 1604, 1634),
        Colors.black,
      ),
      isTrue,
    );
  });

  test('every drawable station resolves to a selectable station name', () {
    for (final item in stations.where((station) => !station.isWaypoint)) {
      expect(
        stationSelectionName(item),
        isNotEmpty,
        reason: '${item.id} tidak dapat dipilih dari peta',
      );
    }
    expect(stationSelectionName(station('manggarai_bk')), 'Manggarai');
    expect(stationSelectionName(station('setiabudi_lrt_cb')), 'Setiabudi');
  });

  test(
    'every merged interchange renders one hub at the line intersection',
    () async {
      final pixels = await _renderMapPixels();

      for (final pair in kMergedStationPairs.entries) {
        final primary = station(pair.key);
        final secondary = station(pair.value);
        final hubRect = mergedStationHubRect(primary, secondary);
        final intersection = Offset(
          (primary.position.dx + secondary.position.dx) / 2,
          (primary.position.dy + secondary.position.dy) / 2,
        );

        expect(hubRect.center, intersection);
        expect(hubRect.contains(primary.position), isTrue);
        expect(hubRect.contains(secondary.position), isTrue);
        expect(
          _pixelMatches(pixels, intersection.translate(0, -8), Colors.white),
          isTrue,
          reason: '${pair.key}/${pair.value} bukan satu hub gabungan',
        );
      }
    },
  );
}
