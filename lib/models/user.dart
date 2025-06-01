class UserModel {
  final int? id;
  final String username;
  final String password;
  String? bio;
  String? imgPath;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    this.bio,
    this.imgPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'bio': bio,
      'imgPath': imgPath,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      bio: map['bio'],
      imgPath: map['imgPath'],
    );
  }
}
