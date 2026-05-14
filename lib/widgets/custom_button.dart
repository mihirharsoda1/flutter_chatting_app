// ignore_for_file: deprecated_member_use

import 'package:flutter_chat_app/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isOutlined;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isOutlined = false,
    this.borderRadius = AppConstants.borderRadiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    // Add constraints to prevent infinite width
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width ?? double.infinity,
        minWidth: 0,
      ),
      child: SizedBox(
        width: width,
        height: height ?? 56,
        child: isOutlined ? _buildOutlinedButton() : _buildFilledButton(),
      ),
    );
  }

  Widget _buildFilledButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppConstants.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
        minimumSize: Size(0, height ?? 56),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingSmall,
          horizontal: AppConstants.paddingMedium,
        ),
      ),
      child: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: backgroundColor ?? AppConstants.primaryColor,
        side: BorderSide(
          color: backgroundColor ?? AppConstants.primaryColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        minimumSize: Size(0, height ?? 56),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingSmall,
          horizontal: AppConstants.paddingMedium,
        ),
      ),
      child: isLoading
          ? _buildLoadingIndicator(isOutlined: true)
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildLoadingIndicator({bool isOutlined = false}) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined
              ? (backgroundColor ?? AppConstants.primaryColor)
              : (textColor ?? Colors.white),
        ),
      ),
    );
  }
}
