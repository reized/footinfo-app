import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String password, String hashedPassword) {
    String hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }

  static String hashPasswordWithSalt(String password, String salt) {
    var combinedBytes = utf8.encode(password + salt);
    var digest = sha256.convert(combinedBytes);
    return digest.toString();
  }

  static String generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
