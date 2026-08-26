import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/search_station/presentation/widgets/station_card.dart';

void main() {
  testWidgets('station card only shows station identity and service', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StationCard(name: 'Ancol', lineInfo: 'KRL Lin Tanjung Priok'),
        ),
      ),
    );

    expect(find.text('Ancol'), findsOneWidget);
    expect(find.text('KRL Lin Tanjung Priok'), findsOneWidget);
    expect(find.textContaining('menit'), findsNothing);
  });
}
