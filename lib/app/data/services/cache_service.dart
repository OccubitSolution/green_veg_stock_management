import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  static const String productsBox = 'products';
  static const String customersBox = 'customers';
  static const String pricesBox = 'prices';
  static const String ordersBox = 'orders';
  static const String categoriesBox = 'categories';
  static const String settingsBox = 'settings';
  static const String analyticsBox = 'analytics';

  static final CacheService _instance = CacheService._();
  factory CacheService() => _instance;
  CacheService._();

  final Map<String, Box> _boxes = {};

  Future<void> init() async {
    _boxes[productsBox] = await Hive.openBox(productsBox);
    _boxes[customersBox] = await Hive.openBox(customersBox);
    _boxes[pricesBox] = await Hive.openBox(pricesBox);
    _boxes[ordersBox] = await Hive.openBox(ordersBox);
    _boxes[categoriesBox] = await Hive.openBox(categoriesBox);
    _boxes[settingsBox] = await Hive.openBox(settingsBox);
    _boxes[analyticsBox] = await Hive.openBox(analyticsBox);
    debugPrint('✅ CacheService initialized');
  }

  Box _getBox(String boxName) {
    return _boxes[boxName] ?? Hive.box(boxName);
  }

  Future<void> cacheData(String box, String key, dynamic data) async {
    try {
      final boxInstance = _getBox(box);
      await boxInstance.put(key, {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('❌ Cache write error: $e');
    }
  }

  dynamic getCachedData(String box, String key) {
    try {
      final boxInstance = _getBox(box);
      return boxInstance.get(key);
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  bool isCacheValid(String box, String key, {int maxAgeMinutes = 30}) {
    try {
      final cached = getCachedData(box, key);
      if (cached == null) return false;
      
      final timestamp = cached['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      return age < (maxAgeMinutes * 60 * 1000);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearBox(String box) async {
    try {
      final boxInstance = _getBox(box);
      await boxInstance.clear();
    } catch (e) {
      debugPrint('❌ Clear box error: $e');
    }
  }

  Future<void> clearAll() async {
    for (var box in _boxes.values) {
      await box.clear();
    }
  }

  // Products
  Future<void> cacheProducts(String vendorId, List<Map<String, dynamic>> products) async {
    await cacheData(productsBox, vendorId, products);
  }

  List<Map<String, dynamic>>? getCachedProducts(String vendorId) {
    try {
      final cached = getCachedData(productsBox, vendorId);
      if (cached == null) return null;
      final data = cached['data'];
      if (data == null) return null;
      if (data is! List) return null;
      return data.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  // Categories
  Future<void> cacheCategories(String vendorId, List<Map<String, dynamic>> categories) async {
    await cacheData(categoriesBox, vendorId, categories);
  }

  List<Map<String, dynamic>>? getCachedCategories(String vendorId) {
    try {
      final cached = getCachedData(categoriesBox, vendorId);
      if (cached == null) return null;
      final data = cached['data'];
      if (data == null) return null;
      if (data is! List) return null;
      return data.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  // Customers
  Future<void> cacheCustomers(String vendorId, List<Map<String, dynamic>> customers) async {
    await cacheData(customersBox, vendorId, customers);
  }

  List<Map<String, dynamic>>? getCachedCustomers(String vendorId) {
    try {
      final cached = getCachedData(customersBox, vendorId);
      if (cached == null) return null;
      final data = cached['data'];
      if (data == null) return null;
      if (data is! List) return null;
      return data.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  // Prices
  Future<void> cachePrices(String vendorId, List<Map<String, dynamic>> prices) async {
    await cacheData(pricesBox, vendorId, prices);
  }

  List<Map<String, dynamic>>? getCachedPrices(String vendorId) {
    try {
      final cached = getCachedData(pricesBox, vendorId);
      if (cached == null) return null;
      final data = cached['data'];
      if (data == null) return null;
      if (data is! List) return null;
      return data.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  // Orders
  Future<void> cacheOrders(String vendorId, List<Map<String, dynamic>> orders) async {
    await cacheData(ordersBox, vendorId, orders);
  }

  List<Map<String, dynamic>>? getCachedOrders(String vendorId) {
    try {
      final cached = getCachedData(ordersBox, vendorId);
      if (cached == null) return null;
      final data = cached['data'];
      if (data == null) return null;
      if (data is! List) return null;
      return data.map((e) {
        if (e is Map) {
          return Map<String, dynamic>.from(e);
        }
        return <String, dynamic>{};
      }).toList();
    } catch (e) {
      debugPrint('❌ Cache read error: $e');
      return null;
    }
  }

  // Analytics (shorter cache time - 5 minutes)
  Future<void> cacheAnalytics(String vendorId, String key, dynamic data) async {
    await cacheData(analyticsBox, '${vendorId}_$key', data);
  }

  bool isAnalyticsCacheValid(String vendorId, String key, {int maxAgeMinutes = 5}) {
    return isCacheValid(analyticsBox, '${vendorId}_$key', maxAgeMinutes: maxAgeMinutes);
  }

  dynamic getCachedAnalytics(String vendorId, String key) {
    return getCachedData(analyticsBox, '${vendorId}_$key');
  }
}
