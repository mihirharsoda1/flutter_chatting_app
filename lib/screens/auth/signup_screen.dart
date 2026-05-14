// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/auth/login_screen.dart';
import 'package:flutter_chat_app/screens/home/home_screen.dart';
import 'package:flutter_chat_app/services/auth_service.dart';
import 'package:flutter_chat_app/utils/constants.dart';
import 'package:flutter_chat_app/widgets/custom_button.dart';
import 'package:flutter_chat_app/widgets/custom_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final userModel = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      if (userModel != null) {
        try {
          // Try to connect with timeout
          await ZIMKit().connectUser(id: userModel.uid, name: userModel.name);

          await ZegoUIKitPrebuiltCallInvitationService().init(
            appID: AppConstants.zegoAppID,
            appSign: AppConstants.zegoAppSign,
            userID: userModel.uid,
            userName: userModel.name,
            plugins: [ZegoUIKitSignalingPlugin()],
          );
        } catch (zegoError) {
          print('Zego initialization error: $zegoError');
          // Continue even if Zego fails - app still works for chat
        }

        Fluttertoast.showToast(
          msg: AppConstants.signupSuccess,
          backgroundColor: AppConstants.secondaryColor,
        );
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: AppConstants.accentColor,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 50,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Sign up to get started",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Name',
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            validator: TextFieldValidators.name,
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: TextFieldValidators.email,
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: TextFieldValidators.password,
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            validator: (value) =>
                                TextFieldValidators.confirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                          ),
                          SizedBox(height: 24),
                          CustomButton(
                            text: "Sign Up",
                            onPressed: _signUp,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToLogin,
                                child: Text(
                                  "Log In",
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
                      ),
                      child: Text(
                        "By signing up, you agree to our Terms of Service and Privacy Policy.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
