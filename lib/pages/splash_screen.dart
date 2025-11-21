import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resume_builder/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller; // For main animations
  late AnimationController _dotsController; // For dots animation
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  late Animation<Color?> _colorStart;
  late Animation<Color?> _colorMiddle;
  late Animation<Color?> _colorEnd;

  final ColorTween _gradientStart = ColorTween(
    begin: const Color(0xff5f56ee),
    end: const Color(0xff9b8fff),
  );
  final ColorTween _gradientMiddle = ColorTween(
    begin: const Color(0xffe4d8fd),
    end: const Color(0xffb0a1ff),
  );
  final ColorTween _gradientEnd = ColorTween(
    begin: const Color(0xff9b8fff),
    end: const Color(0xff5f56ee),
  );

  @override
  void initState() {
    super.initState();

    // Initialize main animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorStart = _gradientStart.animate(_controller);
    _colorMiddle = _gradientMiddle.animate(_controller);
    _colorEnd = _gradientEnd.animate(_controller);

    // Initialize dots animation controller for infinite repeat
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _handlePermissions();
  }

  Future<void> _handlePermissions() async {
    final results = await Future.wait([
      Permission.storage.request(),
      Future.delayed(const Duration(seconds: 4)),
    ]);

    final status = results[0] as PermissionStatus;
    if (!mounted) return;

    if (status.isGranted) {
      _navigateToHome();
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    } else {
      _showSettingsDialog();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This app needs storage access to save and manage your resumes. Please grant the permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
              _handlePermissions();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotsController.dispose();
    super.dispose();
  }


  Widget _animatedLoadingDots() {
    return SpinKitSpinningLines(color: Colors.white, size: 50.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorStart.value ?? const Color(0xff5f56ee),
                  _colorMiddle.value ?? const Color(0xffe4d8fd),
                  _colorEnd.value ?? const Color(0xff9b8fff),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Image.asset(
                          'images/app_logo.png',
                          width: screenWidth * 0.4,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Resume Builder',
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1.5,
                        shadows: const [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Build a Resume That Gets You Hired Faster',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        shadows: const [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),  
                  ),
                  const SizedBox(height: 40),
                  _animatedLoadingDots(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
