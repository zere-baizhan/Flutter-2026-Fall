import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> _items = const [];
  bool _loading = false;
  ApiException? _error;

  List<User> get items => _items;
  bool get loading => _loading;
  ApiException? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.getAll();
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<User> create(User draft) async {
    final created = await _repo.create(draft);
    _items = [created, ..._items];
    notifyListeners();
    return created;
  }
}
