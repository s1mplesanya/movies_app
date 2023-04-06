import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class _Keys {
  static const sessionId = 'session_Id';
  static const accountId = 'account_Id';
}

class SessionDataProvider {
  static const _securityStorage = FlutterSecureStorage();

  Future<String?> getSessionId() => _securityStorage.read(key: _Keys.sessionId);
  Future<void> setSessionId(String value) =>
      _securityStorage.write(key: _Keys.sessionId, value: value);
  Future<void> deleteSessionId() =>
      _securityStorage.delete(key: _Keys.sessionId);

  Future<int?> getAccountId() async {
    final id = await _securityStorage.read(key: _Keys.accountId);
    return id != null ? int.tryParse(id) : null;
  }

  Future<void> setAccountId(int value) =>
      _securityStorage.write(key: _Keys.accountId, value: value.toString());
  Future<void> deleteAccountId() =>
      _securityStorage.delete(key: _Keys.accountId);
}
