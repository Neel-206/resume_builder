import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resume_builder/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handlePermissions();
  }

  Future<void> _handlePermissions() async {
    final results = await Future.wait([
      Permission.storage.request(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    final status = results[0] as PermissionStatus;

    if (!mounted) return;

    if (status.isGranted) {
      // Permission granted, navigate to home page
      _navigateToHome();
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show a dialog to open settings
      _showSettingsDialog();
    } else {
      // Permission denied, you can show a rationale and retry
      // For simplicity, we'll just show the settings dialog here as well
      _showSettingsDialog();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'This app needs storage access to save and manage your resumes. Please grant the permission in app settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              // Open app settings
              await openAppSettings();
              // For simplicity, we'll just exit. A better approach would be to re-check
              // the permission status after the user returns from settings.
              Navigator.of(context).pop();
              _handlePermissions(); // Re-check permission after returning from settings
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5f56ee), Color(0xffe4d8fd), Color(0xff9b8fff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/app_logo.png',
                width: screenWidth * 0.4,
                height: 100,
              ),
              // const SizedBox(height: 20),
              // Text(
              //   'Resume Builder',
              //   style: GoogleFonts.poppins(
              //     textStyle: TextStyle(
              //       color: Colors.white,
              //       fontSize: screenWidth * 0.07,
              //       fontWeight: FontWeight.bold,
              //       letterSpacing: 1.2,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
