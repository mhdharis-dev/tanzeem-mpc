import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/madrasa_model.dart';
import 'url_launcher_helper.dart';

class WhatsAppHelper {
  /// Opens a WhatsApp chat to [phone] with an optional pre-filled message
  static Future<void> openWhatsAppChat({
    required BuildContext context,
    required String phone,
    String? message,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid phone number for WhatsApp.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    // Ensure phone number starts with country code if not present (defaulting to India +91 if 10 digits)
    String formattedPhone = cleanPhone;
    if (!formattedPhone.startsWith('+')) {
      if (formattedPhone.length == 10) {
        formattedPhone = '+91$formattedPhone';
      }
    }

    final encodedMsg = Uri.encodeComponent(message ?? 'Assalamu Alaikum! Greetings from Tanzeem Team.');
    final String urlString = 'https://wa.me/$formattedPhone?text=$encodedMsg';

    try {
      UrlLauncherHelper.launchExternalUrl(urlString);
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      if (context.mounted) {
        _fallbackWhatsAppMessage(context, formattedPhone, urlString);
      }
    }
  }

  static void _fallbackWhatsAppMessage(BuildContext context, String phone, String urlString) {
    Clipboard.setData(ClipboardData(text: urlString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('WhatsApp link copied to clipboard for $phone! Paste in browser/WhatsApp.'),
        backgroundColor: const Color(0xFF25D366),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Sends automated Tanzeem Welcome Registration Message for new Madrasa
  static Future<void> sendMadrasaRegistrationWelcomeMsg({
    required BuildContext context,
    required MadrasaModel madrasa,
  }) async {
    final String msg = '''
🌿 *السلام عليكم ورحمة الله*

Dear *${madrasa.coordinatorName}*,

Welcome to **Tanzeem – Smart Meelad Program Management**.

We are delighted to have you as the *Program Coordinator* for *${madrasa.madrasaName}*.

*Tanzeem* is designed to simplify the planning, scheduling, and management of Meelad programs, making event coordination faster, more organized, and more efficient.

━━━━━━━━━━━━━━━━━━━━━━

🔐 *Your Login Credentials*

📧 Email:
${madrasa.email}

🔑 Password:
${madrasa.password}

🌐 Login:
https://tanzeem-mpc.vercel.app/

━━━━━━━━━━━━━━━━━━━━━━

If you experience any issues logging in or require assistance, please contact the Tanzeem support team.

May Allah (ﷻ) accept your efforts and grant success to your Meelad programs.

*جَزَاكُمُ اللَّهُ خَيْرًا*

— *Team Tanzeem*
''';

    await openWhatsAppChat(
      context: context,
      phone: madrasa.coordinatorPhone,
      message: msg,
    );
  }
}
