import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class CacheService {
  static const String _listingsBox = 'listings_cache';
  static const String _userBox = 'user_cache';
  static const String _searchBox = 'search_cache';
  
  // Cache duration
  static const Duration _cacheDuration = Duration(hours: 1);

  // Initialize Hive
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_listingsBox);
    await Hive.openBox(_userBox);
    await Hive.openBox(_searchBox);
  }

  // Listings Cache
  static Future<void> cacheListings(List<Map<String, dynamic>> listings) async {
    final box = Hive.box(_listingsBox);
    await box.put('listings', {
      'data': listings,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>?> getCachedListings() async {
    final box = Hive.box(_listingsBox);
    final cached = box.get('listings');
    
    if (cached == null) return null;
    
    final timestamp = DateTime.parse(cached['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      await box.delete('listings');
      return null;
    }
    
    return List<Map<String, dynamic>>.from(cached['data'] as List);
  }

  // User Profile Cache
  static Future<void> cacheUserProfile(String userId, Map<String, dynamic> profile) async {
    final box = Hive.box(_userBox);
    await box.put(userId, {
      'data': profile,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> getCachedUserProfile(String userId) async {
    final box = Hive.box(_userBox);
    final cached = box.get(userId);
    
    if (cached == null) return null;
    
    final timestamp = DateTime.parse(cached['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      await box.delete(userId);
      return null;
    }
    
    return Map<String, dynamic>.from(cached['data'] as Map);
  }

  // Search Results Cache
  static Future<void> cacheSearchResults(
    String query,
    List<Map<String, dynamic>> results,
  ) async {
    final box = Hive.box(_searchBox);
    await box.put(query, {
      'data': results,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>?> getCachedSearchResults(
    String query,
  ) async {
    final box = Hive.box(_searchBox);
    final cached = box.get(query);
    
    if (cached == null) return null;
    
    final timestamp = DateTime.parse(cached['timestamp'] as String);
    if (DateTime.now().difference(timestamp) > Duration(minutes: 30)) {
      await box.delete(query);
      return null;
    }
    
    return List<Map<String, dynamic>>.from(cached['data'] as List);
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    await Hive.box(_listingsBox).clear();
    await Hive.box(_userBox).clear();
    await Hive.box(_searchBox).clear();
  }

  // Clear specific cache
  static Future<void> clearListingsCache() async {
    await Hive.box(_listingsBox).clear();
  }

  static Future<void> clearUserCache() async {
    await Hive.box(_userBox).clear();
  }

  static Future<void> clearSearchCache() async {
    await Hive.box(_searchBox).clear();
  }

  // Get cache size
  static Future<int> getCacheSize() async {
    int size = 0;
    size += Hive.box(_listingsBox).length;
    size += Hive.box(_userBox).length;
    size += Hive.box(_searchBox).length;
    return size;
  }
}
