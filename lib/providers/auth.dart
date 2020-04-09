import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping/models/http_exception.dart';

class Auth with ChangeNotifier {
  /// the token got by firebase to prove that the user is logged in " has access"
  String _token;
  ///  the duration for the token
  DateTime _expireyDate;
  /// the userId
  String _userId;
  /// to calculate when the token will expire
  Timer _authTimer;

  /// if the token is not null so the user is authenticated and return true
  bool get isAuth {
    return token != null;
  }

  /// getting the token to use it to store data into firebase
  String get token {
    if (_expireyDate != null &&
        _expireyDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
  }

  String get userId {
    return _userId;
  }

  /// signing the user in
  Future<void> signup(String email, String password) async {
    return _authentication(email, password, 'signUp');
  }

  /// signing the user in
  Future<void> signIn(String email, String password) async {
    return _authentication(email, password, 'signInWithPassword');
  }

  /// using email & password that the user entered we will authenticate & urlsegment to identify if the user logging in or registering
  Future<void> _authentication(
      String email, String password, String urlSegment) async   {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyA-two2Oh9YDMEaWAOMe4Ew7UMzE2DBWWY';

    /// connecting the usser to the server
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireyDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expireyDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }


  /// checking if there is a token is stored into the device so we can auto log in user

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expireyDate = expiryDate;
     notifyListeners();

    print(_userId);
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireyDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    /// after logging out we clear the userData stored into the device
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final logoutTime = _expireyDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: logoutTime), logout);

  }
}
