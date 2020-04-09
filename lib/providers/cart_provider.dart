
import 'package:flutter/material.dart';



/// model class

class CartItem {

  /// id of the cart
  final String id;
  /// title of the product
  final String title;
  /// quantity of the product
  final int quantity;
  /// price of the product
  final double price;

  /// initializing our object
  CartItem({@required this.id, @required this.title, @required this.price, @required this.quantity});


  /// converting the object to json when calling using jsonEncode
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'quantity': quantity,
    'price': price
  };

  /// converting the json to objects when calling jsonDecode
  CartItem.fromJson(Map<String, dynamic> json):
      id = json['id'],
      title = json['title'],
      quantity = json['quantity'],
      price = json['price'];
}

/// this class will provide the widgets with cart data
class Cart with ChangeNotifier {

  /// this list will carry our cart items
  Map<String, CartItem> _items = {};


  Map<String, CartItem> get items {
    return {..._items};
  }

    /// returning how many carts the client made
  int getCount() {

      return _items.length;
}

  /// returning the total price of all carts
  double get totalAmount {
      var total = 0.0;

      _items.forEach((key, CartItem){
        total += CartItem.price * CartItem.quantity;
      });
      return total;

  }

  /// adding a cart to our list
  void addItem(String productId, double price, String title) {
      if(_items.containsKey(productId)) {

        _items.update(productId, (existingCartItem)=> CartItem(quantity: existingCartItem.quantity + 1, id: existingCartItem.id, title: existingCartItem.title, price: existingCartItem.price));
      }
      else{
        _items.putIfAbsent(productId, () => CartItem(id:  DateTime.now().toString(),title: title, quantity:  1, price: price ));
      }
      notifyListeners();

  }




  /// remove a cart
  void removeCart(String productId){
      _items.remove(productId);
      notifyListeners();
  }

  void removeOneProduct(String productId) {

      /// if the quantity is 1 so remove all the cart
      if(_items[productId].quantity == 1)
        removeCart(productId);

      /// if it`s more than one reduce the quantity
      else {

      _items.update(productId, (existingCartItem) =>
          CartItem(id: existingCartItem.id, quantity: existingCartItem.quantity - 1 , title: existingCartItem.title,price: existingCartItem.price)
      );
        notifyListeners();
      }
    }
    /// clearing the cart after making an order
    void clear(){
      _items = {};
      notifyListeners();
    }
  }


