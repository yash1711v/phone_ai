import 'package:objectbox/objectbox.dart';
import '../../objectbox.g.dart';
import '../utils/logger.dart';

class ObjectBoxService {
  static Store? _store;

  static Future<Store> init() async {
    if (_store != null) return _store!;

    try {
      _store = await openStore();
      LogLevel.info( 'ObjectBox initialized successfully');
      return _store!;
    } catch (e) {
      LogLevel.error( 'Failed to initialize ObjectBox',  e);
      rethrow;
    }
  }

  static Store get store {
    if (_store == null) {
      throw Exception('ObjectBox not initialized. Call init() first.');
    }
    return _store!;
  }

  static void close() {
    _store?.close();
    _store = null;
    LogLevel.info( 'ObjectBox closed');
  }
}
