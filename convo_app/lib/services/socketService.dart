import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class SocketService {
  IO.Socket? _socket;
  StreamController<dynamic>? _messageController;
  StreamController<dynamic>? _deleteMessageController;

  Stream<dynamic> get messages =>
      _messageController?.stream ?? Stream.empty();

  Stream<dynamic> get deleteMessages =>
      _deleteMessageController?.stream ?? Stream.empty();

  void connectAndListen(String userId) {
    print("🔌 Socket connection started.");

    if (_socket != null && _socket!.connected) {
      print('Socket is already connected.');
      return;
    }

    // 4. Create NEW instances for the new session.
    _messageController = StreamController<dynamic>.broadcast();
    _deleteMessageController = StreamController<dynamic>.broadcast();

    _socket = IO.io("http://10.0.2.2:3000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected successfully.');
      _socket!.emit('register_user', userId);
    });

    _socket!.on('receive_private_message', (data) {
      _messageController?.add(data);
    });

    _socket!.on('message_deleted', (data) {
      _deleteMessageController?.add(data);
    });
    _socket!.onConnectError((data) => print("❌ Socket Connect Error: $data"));
    _socket!.onError((data) => print("❌ Socket Error: $data"));
  }


  void sendMessage(String senderId, String receiverId, String content) {
    _socket?.emit('send_private_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  void disconnect() {
    // 5. Fully tear down and clean up all resources.
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    _messageController?.close();
    _messageController = null;

    _deleteMessageController?.close();
    _deleteMessageController = null;

    print("🔌 Socket disconnected and resources cleaned up.");
  }
}