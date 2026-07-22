import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/assistant/domain/entities/assistant_conversation_item.dart';
import 'package:timetable/features/assistant/presentation/controllers/assistant_conversation_controller.dart';
import 'package:timetable/features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';

void main() {
  test('typed command activates every alarm and appends ordered messages', () {
    final alarms = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai');
    final chat = AssistantConversationController(alarmController: alarms);

    chat.submitText('Aktifkan semua alarm tiket saya');

    expect(chat.items.first.author, AssistantMessageAuthor.user);
    expect(chat.items.first.text, 'Aktifkan semua alarm tiket saya');
    expect(chat.items.last.kind, AssistantConversationItemKind.alarmStatus);
    expect(alarms.state.departureAlarmEnabled, isTrue);
    expect(alarms.state.destinationAlarmEnabled, isTrue);
  });

  test('arrival and next-alarm questions report the current countdown', () {
    final alarms = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);
    final chat = AssistantConversationController(alarmController: alarms);

    chat.submitText('Kereta saya datang berapa menit lagi?');
    expect(chat.items.last.text, 'Kereta datang 5 menit lagi');

    chat.submitText('Alarm berikutnya kapan?');
    expect(chat.items.last.text, 'Kereta datang 5 menit lagi');
    expect(chat.items.last.kind, AssistantConversationItemKind.alarmStatus);
  });

  test('destination and all alarms can be cancelled through chat', () {
    final alarms = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);
    final chat = AssistantConversationController(alarmController: alarms);

    chat.submitText('Matikan alarm tujuan');
    expect(alarms.state.destinationAlarmEnabled, isFalse);
    expect(alarms.state.departureAlarmEnabled, isTrue);

    chat.submitText('Batalkan semua alarm');
    expect(alarms.state.hasAnyAlarm, isFalse);
    expect(chat.items.last.text, 'Semua alarm perjalanan dibatalkan.');
  });

  test('unknown command returns concise command examples', () {
    final chat = AssistantConversationController(
      alarmController: TravelAlarmController(),
    );

    chat.submitText('Pesan yang tidak dikenali');

    expect(chat.items.last.text, contains('Saya belum memahami perintah itu'));
    expect(chat.items.last.text, contains('Alarm berikutnya kapan?'));
  });

  test('alarm command without a ticket adds an empty-ticket item', () {
    final chat = AssistantConversationController(
      alarmController: TravelAlarmController(),
    );

    chat.submitText('Aktifkan semua alarm tiket saya');

    expect(chat.items.last.kind, AssistantConversationItemKind.noActiveTicket);
    expect(chat.items.last.text, 'Belum ada tiket aktif');
  });

  test('empty messages are ignored and voice uses the same timeline', () {
    final chat = AssistantConversationController(
      alarmController: TravelAlarmController(),
    );

    chat.submitText('   ');
    expect(chat.items, isEmpty);

    chat.addVoiceExchange(
      transcript: 'Saya ingin ke Manggarai dari Setiabudi.',
      response: 'Kereta datang 5 menit lagi.',
    );

    expect(chat.items, hasLength(2));
    expect(chat.items.first.author, AssistantMessageAuthor.user);
    expect(chat.items.last.author, AssistantMessageAuthor.assistant);
  });
}
