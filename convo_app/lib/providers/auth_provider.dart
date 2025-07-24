import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiService.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get userId => _userId;

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({'token': _token, 'userId': _userId});
    await prefs.setString('userData', userData);
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    if (response.containsKey('token')) {
      _token = response['token'];
      _userId = response['_id'];
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
      await _saveToPrefs(); // Use await to ensure data is saved
      notifyListeners();
    } else {
      throw Exception(response['message']);
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

    if (_token == null || _userId == null) {
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }
}