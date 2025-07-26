import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../services/apiService.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _userImage;

  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userImage => _userImage;

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'userName': _userName,
      'userEmail': _userEmail,
      'userImage': _userImage,
    });
    await prefs.setString('userData', userData);
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    if (response.containsKey('token')) {
      _token = response['token'];
      _userId = response['_id'];
      final Map<String, dynamic> payload = Jwt.parseJwt(_token!);
      _userName = payload['name'];
      _userEmail = payload['email'];
      _userImage = response['image'];
      await _saveToPrefs(); // Use await to ensure data is saved
      notifyListeners();
    } else {
      throw Exception(response['message']);
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _apiService.register(name, email, password);
    if (response.containsKey('token')) {
      _token = response['token'];
      _userId = response['_id'];
      _userName = response['name'];
      _userEmail = response['email'];
      await _saveToPrefs(); // Use await to ensure data is saved
      notifyListeners();
    } else {
      throw Exception(response['message']);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    if(_token == null) return;
    try{
       final response = await _apiService.updateProfile(_token!, updateData);
       _token = response['token'];
       _userId = response['_id'];
       _userName = response['name'];
       _userEmail = response['email'];
       await _saveToPrefs();
       notifyListeners();
    }catch(e){
      rethrow;
    }
  }



  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
    json.decode(prefs.getString('userData')!) as Map<String, Object?>;
    _token = extractedUserData['token'] as String?;
    _userId = extractedUserData['userId'] as String?;
    _userName = extractedUserData['userName'] as String?;
    _userEmail = extractedUserData['userEmail'] as String?;
    _userImage = extractedUserData['userImage'] as String?;

    if (_token == null || _userId == null) {
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> uploadProfileImage(String filePath) async {
    if (_token == null) return;
    try {
      final response = await _apiService.uploadProfileImage(_token!, filePath);
      _userImage = response['image'];
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userImage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }
}