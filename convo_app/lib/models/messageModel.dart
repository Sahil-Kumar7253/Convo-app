class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      senderId: json['sender']['_id'] ?? json['sender'],
      receiverId: json['receiver'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}