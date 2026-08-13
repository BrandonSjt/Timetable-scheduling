import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/auth/data/models/auth_session_model.dart';

void main() {
  test('auth session parses backend token and preference contract', () {
    final session = AuthSessionModel.fromJson({
      'accessToken': 'access-token',
      'refreshToken': 'refresh-token',
      'accessTokenExpiresIn': 900,
      'user': {
        'id': 'user-1',
        'email': 'user@example.com',
        'name': 'Riyadh',
        'phone': null,
        'role': 'REGISTERED',
        'language': 'id',
        'accessibilityEnabled': true,
        'notificationsEnabled': false,
      },
    });

    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.user.name, 'Riyadh');
    expect(session.user.accessibilityEnabled, isTrue);
    expect(session.user.notificationsEnabled, isFalse);
  });
}
