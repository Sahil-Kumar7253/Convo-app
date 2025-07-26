class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String? content;
  final String? imageUrl;
  final String messageType;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.messageType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      senderId: json['sender']['_id'] ?? json['sender'],
      receiverId: json['receiver'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      messageType: json['messageType'] ?? "text",
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}