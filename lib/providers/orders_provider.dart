import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping/models/http_exception.dart';
import 'package:shopping/providers/cart_provider.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  /// id of the order
  final String id;

  /// the total price of the order
  final double amount;

  /// the items were ordered
  final List<CartItem> products;

  /// the date of the order
  final DateTime dateTime;
  /// initializing our object
  OrderItem({
    this.id,
    this.products,
    this.dateTime,
    this.amount,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  final String token;
  final String userId;
  Orders(this.userId,this.token, this._orders);
  Future<void> addOrder(List<CartItem> cartProducts, double total) {
    final String url = 'https://shopping-59751.firebaseio.com/orders/$userId.json?auth=$token';
    return http
        .post(url,
            body: jsonEncode({
              'total': total,
              'cartProducts': cartProducts,
              'date': DateTime.now().toIso8601String(),
            }))
        .then((response) {
      _orders.add(OrderItem(
          id: jsonDecode(response.body)['name'],
          products: cartProducts,
          amount: total,
          dateTime: DateTime.now(),

      ));
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> fetchOrders() {
    final String url = 'https://shopping-59751.firebaseio.com/orders/$userId.json?auth=$token';


    return http.get(url).then((response) {
      List<OrderItem> _loadedOrders = [];
      var extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      /// if there is no data in the database return nothing
      if (extractedData == null) {
        return;
      }
      /// add the data from database to the order list
      extractedData.forEach((orderId, orderData) {
        print(orderData['cartProducts']);
        _loadedOrders.add(OrderItem(
            dateTime: DateTime.parse(orderData['date']),
            id: orderId,
            amount: orderData['total'],
            products: (orderData['cartProducts'] as List<dynamic>)
                .map((product) => CartItem.fromJson(product))
                .toList()));

        _orders = _loadedOrders;
        notifyListeners();
      });
    }).catchError((error) {
      throw error;
    });
  }


  /// clearing all orders
  Future<void> clearOrders() async {
    final String url = 'https://shopping-59751.firebaseio.com/orders/$userId.json?auth=$token';
    /// making a copy of the current orders
    var _backupOrders = [..._orders];
    _orders.clear();
    notifyListeners();

    return http.delete(url).then((response) {
      /// if an error occurred add the orders to the list again
      if (response.statusCode >= 400) {
        _orders.addAll(_backupOrders);
        notifyListeners();
        throw HttpException('Could not clear orders');
      }
      /// else we don`t need the backup any more
      _backupOrders = null;
    });
  }
}
