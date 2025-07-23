import 'dart:async';
import 'package:flutter/material.dart';
import '../models/messageModel.dart';
import '../models/userModel.dart';
import '../services/apiService.dart';
import '../services/socketService.dart';
import 'auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  List<UserModel> _users = [];
  List<Message> _messages = [];
  AuthProvider? _authProvider;

  List<UserModel> get users => _users;
  List<Message> get messages => _messages;

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  void connectSocket() {
    if (_authProvider?.userId == null) return;
    _socketService.connectAndListen(_authProvider!.userId!);
    _socketService.messages.listen((data) {
      _messages.add(Message.fromJson(data));
      notifyListeners();
    });
  }

  Future<void> fetchUsers() async {
    if (_authProvider?.token == null) return;
    try {
      _users = await _apiService.getUsers(_authProvider!.token!);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchChatHistory(String receiverId) async {
    if (_authProvider?.token == null) return;
    try {
      _messages = await _apiService.getChatHistory(_authProvider!.token!, receiverId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void sendMessage(String receiverId, String content) {
    if (_authProvider?.userId == null) return;
    _socketService.sendMessage(_authProvider!.userId!, receiverId, content);
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}