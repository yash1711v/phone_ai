import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/account_model.dart';
import '../models/user_model.dart';

/// Local data source for authentication
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();

  /// Cache v3 account and set logged-in state
  Future<void> cacheAccountAndSetLoggedIn(AccountModel account);
  /// Get cached v3 account (null if not logged in)
  Future<AccountModel?> getCachedAccount();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'cached_token';
  static const String _accountKey = 'auth_v3_account';
  static const String _isLoggedInKey = 'auth_is_logged_in';

  AuthLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      await prefs.setString(_userKey, userJson.toString());
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJsonString = prefs.getString(_userKey);
      if (userJsonString == null) return null;
      // Note: In a real app, you'd use proper JSON parsing
      // This is simplified for the structure
      return null; // Implement proper parsing
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_accountKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheAccountAndSetLoggedIn(AccountModel account) async {
    try {
      await prefs.setString(_accountKey, jsonEncode(account.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw CacheException('Failed to cache account: ${e.toString()}');
    }
  }

  @override
  Future<AccountModel?> getCachedAccount() async {
    try {
      final jsonStr = prefs.getString(_accountKey);
      if (jsonStr == null) return null;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AccountModel.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      throw CacheException('Failed to cache token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getCachedToken() async {
    try {
      return prefs.getString(_tokenKey);
    } catch (e) {
      throw CacheException('Failed to get cached token: ${e.toString()}');
    }
  }
}
