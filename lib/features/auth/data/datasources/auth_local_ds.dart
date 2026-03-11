import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for authentication
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'cached_token';

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
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
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
