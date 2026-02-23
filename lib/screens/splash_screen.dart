import 'dart:io';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    _initApp();
  }

  Future<void> _initApp() async {
    // Wait for minimum splash time
    await Future.delayed(const Duration(seconds: 3));
    _checkConnectivityAndLogin();
  }

  Future<void> _checkConnectivityAndLogin() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // Internet is available, now check app config
        final config = await ApiService.getAppConfig();
        
        if (config['is_maintenance'] == true) {
          _showMaintenanceDialog();
          return;
        }

        final latestVersion = config['latest_version'] ?? ApiService.appVersion;
        final updateUrl = config['update_url'] ?? '';

        if (latestVersion != ApiService.appVersion) {
          _showUpdateDialog(latestVersion, updateUrl);
          return;
        }

        // Everything okay, check login
        _checkLoginStatus();
      }
    } on SocketException catch (_) {
      // No internet
      _showNoInternetDialog();
    } catch (e) {
      // Fallback if config fails
      _checkLoginStatus();
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.engineering_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Sedang Perbaikan'),
          ],
        ),
        content: const Text('Aplikasi sedang dalam pemeliharaan rutin untuk meningkatkan layanan. Mohon tunggu beberapa saat.'),
        actions: [
          TextButton(
            onPressed: () => _checkConnectivityAndLogin(),
            child: const Text('CEK LAGI', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.system_update_rounded, color: AppTheme.primaryBlue),
            SizedBox(width: 10),
            Text('Update Tersedia'),
          ],
        ),
        content: Text('Versi baru ($version) sudah tersedia. Silakan perbarui aplikasi Anda untuk terus menggunakan layanan.'),
        actions: [
          TextButton(
            onPressed: () {
              // Usually launch URL here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Buka: $url')),
              );
            },
            child: const Text('UPDATE SEKARANG', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Tidak Ada Koneksi'),
          ],
        ),
        content: const Text('Aplikasi membutuhkan koneksi internet untuk dapat berjalan. Pastikan internet Anda aktif dan coba lagi.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivityAndLogin(); // Try again
            },
            child: const Text('COBA LAGI', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    final token = await ApiService.getToken();
    
    if (token != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const AppLogo(),
              const SizedBox(height: 24),
              const Text(
                'MYTECHPUS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Digital Writing & Reading Platform',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
