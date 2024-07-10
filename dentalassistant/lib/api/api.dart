import 'dart:convert';

import 'package:dentalassistant/helpers/shared_preferences.dart';
import 'package:dentalassistant/models/product.dart';
import 'package:http/http.dart' as http;

const baseUrl = 'http://192.168.24.21:8080/dental/api.php';

class Api {
  static final Api _api = Api._internal();

  factory Api() {
    return _api;
  }

  Api._internal();

  Map<String, String> _getHeader() {
    return {"Content-Type": "application/json"};
  }

  Future<List<Product>> getProducts() async {
    try {
      final response =
          await http.get(Uri.parse(baseUrl), headers: _getHeader());
      if (response.statusCode == 200) {
        List<Product> products = [];
        jsonDecode(response.body).forEach((product) {
          products.add(Product.fromJson(product));
        });
        await SharedPreferencesHelper().saveProducts(products);
        return products;
      } else {
        return await SharedPreferencesHelper().getProducts();
      }
    } catch (e) {
      return await SharedPreferencesHelper().getProducts();
    }
  }

  Future<bool> createProduct({required Product product}) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeader(),
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct({required product}) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl),
        headers: _getHeader(),
        body: jsonEncode(product.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct({required int id}) async {
    try {
      final response = await http.delete(
        Uri.parse(baseUrl),
        headers: _getHeader(),
        body: jsonEncode({'id': id.toString()}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
