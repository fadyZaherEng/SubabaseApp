class UserModel{
  final String userId;
  final String email;
  final String password;
  const UserModel({
    required this.userId,
    required this.email,
    required this.password,
  });
  //from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
  //to json
  Map<String, dynamic> toJson() => <String, dynamic>{
    'userId': userId,
    'email': email,
    'password': password,
  };
}