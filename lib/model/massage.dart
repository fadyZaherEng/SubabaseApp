class Massage {
  final String message;
  final int? id;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String? createdAt;
  final bool isMine;
  final bool isRead;

  Massage({
    required this.message,
    this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    this.createdAt,
    required this.isMine,
    required this.isRead,
  });

  //from json
  factory Massage.fromJson(Map<String, dynamic> json) {
    return Massage(
      message: json['message'],
      id: json['id'],
      senderId: json['sender_id'],
      senderEmail: json['sender_email'],
      receiverId: json['receiver_id'],
      receiverEmail: json['receiver_email'],
      createdAt: json['created_at'],
      isMine: json['is_mine'],
      isRead: json['is_read'],
    );
  }

  //to json
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender_id': senderId,
      'sender_email': senderEmail,
      'receiver_id': receiverId,
      'receiver_email': receiverEmail,
      'is_mine': isMine,
      'is_read': isRead,
    };
  }
}
