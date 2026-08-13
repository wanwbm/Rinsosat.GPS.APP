import 'dart:developer' as developer;
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class TokenStore {
  static const _tokenKey = 'token';
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  static void _log(String message, [Object? error, StackTrace? stack]) {
    FirebaseCrashlytics.instance.log(message);
    developer.log(message, error: error, stackTrace: stack);
  }

  static String biometricReason() {
    final languageCode = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (languageCode == 'pt') {
      return 'Desbloqueie para acessar sua conta Rinosat';
    }
    return 'Unlock to access your Rinosat account';
  }

  Future<void> save(String token) async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.write(key: _tokenKey, value: token);
      _log('Token saved (length=${token.length})');
    } on PlatformException catch (e) {
      _log('Failed to write token.', e);
    }
  }

  Future<bool> hasToken() async {
    try {
      final has = await _storage.containsKey(key: _tokenKey);
      _log('hasToken=$has');
      return has;
    } on PlatformException catch (e) {
      _log('Failed to check token.', e);
      return false;
    }
  }

  Future<String?> read() async {
    try {
      final value = await _storage.read(key: _tokenKey);
      _log('read token: ${value == null ? 'null' : 'len=${value.length}'}');
      return value;
    } on PlatformException catch (e) {
      _log('Failed to read token.', e);
      return null;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: biometricReason(),
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException catch (e) {
      _log('Failed to authenticate.', e);
    } on PlatformException catch (e) {
      _log('Failed to authenticate.', e);
    }
    return false;
  }

  Future<void> delete() async {
    try {
      await _storage.delete(key: _tokenKey);
      _log('Token deleted');
    } on PlatformException catch (e) {
      _log('Failed to delete token.', e);
    }
  }
}
