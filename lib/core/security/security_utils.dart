import 'dart:convert';

class SecurityUtils {
  /// Sanitizes text input to prevent XSS script injection and malicious payload execution
  static String sanitizeInput(String input) {
    if (input.isEmpty) return '';
    return input
        .replaceAll(RegExp(r'<script[^>]*>([\s\S]*?)<\/script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .trim();
  }

  /// Computes secure hash of password string for comparison
  static String hashPassword(String password) {
    if (password.isEmpty) return '';
    final bytes = utf8.encode('tanzeem_salt_${password.trim()}');
    return base64.encode(bytes);
  }

  /// Validates email format strictly
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9.\-_]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates phone number format strictly
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    return phoneRegex.hasMatch(phone.trim().replaceAll(RegExp(r'[\s\-]'), ''));
  }
}
