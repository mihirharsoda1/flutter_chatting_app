// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/auth/login_screen.dart';
import 'package:flutter_chat_app/screens/home/home_screen.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/utils/constants.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthState();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.8, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<bool> _initializeZego(String userId, String userName) async {
    try {
      await ZIMKit().connectUser(id: userId, name: userName);
      // Note: ZIMKit does not expose enableNotifications()
      // Notification configuration should be handled via the
      // appropriate ZIM/ZIMKit APIs elsewhere if needed.

      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: AppConstants.zegoAppID,
        appSign: AppConstants.zegoAppSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
      print('Zego initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing Zego: $e');
      return false;
    }
  }

  Future<void> _checkAuthState() async {
    // Show splash for at least 2 seconds
    await Future.delayed(Duration(milliseconds: 2000));

    if (!mounted) return;

    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      try {
        final userData = await _authService.getCurrentUserData();
        if (userData != null && mounted) {
          await _authService.updateUserOnlineStatus(userData.uid, true);
          // Initialize Zego in background without awaiting
          await _initializeZego(userData.uid, userData.name);

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        } else {
          _navigateToLogin();
        }
      } catch (e) {
        print('Error getting user data: $e');
        _navigateToLogin();
      }
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppConstants.primaryColor,
                        size: 60,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Connect, Chat & Call",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 48),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
