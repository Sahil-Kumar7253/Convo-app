import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class SocketService {
  // 1. Make both the socket and the controller nullable.
  //    Their existence now represents an active session.
  IO.Socket? _socket;
  StreamController<dynamic>? _messageController;

  // 2. The public stream getter must handle the case where the controller is null.
  //    It returns an empty stream if there is no active session.
  Stream<dynamic> get messages =>
      _messageController?.stream ?? Stream.empty();

  void connectAndListen(String userId) {
    // 3. Ensure we don't create multiple connections.
    //    If a socket already exists, do nothing.
    if (_socket != null && _socket!.connected) {
      print('Socket is already connected.');
      return;
    }

    // 4. Create NEW instances for the new session.
    _messageController = StreamController<dynamic>.broadcast();
    _socket = IO.io(Constants.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected successfully.');
      _socket!.emit('register_user', userId);
    });

    _socket!.on('receive_private_message', (data) {
      // Add data only to the current, active controller.
      _messageController?.add(data);
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

    print("🔌 Socket disconnected and resources cleaned up.");
  }
}