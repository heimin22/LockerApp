import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'crypto_service.dart';

/// Authentication service that handles password and biometric authentication
/// Now uses secure master key derivation with PBKDF2 and per-device salt
class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _passwordHashKey = 'user_password_hash'; // Legacy key
  static const String _firstTimeKey = 'is_first_time';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  static const String _migrationCompleteKey = 'crypto_migration_complete';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final CryptoService _cryptoService = CryptoService();

  /// Check if this is the first time launching the app (no password set)
  Future<bool> isFirstTime() async {
    try {
      final isFirstTime = await _storage.read(key: _firstTimeKey);
      final isFirstTimeFlag = isFirstTime == null || isFirstTime == 'true';
      
      // Also check if crypto system is initialized
      final cryptoInitialized = await _cryptoService.isInitialized();
      
      return isFirstTimeFlag || !cryptoInitialized;
    } catch (e) {
      return true; // Default to first time if there's an error
    }
  }

  /// Create and store the user's password using secure master key derivation
  Future<bool> createPassword(String password) async {
    try {
      if (password.isEmpty) return false;
      
      // Use the new crypto system for password creation
      final success = await _cryptoService.createMasterKeyHash(password);
      if (success) {
        await _storage.write(key: _firstTimeKey, value: 'false');
        await _storage.write(key: _migrationCompleteKey, value: 'true');
        
        // Remove legacy password hash if it exists
        await _storage.delete(key: _passwordHashKey);
        
        if (kDebugMode) {
          print('AuthService: Password created with secure crypto system');
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Failed to create password: $e');
      }
      return false;
    }
  }

  /// Verify the provided password against stored hash
  /// Handles both new crypto system and legacy system with automatic migration
  Future<bool> verifyPassword(String password) async {
    try {
      if (password.isEmpty) return false;
      
      // Check if migration to new crypto system is complete
      final migrationComplete = await _storage.read(key: _migrationCompleteKey);
      final cryptoInitialized = await _cryptoService.isInitialized();
      
      if (migrationComplete == 'true' || cryptoInitialized) {
        // Use new crypto system
        final isValid = await _cryptoService.verifyPassphrase(password);
        
        if (kDebugMode) {
          print('AuthService: Password verified with secure crypto system');
        }
        
        return isValid;
      }
      
      // Handle legacy system and migrate if password is correct
      final legacyHash = await _storage.read(key: _passwordHashKey);
      if (legacyHash != null) {
        final computedHash = _hashPassword(password);
        if (computedHash == legacyHash) {
          if (kDebugMode) {
            print('AuthService: Legacy password verified, initiating migration');
          }
          
          // Migrate to new crypto system
          final migrationSuccess = await _migrateToNewCryptoSystem(password);
          if (migrationSuccess) {
            if (kDebugMode) {
              print('AuthService: Successfully migrated to new crypto system');
            }
          }
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Password verification failed: $e');
      }
      return false;
    }
  }

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if biometric authentication is enabled by the user
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricsEnabledKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      if (!enabled) {
        // When disabling biometrics, remove the biometric master key
        await _cryptoService.removeBiometricMasterKey();
        
        if (kDebugMode) {
          print('AuthService: Biometric disabled and master key removed');
        }
      }
      
      await _storage.write(key: _biometricsEnabledKey, value: enabled.toString());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Failed to set biometric enabled: $e');
      }
      return false;
    }
  }

  /// Authenticate using biometrics
  /// Returns true if biometric authentication succeeds and master key is available
  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to access your locker',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return false;

      // Check if biometric master key is setup
      final hasBiometricKey = await _cryptoService.isBiometricMasterKeySetup();
      if (!hasBiometricKey) {
        if (kDebugMode) {
          print('AuthService: Biometric master key not setup');
        }
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Biometric authentication required',
            cancelButton: 'No thanks',
          ),
          const IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        if (kDebugMode) {
          print('AuthService: Biometric authentication successful');
        }
        return true;
      }

      return false;
    } on PlatformException catch (e) {
      // Handle specific biometric errors
      if (e.code == 'NotAvailable') {
        if (kDebugMode) {
          print('AuthService: Biometric not available: ${e.message}');
        }
        return false;
      } else if (e.code == 'NotEnrolled') {
        if (kDebugMode) {
          print('AuthService: Biometric not enrolled: ${e.message}');
        }
        return false;
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        if (kDebugMode) {
          print('AuthService: Biometric locked out: ${e.message}');
        }
        return false;
      }
      if (kDebugMode) {
        print('AuthService: Biometric error: ${e.code} - ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Biometric authentication failed: $e');
      }
      return false;
    }
  }

  /// Setup biometric authentication (should be called after password is set)
  /// This will securely store the master key for biometric access
  Future<bool> setupBiometricAuthentication(String passphrase) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) return false;

      // First verify the passphrase is correct
      final isValidPassphrase = await verifyPassword(passphrase);
      if (!isValidPassphrase) {
        if (kDebugMode) {
          print('AuthService: Invalid passphrase provided for biometric setup');
        }
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Set up biometric authentication',
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Set up biometric authentication',
            cancelButton: 'Cancel setup',
          ),
          const IOSAuthMessages(
            cancelButton: 'Cancel setup',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Setup the biometric master key
        final biometricKeySetup = await _cryptoService.setupBiometricMasterKey(passphrase);
        if (biometricKeySetup) {
          await setBiometricEnabled(true);
          
          if (kDebugMode) {
            print('AuthService: Biometric authentication with master key setup completed');
          }
          
          return true;
        } else {
          if (kDebugMode) {
            print('AuthService: Failed to setup biometric master key');
          }
          return false;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Biometric setup failed: $e');
      }
      return false;
    }
  }

  /// Migrate from legacy password system to new crypto system
  Future<bool> _migrateToNewCryptoSystem(String password) async {
    try {
      // Create master key hash with new system
      final success = await _cryptoService.createMasterKeyHash(password);
      if (success) {
        // Mark migration as complete
        await _storage.write(key: _migrationCompleteKey, value: 'true');
        // Remove legacy password hash
        await _storage.delete(key: _passwordHashKey);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Migration to new crypto system failed: $e');
      }
      return false;
    }
  }

  /// Get master key for encryption operations (use with extreme care)
  /// Can be called with password or after successful biometric authentication
  Future<List<int>?> getMasterKey([String? password]) async {
    try {
      if (password != null) {
        // Password-based master key retrieval
        final isValid = await verifyPassword(password);
        if (!isValid) return null;
        
        return await _cryptoService.getMasterKeyForOperation(password);
      } else {
        // Biometric-based master key retrieval
        // This should only be called immediately after successful biometric authentication
        final biometricKey = await _cryptoService.getBiometricMasterKey();
        if (biometricKey != null) {
          if (kDebugMode) {
            print('AuthService: Retrieved master key via biometric authentication');
          }
          return biometricKey;
        }
        
        if (kDebugMode) {
          print('AuthService: Failed to retrieve biometric master key');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Failed to get master key: $e');
      }
      return null;
    }
  }

  /// Reset all authentication data (for testing or reset functionality)
  Future<bool> resetAuth() async {
    try {
      // Reset new crypto system
      await _cryptoService.resetCryptoData();
      
      // Reset legacy and other auth data
      await _storage.delete(key: _passwordHashKey);
      await _storage.delete(key: _firstTimeKey);
      await _storage.delete(key: _biometricsEnabledKey);
      await _storage.delete(key: _migrationCompleteKey);
      
      if (kDebugMode) {
        print('AuthService: All authentication data reset');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Failed to reset auth data: $e');
      }
      return false;
    }
  }

  /// Hash password using SHA-256 (legacy method - kept for migration)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get cryptographic information for debugging
  Future<Map<String, dynamic>> getCryptoInfo() async {
    if (!kDebugMode) {
      return {'error': 'Debug info only available in debug mode'};
    }
    
    try {
      final cryptoInfo = await _cryptoService.getCryptoInfo();
      final migrationComplete = await _storage.read(key: _migrationCompleteKey);
      final hasLegacyHash = await _storage.read(key: _passwordHashKey) != null;
      final biometricEnabled = await isBiometricEnabled();
      final biometricAvailable = await isBiometricAvailable();
      final availableBiometrics = await getAvailableBiometrics();
      
      return {
        ...cryptoInfo,
        'migration_complete': migrationComplete == 'true',
        'has_legacy_hash': hasLegacyHash,
        'biometric_enabled': biometricEnabled,
        'biometric_available': biometricAvailable,
        'available_biometrics': availableBiometrics.map((b) => b.toString()).toList(),
      };
    } catch (e) {
      return {'error': 'Failed to get crypto info: $e'};
    }
  }

  /// Get biometric type display name
  String getBiometricDisplayName(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (biometrics.contains(BiometricType.strong) || 
               biometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}
