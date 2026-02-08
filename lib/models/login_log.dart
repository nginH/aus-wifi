class LoginLog {
  final int? id;
  final DateTime timestamp;
  final String username;
  final String status;
  final String message;

  LoginLog({
    this.id,
    required this.timestamp,
    required this.username,
    required this.status,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'username': username,
      'status': status,
      'message': message,
    };
  }

  factory LoginLog.fromMap(Map<String, dynamic> map) {
    return LoginLog(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      username: map['username'],
      status: map['status'],
      message: map['message'],
    );
  }
}
