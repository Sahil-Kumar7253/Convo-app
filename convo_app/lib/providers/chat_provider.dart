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

  List<UserModel> _friends = [];
  List<UserModel> _friendRequests = [];
  List<UserModel> _discoverableUsers = [];
  List<UserModel> get friends => _friends;
  List<UserModel> get friendRequests => _friendRequests;
  List<UserModel> get discoverableUsers => _discoverableUsers;

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

  Future<void> fetchFriends(String token) async {
    _friends = await _apiService.getFriends(token);
    notifyListeners();
  }

  Future<void> fetchFriendRequests(String token) async {
    try {
      print("1. Fetching friend requests...");
      _friendRequests = await _apiService.getFriendRequests(token);

      // This log is crucial. It shows us what was received from the backend.
      print("2. Received friend requests data: ${_friendRequests.length} items.");

      notifyListeners();
      print("3. Notified listeners.");
    } catch (e) {
      print("❌ ERROR in fetchFriendRequests: $e");
    }
  }

  Future<void> fetchDiscoverableUsers(String token) async {
    try {
      _discoverableUsers = await _apiService.getUsers(token);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendFriendRequest(String token, String receiverId) async {
    try {
      await _apiService.sendFriendRequest(token, receiverId);
      // Remove the user from the discoverable list for instant UI feedback
      _discoverableUsers.removeWhere((user) => user.id == receiverId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> acceptFriendRequest(String token, String senderId) async {
    try {
      await _apiService.acceptFriendRequest(token, senderId);
      _friendRequests.removeWhere((user) => user.id == senderId);
      await fetchFriends(token);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> declineFriendRequest(String token, String senderId) async {
    try {
      await _apiService.declineFriendRequest(token, senderId);
      _friendRequests.removeWhere((user) => user.id == senderId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeFriend(String token, String friendId) async {
    try {
      await _apiService.removeFriend(token, friendId);
      _friends.removeWhere((user) => user.id == friendId);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchChatHistory(String token, String receiverId) async {
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