import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Flutter Chat';
  static const String appVersion = '1.0.0';

  // Add these to AppConstants
  // static const int callTimeoutSeconds = 60; // Call rings for 60 seconds
  // static const bool notifyWhenAppRunningInBackgroundOrQuit = true;

  // Make sure these are correct
  static const int zegoAppID = 1881066074; // Your actual App ID
  static const String zegoAppSign =
      '5cee4c3dac49d85e2f51c416fa4795bcd574827a15ced513c12c7b25da8c065b'; // Your actual App Sign

  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF6584);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5A52FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle bodyTextSecondary = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusCircular = 50.0;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String unknownError = 'Something went wrong. Please try again.';
  static const String emailInvalid = 'Please enter a valid email address.';
  static const String passwordShort =
      'Password must be at least $minPasswordLength characters.';
  static const String fieldsEmpty = 'Please fill in all fields.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account has been created successfully!';
  static const String logoutSuccess = 'You have been logged out successfully!';

  static const String defaultAvatar =
      'https://ui-avatars.com/api/?background=6C63FF&color=fff&name=';

  // Zegocloud Features
  static const bool enableVideoCall = true;
  static const bool enableVoiceCall = true;
  static const bool enableScreenShare = false;
  static const bool enableChat = true;
}

String getUserAvatar(String name) {
  return '${AppConstants.defaultAvatar}${Uri.encodeComponent(name)}';
}

String formatTimeStamp(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return 'Just now';
      }
      return '${difference.inMinutes} min ago';
    }
    return '${difference.inHours} hr ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
