import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';
import '../utils/toast_utils.dart';
import '../themes/app_colors.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = true;
  String _loadingMessage = 'Loading...';
  bool _isFirstTime = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];
  String _biometricDisplayName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometricState();
    }
  }

  Future<void> _initialize() async {
    await _checkAuthState();
    if (_isFirstTime) {
      await _checkBiometricState();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkAuthState() async {
    final isFirstTime = await _authService.isFirstTime();
    setState(() {
      _isFirstTime = isFirstTime;
    });
  }

  Future<void> _checkBiometricState() async {
    final isAvailable = await _authService.isBiometricAvailable();
    final isEnabled = await _authService.isBiometricEnabled();
    final biometrics = await _authService.getAvailableBiometrics();
    final displayName = _authService.getBiometricDisplayName(biometrics);
    
    setState(() {
      _isBiometricAvailable = isAvailable;
      _isBiometricEnabled = isEnabled;
      _availableBiometrics = biometrics;
      _biometricDisplayName = displayName;
    });
  }

  Future<void> _createPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      ToastUtils.showToast('Please enter a password');
      return;
    }

    if (password.length < 6) {
      ToastUtils.showToast('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      ToastUtils.showToast('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Creating secure password...';
    });

    final success = await _createPasswordWithTimeout(password);
    if (success) {
      ToastUtils.showToast('Password created successfully');
      _passwordController.clear();
      _confirmPasswordController.clear();

      await _checkBiometricState();
      
      // Check if user wants to set up biometrics
      if (_isBiometricAvailable) {
        _showBiometricSetupDialog();
      } else {
        _navigateToMainApp();
      }
    } else {
      ToastUtils.showToast('Failed to create password');
    }

    setState(() {
      _isLoading = false;
      _loadingMessage = 'Loading...';
    });
  }

  /// Create password with timeout to prevent hanging
  Future<bool> _createPasswordWithTimeout(String password) async {
    try {
      return await _authService.createPassword(password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Password creation timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('Password creation error: $e');
      return false;
    }
  }

  Future<void> _authenticateWithPassword() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ToastUtils.showToast('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Verifying password...';
    });

    final success = await _verifyPasswordWithTimeout(password);
    if (success) {
      _passwordController.clear();
      _navigateToMainApp();
    } else {
      ToastUtils.showToast('Incorrect password');
      // Clear password field for security
      _passwordController.clear();
    }

    setState(() {
      _isLoading = false;
      _loadingMessage = 'Loading...';
    });
  }

  /// Verify password with timeout to prevent hanging
  Future<bool> _verifyPasswordWithTimeout(String password) async {
    try {
      return await _authService.verifyPassword(password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Password verification timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('Password verification error: $e');
      return false;
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Authenticating with $_biometricDisplayName...';
    });

    final success = await _authenticateBiometricsWithTimeout();
    if (success) {
      _navigateToMainApp();
    } else {
      ToastUtils.showToast('Biometric authentication failed');
    }

    setState(() {
      _isLoading = false;
      _loadingMessage = 'Loading...';
    });
  }

  /// Authenticate with biometrics with timeout
  Future<bool> _authenticateBiometricsWithTimeout() async {
    try {
      return await _authService.authenticateWithBiometrics().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Biometric authentication timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  void _showBiometricSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Set up $_biometricDisplayName'),
        content: Text(
          'Would you like to enable $_biometricDisplayName authentication for faster login?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToMainApp();
            },
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _setupBiometrics();
            },
            child: const Text('Set up'),
          ),
        ],
      ),
    );
  }

  Future<void> _setupBiometrics() async {
    // Show dialog to get user's passphrase for biometric setup
    final passphrase = await _showPassphraseDialog();
    if (passphrase == null) {
      // User cancelled, proceed to main app without biometrics
      _navigateToMainApp();
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Setting up $_biometricDisplayName...';
    });

    final success = await _setupBiometricsWithTimeout(passphrase);
    if (success) {
      ToastUtils.showToast('$_biometricDisplayName enabled successfully');
      await _checkBiometricState();
    } else {
      ToastUtils.showToast('Failed to enable $_biometricDisplayName');
    }

    setState(() {
      _isLoading = false;
      _loadingMessage = 'Loading...';
    });

    _navigateToMainApp();
  }

  /// Setup biometrics with timeout and progress updates
  Future<bool> _setupBiometricsWithTimeout(String passphrase) async {
    try {
      // Step 1: Verify passphrase
      setState(() {
        _loadingMessage = 'Verifying passphrase...';
      });
      
      final passphraseValid = await _authService.verifyPassword(passphrase).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Passphrase verification timed out');
          return false;
        },
      );
      
      if (!passphraseValid) {
        ToastUtils.showToast('Invalid passphrase');
        return false;
      }
      
      // Step 2: Setup biometric authentication
      setState(() {
        _loadingMessage = 'Setting up biometric authentication...';
      });
      
      return await _authService.setupBiometricAuthentication(passphrase).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Biometric setup timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('Biometric setup error: $e');
      return false;
    }
  }

  /// Show dialog to get user's passphrase for biometric setup
  Future<String?> _showPassphraseDialog() async {
    final passphraseController = TextEditingController();
    bool isPasswordVisible = false;
    
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Setup $_biometricDisplayName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your passphrase to securely setup $_biometricDisplayName authentication.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passphraseController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Passphrase',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                passphraseController.dispose();
                Navigator.of(context).pop(null);
              },
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                final passphrase = passphraseController.text.trim();
                passphraseController.dispose();
                Navigator.of(context).pop(passphrase.isNotEmpty ? passphrase : null);
              },
              child: const Text('Setup'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMainApp() {
    ToastUtils.showToast('Welcome to Locker!');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_loadingMessage),
              const SizedBox(height: 8),
              const Text(
                'Please wait...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Title
              Icon(
                Icons.lock,
                size: 80,
                color: AppColors.primaryText,
              ),
              const SizedBox(height: 16),
              Text(
                'Locker',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isFirstTime ? 'Create your secure password' : 'Enter your password to continue',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: _isFirstTime ? 'Create Password' : 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                onSubmitted: _isFirstTime ? null : (value) => _authenticateWithPassword(),
              ),
              const SizedBox(height: 16),

              // Confirm Password Input (only for first time)
              if (_isFirstTime) ...[
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (value) => _createPassword(),
                ),
                const SizedBox(height: 32),
              ] else ...[
                const SizedBox(height: 32),
              ],

              // Primary Action Button
              ElevatedButton(
                onPressed: _isFirstTime ? _createPassword : _authenticateWithPassword,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _isFirstTime ? 'Create Password' : 'Unlock',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // Biometric Authentication Button (only if available and not first time)
              if (!_isFirstTime && _isBiometricAvailable && _isBiometricEnabled) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _authenticateWithBiometrics,
                  icon: Icon(_getBiometricIcon()),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Use $_biometricDisplayName'),
                  ),
                ),
              ],

              // Helper Text
              if (_isFirstTime) ...[
                const SizedBox(height: 24),
                Text(
                  'Your password will be securely encrypted and stored locally on your device.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],

              // Debug buttons (only in debug mode)
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _testBiometricAvailability,
                        child: const Text('Test Biometric'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetBiometricAuth,
                        child: const Text('Reset Biometric'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else {
      return Icons.security;
    }
  }

  void _testBiometricAvailability() async {
    final isAvailable = await _authService.isBiometricAvailable();
    final isEnabled = await _authService.isBiometricEnabled();
    final biometrics = await _authService.getAvailableBiometrics();
    final displayName = _authService.getBiometricDisplayName(biometrics);

    final message = '''
Biometric Availability Test
============================

Is Biometric Available: $isAvailable
Is Biometric Enabled: $isEnabled
Available Biometrics: ${biometrics.join(', ')}
Biometric Display Name: $displayName
    ''';

    ToastUtils.showToast(message);
  }

  void _resetBiometricAuth() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Biometric Authentication'),
        content: const Text(
          'This will reset your biometric authentication settings. You will need to set it up again if you want to use biometric login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _authService.resetBiometricAuth();
      if (success) {
        ToastUtils.showToast('Biometric authentication reset successfully');
        await _checkBiometricState();
      } else {
        ToastUtils.showToast('Failed to reset biometric authentication');
      }
    }
  }
}