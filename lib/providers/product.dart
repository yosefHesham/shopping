// here we define how our data will look like
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/models/http_exception.dart';
/// we added change notifier so that we can manage favorite status
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String userId;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    @required this.userId,
    this.isFavourite = false

  });

  /// this function to handle favorite status

  Future<void> toggleFavorite(String token, String userId) {
    final url = 'https://shopping-59751.firebaseio.com/userFav/$userId/${this.id}.json?auth=$token';
    final oldStatus = this.isFavourite;
    this.isFavourite = ! this.isFavourite;
    notifyListeners();
    return http.put(url, body: jsonEncode(
       this.isFavourite
    )).then((response){
          if(response.statusCode >= 400) {
            this.isFavourite = oldStatus;
            notifyListeners();
            throw HttpException('Could not change status');
          }
    }).catchError((_){
      this.isFavourite = oldStatus;
      notifyListeners();
    });

  }
}
