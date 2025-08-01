import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/messageModel.dart';
import '../models/userModel.dart';
import '../utils/constants.dart';

class ApiService {

  final String _baseUrl = Constants.baseUrl;

  dynamic _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'An unknown error occurred.');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(Constants.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(Constants.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    return json.decode(response.body);
  }

  Future<List<UserModel>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<Message>> getChatHistory(String token, String receiverId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/messages/$receiverId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = json.decode(response.body);
      return messagesJson.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  Future<Map<String, dynamic>> updateProfile(String token, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(Constants.updateUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data)
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message'] ?? 'Failed to update profile.');
    }
  }

  Future<void> deleteMessage(String token, String messageId)async {
    await http.delete(
      Uri.parse("http://10.0.2.2:3000/api/messages/$messageId"),
      headers: {"authorization": "Bearer $token"},
    );
  }

  Future<Map<String, dynamic>> uploadProfileImage(String token, String filePath) async {
    final uri = Uri.parse(Constants.profileImageUrl);
    final request = http.MultipartRequest('POST', uri);

    request.headers['authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception(json.decode(responseBody)['message'] ?? 'Failed to upload image.');
    }
  }

  Future<void> sendImageMessage(String token, String receiverId, String filePath)async{
    final uri = Uri.parse(Constants.sendImage);
    final request = http.MultipartRequest('POST', uri);

    request.headers['authorization'] = 'Bearer $token';
    request.fields['receiverId'] = receiverId;
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    final response = await request.send();

    if(response.statusCode != 201){
      final responseBody = await response.stream.bytesToString();
      throw Exception(json.decode(responseBody)['message'] ?? "Failed to send image.");
    }
  }


  //Friends

  Future<List<UserModel>> getFriends(String token) async {
    final response = await http.get(
      Uri.parse(Constants.friendUrl),
      headers: {'authorization': 'Bearer $token'}
    );
    final List<dynamic> friendsJson = _handleResponse(response);
    return friendsJson.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<List<UserModel>> getFriendRequests(String token) async {
    final response = await http.get(
      Uri.parse(Constants.friendRequestUrl),
      headers: {'Authorization': 'Bearer $token'}
    );
    final List<dynamic> friendRequestsJson = _handleResponse(response);
    return friendRequestsJson.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<void> sendFriendRequest(String token, String recieverId) async {
    final response = await http.post(
      Uri.parse("${Constants.friendRequestSendUrl}/$recieverId"),
      headers: {'Authorization': 'Bearer $token'}
    );
    print("Request Send Successfully");
    _handleResponse(response);
  }

  Future<void> acceptFriendRequest(String token, String senderId) async {
    final response = await http.put(
      Uri.parse("${Constants.friendRequestAcceptUrl}/$senderId"),
      headers: {'authorization': 'Bearer $token'}
    );
    _handleResponse(response);
  }

  Future<void> declineFriendRequest(String token, String senderId) async {
    final response = await http.put(
        Uri.parse("${Constants.friendRequestDeclineUrl}/$senderId"),
        headers: {'authorization': 'Bearer $token'}
    );
    _handleResponse(response);
  }

  Future<void> removeFriend(String token, String friendId) async {
    final response = await http.delete(
      Uri.parse("${Constants.friendRemoveUrl}/$friendId"),
      headers: {'authorization': 'Bearer $token'}
    );
    _handleResponse(response);
  }
}