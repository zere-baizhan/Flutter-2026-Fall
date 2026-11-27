import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:week_12/features/users/user.dart';

/// The cache (Level 4) depends on this round trip: toJson → file → fromJson.
void main() {
  test('User survives the JSON round trip used by UsersCache', () {
    const json = {
      'id': 1,
      'name': 'Leanne Graham',
      'username': 'Bret',
      'email': 'Sincere@april.biz',
      'address': {
        'street': 'Kulas Light',
        'suite': 'Apt. 556',
        'city': 'Gwenborough',
        'zipcode': '92998-3874',
        'geo': {'lat': '-37.3159', 'lng': '81.1496'},
      },
      'phone': '1-770-736-8031 x56442',
      'website': 'hildegard.org',
      'company': {'name': 'Romaguera-Crona', 'catchPhrase': 'Neural-net'},
    };
    final u = User.fromJson(json);
    final text = jsonEncode([u.toJson()]);
    final back = User.fromJson(
      (jsonDecode(text) as List<dynamic>).first as Map<String, dynamic>,
    );
    expect(back, u);
    expect(back.address.city, 'Gwenborough');
    expect(back.phoneDigits, '1770736803156442');
  });
}
