import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cryptographic service that handles secure master key derivation
/// using PBKDF2 with per-device salt for enhanced security
class CryptoService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _deviceSaltKey = 'device_salt';
  static const String _masterKeyHashKey = 'master_key_hash';
  static const String _biometricKeyKey = 'biometric_master_key';
  static const String _biometricSaltKey = 'biometric_salt';
  
  // PBKDF2 parameters - following OWASP recommendations
  static const int _pbkdf2Iterations = 600000; // 600k iterations for HMAC-SHA256
  static const int _saltLength = 32; // 256 bits
  static const int _keyLength = 32; // 256 bits for the master key
  
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Random _secureRandom = Random.secure();

  /// Generate or retrieve the per-device salt
  /// This salt is unique to each device installation
  Future<Uint8List> _getDeviceSalt() async {
    try {
      // Try to retrieve existing salt
      final existingSalt = await _storage.read(key: _deviceSaltKey);
      if (existingSalt != null) {
        return base64Decode(existingSalt);
      }

      // Generate new salt if none exists
      final salt = _generateSecureRandomBytes(_saltLength);
      await _storage.write(key: _deviceSaltKey, value: base64Encode(salt));
      
      debugPrint('CryptoService: Generated new device salt');
      
      return salt;
    } catch (e) {
      throw Exception('Failed to get device salt: $e');
    }
  }

  /// Generate cryptographically secure random bytes
  Uint8List _generateSecureRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes;
  }

  /// Get device-specific identifier to enhance salt uniqueness
  Future<String> _getDeviceIdentifier() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.id}_${androidInfo.fingerprint}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios_unknown';
      } else if (defaultTargetPlatform == TargetPlatform.linux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return '${linuxInfo.machineId ?? 'linux'}_${linuxInfo.name}';
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return '${windowsInfo.computerName}_${windowsInfo.systemMemoryInMegabytes}';
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        return '${macInfo.systemGUID ?? 'macos'}_${macInfo.model}';
      }
      return 'unknown_device';
    } catch (e) {
      debugPrint('CryptoService: Error getting device identifier: $e');
      return 'fallback_device_id';
    }
  }

  /// Derive master key from passphrase using PBKDF2 with device salt
  Future<Uint8List> deriveMasterKey(String passphrase) async {
    if (passphrase.isEmpty) {
      throw ArgumentError('Passphrase cannot be empty');
    }

    try {
      // Get device salt
      final deviceSalt = await _getDeviceSalt();
      
      // Get device identifier and mix it with the salt for added entropy
      final deviceId = await _getDeviceIdentifier();
      final deviceIdBytes = utf8.encode(deviceId);
      
      // Combine device salt with device ID bytes for enhanced uniqueness
      final combinedSalt = Uint8List(deviceSalt.length + deviceIdBytes.length);
      combinedSalt.setRange(0, deviceSalt.length, deviceSalt);
      combinedSalt.setRange(deviceSalt.length, combinedSalt.length, deviceIdBytes);

      // Derive the master key using PBKDF2
      final passphraseBytes = utf8.encode(passphrase);
      final masterKey = _pbkdf2(passphraseBytes, combinedSalt, _pbkdf2Iterations, _keyLength);

      debugPrint('CryptoService: Successfully derived master key (${masterKey.length} bytes)');

      return masterKey;
    } catch (e) {
      throw Exception('Failed to derive master key: $e');
    }
  }

  /// PBKDF2 implementation using HMAC-SHA256
  Uint8List _pbkdf2(List<int> password, List<int> salt, int iterations, int keyLength) {
    final blocks = <int>[];
    final blockCount = (keyLength / 32).ceil(); // SHA-256 produces 32-byte blocks
    
    for (int i = 1; i <= blockCount; i++) {
      final block = _pbkdf2Block(password, salt, iterations, i);
      blocks.addAll(block);
    }
    
    // Truncate to desired key length
    return Uint8List.fromList(blocks.take(keyLength).toList());
  }

  /// Generate a single PBKDF2 block
  List<int> _pbkdf2Block(List<int> password, List<int> salt, int iterations, int blockNumber) {
    // Create HMAC-SHA256
    final hmac = Hmac(sha256, password);
    
    // Initial U1 = HMAC(password, salt || blockNumber)
    final saltWithBlock = [...salt, ...[(blockNumber >> 24) & 0xFF, (blockNumber >> 16) & 0xFF, (blockNumber >> 8) & 0xFF, blockNumber & 0xFF]];
    var u = hmac.convert(saltWithBlock).bytes;
    var result = List<int>.from(u);
    
    // Iterate: U2 = HMAC(password, U1), U3 = HMAC(password, U2), ...
    for (int j = 1; j < iterations; j++) {
      u = hmac.convert(u).bytes;
      // XOR with result
      for (int k = 0; k < result.length; k++) {
        result[k] ^= u[k];
      }
    }
    
    return result;
  }

  /// Create and store a hash of the master key for verification
  Future<bool> createMasterKeyHash(String passphrase) async {
    try {
      final masterKey = await deriveMasterKey(passphrase);
      
      // Create a hash of the master key for verification
      // We add additional rounds of hashing to make verification slower
      final keyHash = _hashMasterKey(masterKey);
      
      await _storage.write(key: _masterKeyHashKey, value: base64Encode(keyHash));
      
      // Clear the master key from memory
      masterKey.fillRange(0, masterKey.length, 0);
      
      debugPrint('CryptoService: Master key hash created and stored');
      
      return true;
    } catch (e) {
      debugPrint('CryptoService: Failed to create master key hash: $e');
      return false;
    }
  }

  /// Verify passphrase by deriving master key and comparing hash
  Future<bool> verifyPassphrase(String passphrase) async {
    try {
      final storedHashBase64 = await _storage.read(key: _masterKeyHashKey);
      if (storedHashBase64 == null) {
        debugPrint('CryptoService: No stored master key hash found');
        return false;
      }

      final storedHash = base64Decode(storedHashBase64);
      final masterKey = await deriveMasterKey(passphrase);
      final computedHash = _hashMasterKey(masterKey);

      // Clear the master key from memory
      masterKey.fillRange(0, masterKey.length, 0);

      // Constant time comparison to prevent timing attacks
      bool isValid = _constantTimeEquals(storedHash, computedHash);
      
      debugPrint('CryptoService: Passphrase verification ${isValid ? 'successful' : 'failed'}');
      
      return isValid;
    } catch (e) {
      debugPrint('CryptoService: Error during passphrase verification: $e');
      return false;
    }
  }

  /// Hash the master key with additional security rounds
  Uint8List _hashMasterKey(Uint8List masterKey) {
    // Use multiple rounds of SHA-256 to slow down potential attacks
    var hash = masterKey;
    for (int i = 0; i < 10000; i++) {
      final digest = sha256.convert(hash);
      hash = Uint8List.fromList(digest.bytes);
    }
    return hash;
  }

  /// Constant time comparison to prevent timing attacks
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  /// Get master key for encryption/decryption operations
  /// WARNING: Handle with extreme care - clear from memory when done
  Future<Uint8List> getMasterKeyForOperation(String passphrase) async {
    // First verify the passphrase is correct
    final isValid = await verifyPassphrase(passphrase);
    if (!isValid) {
      throw Exception('Invalid passphrase');
    }
    
    // Derive and return the master key
    return await deriveMasterKey(passphrase);
  }



  /// Check if master key system is initialized
  Future<bool> isInitialized() async {
    try {
      final salt = await _storage.read(key: _deviceSaltKey);
      final hash = await _storage.read(key: _masterKeyHashKey);
      return salt != null && hash != null;
    } catch (e) {
      return false;
    }
  }

  /// Store master key encrypted for biometric access
  /// This allows biometric authentication to retrieve the master key without the passphrase
  Future<bool> setupBiometricMasterKey(String passphrase) async {
    try {
      // Derive the master key from the passphrase
      final masterKey = await deriveMasterKey(passphrase);
      
      // Generate a random biometric salt
      final biometricSalt = _generateSecureRandomBytes(_saltLength);
      
      // Create a simple encryption key from device info (not super secure but better than plaintext)
      final deviceId = await _getDeviceIdentifier();
      final encryptionKey = sha256.convert(utf8.encode('${deviceId}biometric_key')).bytes;
      
      // XOR encrypt the master key (simple but effective for this purpose)
      final encryptedMasterKey = List<int>.generate(
        masterKey.length, 
        (i) => masterKey[i] ^ encryptionKey[i % encryptionKey.length]
      );
      
      // Store the encrypted master key and biometric salt
      await _storage.write(key: _biometricKeyKey, value: base64Encode(encryptedMasterKey));
      await _storage.write(key: _biometricSaltKey, value: base64Encode(biometricSalt));
      
      // Clear the master key from memory
      masterKey.fillRange(0, masterKey.length, 0);
      
      debugPrint('CryptoService: Biometric master key setup completed');
      
      return true;
    } catch (e) {
      debugPrint('CryptoService: Failed to setup biometric master key: $e');
      return false;
    }
  }

  /// Retrieve master key for biometric authentication
  /// This should only be called after biometric authentication succeeds
  Future<Uint8List?> getBiometricMasterKey() async {
    try {
      final encryptedKeyBase64 = await _storage.read(key: _biometricKeyKey);
      if (encryptedKeyBase64 == null) {
        debugPrint('CryptoService: No biometric master key found');
        return null;
      }
      
      final encryptedKey = base64Decode(encryptedKeyBase64);
      
      // Recreate the encryption key from device info
      final deviceId = await _getDeviceIdentifier();
      final encryptionKey = sha256.convert(utf8.encode('${deviceId}biometric_key')).bytes;
      
      // XOR decrypt the master key
      final decryptedMasterKey = Uint8List.fromList(
        List<int>.generate(
          encryptedKey.length,
          (i) => encryptedKey[i] ^ encryptionKey[i % encryptionKey.length]
        )
      );
      
      debugPrint('CryptoService: Successfully retrieved biometric master key');
      
      return decryptedMasterKey;
    } catch (e) {
      debugPrint('CryptoService: Failed to retrieve biometric master key: $e');
      return null;
    }
  }

  /// Check if biometric master key is set up
  Future<bool> isBiometricMasterKeySetup() async {
    try {
      final encryptedKey = await _storage.read(key: _biometricKeyKey);
      final biometricSalt = await _storage.read(key: _biometricSaltKey);
      return encryptedKey != null && biometricSalt != null;
    } catch (e) {
      return false;
    }
  }

  /// Remove biometric master key (when biometrics are disabled)
  Future<bool> removeBiometricMasterKey() async {
    try {
      await _storage.delete(key: _biometricKeyKey);
      await _storage.delete(key: _biometricSaltKey);
      
      debugPrint('CryptoService: Biometric master key removed');
      
      return true;
    } catch (e) {
      debugPrint('CryptoService: Failed to remove biometric master key: $e');
      return false;
    }
  }

  /// Reset all cryptographic data (for app reset or testing)
  Future<bool> resetCryptoData() async {
    try {
      await _storage.delete(key: _deviceSaltKey);
      await _storage.delete(key: _masterKeyHashKey);
      await _storage.delete(key: _biometricKeyKey);
      await _storage.delete(key: _biometricSaltKey);
      
      debugPrint('CryptoService: All crypto data reset');
      
      return true;
    } catch (e) {
      debugPrint('CryptoService: Failed to reset crypto data: $e');
      return false;
    }
  }

  /// Get cryptographic information for debugging (non-sensitive data only)
  Future<Map<String, dynamic>> getCryptoInfo() async {
    if (!kDebugMode) {
      return {'error': 'Debug info only available in debug mode'};
    }
    
    try {
      final deviceId = await _getDeviceIdentifier();
      final isInit = await isInitialized();
      final hasBiometricKey = await isBiometricMasterKeySetup();
      final salt = await _storage.read(key: _deviceSaltKey);
      
      return {
        'device_id': deviceId,
        'is_initialized': isInit,
        'has_salt': salt != null,
        'has_biometric_key': hasBiometricKey,
        'pbkdf2_iterations': _pbkdf2Iterations,
        'salt_length': _saltLength,
        'key_length': _keyLength,
      };
    } catch (e) {
      return {'error': 'Failed to get crypto info: $e'};
    }
  }
}
