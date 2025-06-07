import 'package:footinfo_app/models/user.dart';
import 'package:footinfo_app/services/encryption_service.dart';
import 'database_helper.dart';

class UserService {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<int> insertUser(UserModel user) async {
    final db = await dbHelper.database;

    final encryptedUser = UserModel(
      id: user.id,
      username: user.username,
      password: EncryptionService.hashPassword(user.password),
      bio: user.bio,
      imgPath: user.imgPath,
    );

    return await db.insert('users', encryptedUser.toMap());
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUser(String username, String password) async {
    final db = await dbHelper.database;

    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (res.isNotEmpty) {
      final user = UserModel.fromMap(res.first);

      if (EncryptionService.verifyPassword(password, user.password)) {
        return user;
      }
    }

    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await dbHelper.database;

    final updatedUser = UserModel(
      id: user.id,
      username: user.username,
      password: user.password.length == 64
          ? user.password
          : EncryptionService.hashPassword(user.password),
      bio: user.bio,
      imgPath: user.imgPath,
    );

    return await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await dbHelper.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    final user = await getUserById(userId);
    if (user == null) return false;

    if (!EncryptionService.verifyPassword(oldPassword, user.password)) {
      return false;
    }

    final updatedUser = UserModel(
      id: user.id,
      username: user.username,
      password: EncryptionService.hashPassword(newPassword),
      bio: user.bio,
      imgPath: user.imgPath,
    );

    final result = await updateUser(updatedUser);
    return result > 0;
  }
}
