import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for encrypting and decrypting mood data
class EncryptionService {
  static const String _keyStorageKey = 'mood_encryption_key';
  static const String _ivStorageKey = 'mood_encryption_iv';
  
  static Encrypter? _encrypter;
  static IV? _iv;

  /// Initialize encryption service with stored or new keys
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get or generate encryption key
    String? storedKey = prefs.getString(_keyStorageKey);
    String? storedIV = prefs.getString(_ivStorageKey);
    
    if (storedKey == null || storedIV == null) {
      // Generate new key and IV
      final key = _generateSecureKey();
      final iv = _generateSecureIV();
      
      // Store keys securely
      await prefs.setString(_keyStorageKey, key);
      await prefs.setString(_ivStorageKey, iv);
      
      _encrypter = Encrypter(AES(Key.fromBase64(key)));
      _iv = IV.fromBase64(iv);
    } else {
      // Use existing keys
      _encrypter = Encrypter(AES(Key.fromBase64(storedKey)));
      _iv = IV.fromBase64(storedIV);
    }
  }

  /// Encrypt data string
  static String encrypt(String data) {
    if (_encrypter == null || _iv == null) {
      throw Exception('Encryption service not initialized');
    }
    
    final encrypted = _encrypter!.encrypt(data, iv: _iv!);
    return encrypted.base64;
  }

  /// Decrypt data string
  static String decrypt(String encryptedData) {
    if (_encrypter == null || _iv == null) {
      throw Exception('Encryption service not initialized');
    }
    
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter!.decrypt(encrypted, iv: _iv!);
  }

  /// Generate a secure encryption key
  static String _generateSecureKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Generate a secure initialization vector
  static String _generateSecureIV() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Hash data for integrity verification
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify data integrity
  static bool verifyDataIntegrity(String data, String expectedHash) {
    final actualHash = hashData(data);
    return actualHash == expectedHash;
  }

  /// Secure key rotation (for enhanced security)
  static Future<void> rotateKeys() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Generate new keys
    final newKey = _generateSecureKey();
    final newIV = _generateSecureIV();
    
    // Update stored keys
    await prefs.setString(_keyStorageKey, newKey);
    await prefs.setString(_ivStorageKey, newIV);
    
    // Update in-memory keys
    _encrypter = Encrypter(AES(Key.fromBase64(newKey)));
    _iv = IV.fromBase64(newIV);
  }

  /// Clear encryption keys (for logout/data wipe)
  static Future<void> clearKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStorageKey);
    await prefs.remove(_ivStorageKey);
    
    _encrypter = null;
    _iv = null;
  }
}