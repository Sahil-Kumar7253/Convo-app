import 'dart:async';
import 'package:flutter/material.dart';
import '../models/messageModel.dart';
import '../models/userModel.dart';
import '../services/apiService.dart';
import '../services/socketService.dart';


class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  List<UserModel> _users = [];
  List<Message> _messages = [];
  StreamSubscription? _messageSubscription;
  StreamSubscription? _deleteMessageSubscription;

  // We no longer need to store the AuthProvider instance here

  List<UserModel> get users => _users;
  List<Message> get messages => _messages;

  // The 'token' and 'userId' will be passed directly when needed
  Future<void> fetchUsers(String token) async {
    try {
      _users = await _apiService.getUsers(token);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deletedMessage(String token, String messageId) async {
    try {
      await _apiService.deleteMessage(token, messageId);
      print('Message deleted successfully');
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> fetchChatHistory(String token, String receiverId) async {
    if (token == null) return;
    try {
      final history = await _apiService.getChatHistory(token, receiverId);
      _messages.clear();
      _messages.addAll(history);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void connectAndListen(String userId) {
    _socketService.connectAndListen(userId);
    // Cancel previous subscription to ensure only one listener is active
    _messageSubscription?.cancel();
    _messageSubscription = _socketService.messages.listen((data) {
      _messages.add(Message.fromJson(data));
      notifyListeners();
    });

    _deleteMessageSubscription?.cancel();
    _deleteMessageSubscription = _socketService.deleteMessages.listen((data) {
      final String deletedMessageId = data['messageId'];
      _messages.removeWhere((msg) => msg.id == deletedMessageId);
      notifyListeners();
    });
  }

  void sendMessage(String senderId, String receiverId, String content) {
    _socketService.sendMessage(senderId, receiverId, content);
  }

  void disconnect() {
    _socketService.disconnect();
    _messageSubscription?.cancel();
    _deleteMessageSubscription?.cancel();
  }
}