import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/cosntants.dart';


class SocketService {
  late IO.Socket _socket;

  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messages => _messageController.stream;

  void connectAndListen(String userId) {
    _socket = IO.io(Constants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('Socket connected');
      _socket.emit('register_user', userId);
    });

    _socket.on('receive_message', (data) {
      _messageController.add(data);
    });
  }

  void sendMessage(String senderId, String receiverId, String content) {
    _socket.emit('send_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  void disconnect() {
    _socket.disconnect();
    _messageController.close();
  }
}