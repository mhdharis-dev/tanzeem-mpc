// Library: web_storage_helper.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive cross-platform Web Storage, Cache Memory, and Cookie Helper.
/// Handles:
/// 1. Web Cookies (setCookie, getCookie, deleteCookie, clearAllCookies)
/// 2. Local Memory / Local Storage (SharedPreferences / browser localStorage)
/// 3. In-Memory Volatile RAM Cache (RAM caching for Firestore queries & session state)
class WebStorageHelper {
  // Volatile In-Memory RAM Cache Map
  static final Map<String, dynamic> _memoryCache = {};

  // --- 1. WEB COOKIE MANAGEMENT ---
  
  /// Sets a web cookie or stored key-value pair with max-age.
  static Future<void> setCookie(String name, String value, {int maxAgeDays = 30}) async {
    try {
      _memoryCache['cookie_$name'] = value;
      
      // Persist cookie payload to SharedPreferences / localStorage on all platforms
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cookie_$name', value);
    } catch (e) {
      debugPrint('Error setting cookie $name: $e');
    }
  }

  /// Retrieves a cookie value by name.
  static Future<String?> getCookie(String name) async {
    try {
      if (_memoryCache.containsKey('cookie_$name')) {
        return _memoryCache['cookie_$name'] as String?;
      }

      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString('cookie_$name');
      if (val != null) {
        _memoryCache['cookie_$name'] = val;
      }
      return val;
    } catch (e) {
      debugPrint('Error getting cookie $name: $e');
      return null;
    }
  }

  /// Deletes a specified cookie.
  static Future<void> deleteCookie(String name) async {
    try {
      _memoryCache.remove('cookie_$name');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cookie_$name');
    } catch (e) {
      debugPrint('Error deleting cookie $name: $e');
    }
  }

  /// Clears all session cookies.
  static Future<void> clearAllCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('cookie_')).toList();
      for (var k in keys) {
        await prefs.remove(k);
        _memoryCache.remove(k);
      }
    } catch (e) {
      debugPrint('Error clearing all cookies: $e');
    }
  }

  // --- 2. LOCAL MEMORY & LOCAL STORAGE MANAGEMENT ---

  /// Saves a key-value item to Local Storage / SharedPreferences.
  static Future<bool> setLocalMemory(String key, String value) async {
    try {
      _memoryCache['local_$key'] = value;
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      debugPrint('Error saving local memory $key: $e');
      return false;
    }
  }

  /// Retrieves a local memory item.
  static Future<String?> getLocalMemory(String key) async {
    try {
      if (_memoryCache.containsKey('local_$key')) {
        return _memoryCache['local_$key'] as String?;
      }
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(key);
      if (val != null) {
        _memoryCache['local_$key'] = val;
      }
      return val;
    } catch (e) {
      debugPrint('Error getting local memory $key: $e');
      return null;
    }
  }

  /// Removes a key from Local Memory.
  static Future<bool> deleteLocalMemory(String key) async {
    try {
      _memoryCache.remove('local_$key');
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      debugPrint('Error removing local memory $key: $e');
      return false;
    }
  }

  /// Clears all Local Storage entries.
  static Future<void> clearAllLocalMemory() async {
    try {
      _memoryCache.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Error clearing local memory: $e');
    }
  }

  // --- 3. IN-MEMORY RAM CACHE MANAGEMENT ---

  /// Stores object in volatile high-speed RAM Cache Memory.
  static void setCacheMemory(String key, dynamic data) {
    _memoryCache[key] = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Retrieves cached object from RAM Cache Memory.
  static dynamic getCacheMemory(String key, {int maxAgeMinutes = 60}) {
    if (!_memoryCache.containsKey(key)) return null;
    final item = _memoryCache[key];
    if (item is Map && item.containsKey('timestamp')) {
      final ageSecs = (DateTime.now().millisecondsSinceEpoch - (item['timestamp'] as int)) ~/ 1000;
      if (ageSecs > maxAgeMinutes * 60) {
        _memoryCache.remove(key);
        return null;
      }
      return item['data'];
    }
    return item;
  }

  /// Clears all volatile RAM Cache Memory.
  static void clearCacheMemory() {
    _memoryCache.clear();
  }

  // --- 4. UNIFIED COMPLETE STORAGE & CACHE PURGE ---

  /// Clears Cache Memory, Local Storage, and Cookies completely.
  static Future<void> purgeAllStorageCacheAndCookies() async {
    clearCacheMemory();
    await clearAllCookies();
    await clearAllLocalMemory();
  }

  /// Diagnostic report of current storage usage.
  static Future<Map<String, dynamic>> getStorageDiagnostics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final cookieKeys = allKeys.where((k) => k.startsWith('cookie_')).toList();
      final draftKeys = allKeys.where((k) => k.startsWith('draft_')).toList();

      return {
        'ramCacheEntries': _memoryCache.length,
        'totalLocalStorageKeys': allKeys.length,
        'activeCookiesCount': cookieKeys.length,
        'localDraftsCount': draftKeys.length,
        'isWebPlatform': kIsWeb,
      };
    } catch (e) {
      return {
        'ramCacheEntries': 0,
        'totalLocalStorageKeys': 0,
        'activeCookiesCount': 0,
        'localDraftsCount': 0,
        'error': e.toString(),
      };
    }
  }
}
