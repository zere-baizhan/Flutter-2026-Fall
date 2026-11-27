import 'dart:convert';
import 'dart:developer';

import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';

const _sampleJson = '''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {"name": "Romaguera-Crona", "catchPhrase": "Multi-layered client-server neural-net"}
}
''';

void checkModel() {
  final json = jsonDecode(_sampleJson) as Map<String, dynamic>;
  final u = User.fromJson(json);
  assert(u.id == 1 && u.address.geo.lat == -37.3159);
  final again = User.fromJson(
    jsonDecode(jsonEncode(u.toJson())) as Map<String, dynamic>,
  );
  assert(again == u && again.address.city == u.address.city);
  log('checkModel OK: $u', name: 'dev');
}

Future<void> checkRepository(UserRepository repo) async {
  try {
    final all = await repo.getAll();
    log(
      'getAll: ${all.items.length} users (fromCache: ${all.fromCache})',
      name: 'dev',
    );
    final one = await repo.getById(1);
    log('getById(1): $one', name: 'dev');
    try {
      await repo.getById(9999);
    } on NotFoundException {
      log('getById(9999): NotFoundException as expected', name: 'dev');
    }
  } on ApiException catch (e) {
    log('checkRepository failed: $e', name: 'dev');
  }
}
