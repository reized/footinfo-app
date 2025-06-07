import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  /// Enkripsi password menggunakan SHA-256
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi password dengan hash yang tersimpan
  static bool verifyPassword(String password, String hashedPassword) {
    String hashedInput = hashPassword(password);
    return hashedInput == hashedPassword;
  }

  /// Enkripsi password dengan salt untuk keamanan tambahan
  static String hashPasswordWithSalt(String password, String salt) {
    var combinedBytes = utf8.encode(password + salt);
    var digest = sha256.convert(combinedBytes);
    return digest.toString();
  }

  /// Generate salt sederhana (dalam implementasi production, gunakan generator yang lebih aman)
  static String generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}