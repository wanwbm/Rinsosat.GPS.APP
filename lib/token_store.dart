import 'dart:developer' as developer;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class TokenStore {
  static const _tokenKey = 'token';
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

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
    } on PlatformException catch (e) {
      developer.log('Failed to write token.', error: e);
    }
  }

  Future<bool> hasToken() async {
    try {
      return await _storage.containsKey(key: _tokenKey);
    } on PlatformException catch (e) {
      developer.log('Failed to check token.', error: e);
      return false;
    }
  }

  Future<String?> read() async {
    try {
      return await _storage.read(key: _tokenKey);
    } on PlatformException catch (e) {
      developer.log('Failed to read token.', error: e);
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
      developer.log('Failed to authenticate.', error: e);
    } on PlatformException catch (e) {
      developer.log('Failed to authenticate.', error: e);
    }
    return false;
  }

  Future<void> delete() async {
    try {
      await _storage.delete(key: _tokenKey);
    } on PlatformException catch (e) {
      developer.log('Failed to delete token.', error: e);
    }
  }
}
