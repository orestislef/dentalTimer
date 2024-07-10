import 'dart:convert';

import 'package:dentalassistant/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance =
      SharedPreferencesHelper._internal();

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._internal();

  SharedPreferences? _prefs;

  Future<void> ensureInitialized() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveProducts(List<Product> products) async {
    _prefs?.clear();
    List<String> list =
        products.map((product) => jsonEncode(product.toJson())).toList();
    String asdf = jsonEncode(list);
    await _prefs?.setString('products', asdf);
  }

  Future<List<Product>> getProducts() async {
    try {
      var products = _prefs?.getString('products');
      List<Product> mProducts = [];
      if (products != null) {
        List<dynamic> list = jsonDecode(products);
        for (var product in list) {
          mProducts.add(Product.fromJson(jsonDecode(product)));
        }
      }
      return mProducts;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveShowNotification(bool showNotification) async {
    await _prefs?.setBool('showNotification', showNotification);
  }

  Future<bool> showNotification() async {
    return _prefs?.getBool('showNotification') ?? true;
  }

  Future<bool> playSound() async {
    return _prefs?.getBool('playSound') ?? true;
  }

  Future<void> savePlaySound(bool playSound) async {
    await _prefs?.setBool('playSound', playSound);
  }

  Future<bool> vibrate() async {
    return _prefs?.getBool('vibrate') ?? true;
  }

  Future<void> saveVibrate(bool vibrate) async {
    await _prefs?.setBool('vibrate', vibrate);
  }
}
