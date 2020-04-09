import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// we will manage our data through this provider class
/// we store our products in here and these data are listenable so other widgets need that data can change due to data

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/providers/product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  String imgUrl = '';
  String userId;
  String token;

  ProductsProvider(this.userId, this.token, this._items);

  /// sending only favoritted products

  List<Product> get favouriteItems {
    return _items.where((product) => product.isFavourite).toList();
  }


  /// sending all products to the widgets
  List<Product> get items {
    return [..._items].isEmpty? []: [..._items];
  }

  List<Product> getUserItems() {
    return _items.where((product) => product.userId == userId).toList();
  }

  /// this method will be called in product_details widget to display item details using it`s id
  Product findById(String id) {
    var productIndex = items.indexWhere((Product p) => p.id == id);
    return items[productIndex];
  }

  /// getting products from database

  Future<void> fetchProducts() async {
    var url = 'https://shopping-59751.firebaseio.com/products.json?auth=$token';

    return http.get(url).then((response) async {
      final extracedData = json.decode(response.body) as Map<String, dynamic>;
      if(extracedData == null ){
        return;
      }
      url =  'https://shopping-59751.firebaseio.com/userFav/$userId.json?auth=$token';
      final favouriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favouriteResponse.body);
      final List<Product> _loadedProducts = [];
        extracedData.forEach((productId, productData) {
          _loadedProducts.add(Product(
              isFavourite: favoriteData == null ?  false : favoriteData[productId] ?? false,
              userId: productData['userId'],
              id: productId,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],

              ),

          );
      });


      _items = _loadedProducts;
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> addProduct(Product product, File imgFile) async {
    final String url = 'https://shopping-59751.firebaseio.com/products.json?auth=$token';

    /// wait untill the image file is uploaded to firestore and get its link
    await uploadStatusImage(imgFile);
    print(userId);
    /// save to the database and return a future object
    return http
        .post(url,
            body: jsonEncode({
              'title': product.title,
              'description': product.description,
              'imageUrl': imgUrl,
              'price': product.price,
              'userId':userId
            }))
        .then((response) {
      final newProduct = Product(
          userId: userId,
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: imgUrl,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }


  Future<void> removeProduct(Product product) async {
    final String url =
        'https://shopping-59751.firebaseio.com/products/${product.id}.json?auth=$token';

    /// getting the index of our product
    final productIndex = _items.indexOf(product);

    /// making a backup copy of our product so if an error happens while deleting  we can get it back
    var backupProduct = product;
    _items.remove(product);
    notifyListeners();
    return http.delete(url).then((response) {
      /// if the deletion failed throw an error
      if (response.statusCode >= 400) {
        _items.insert(productIndex, backupProduct);
        notifyListeners();
        throw HttpException('Could not Delete Product.');

      }
      /// else make the backup product null because we don`t need it if the deletion succeed
      backupProduct = null;
    });
  }

  Future<void> updateProducts(
      String id, Product newProduct, File imgFile) async {
    final String url =
        'https://shopping-59751.firebaseio.com/products/$id.json?auth=$token';

    if(imgFile != null ) {
      /// wait untill uploading is done
      await uploadStatusImage(imgFile);

      /// execute updating and return a future object
      return http
          .patch(url,
          body: jsonEncode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': imgUrl,
            'price': newProduct.price
          }))
          .then((_) {
        notifyListeners();
      });
    }
    return http
        .patch(url,
        body: jsonEncode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price
        }))
        .then((_) {
      notifyListeners();
    });


  }

  /// in this function we upload
  Future<void> uploadStatusImage(File imgFile) {
    /// creating a file in firebase storage storage  its name will be Post images
    final StorageReference postImgRef =
        FirebaseStorage.instance.ref().child('Post Images');
    var timeKey = DateTime.now();

    /// uploading operation
    final StorageUploadTask uploadTask =
        postImgRef.child(timeKey.toString() + ".jpg").putFile(imgFile);

    ///when the upload is done get the image url and store it into our variable
    return uploadTask.onComplete.then((response) {
      return response.ref.getDownloadURL();
    }).then((url) {
      imgUrl = url;
      print(imgUrl);
    });
  }
}
