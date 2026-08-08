import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';

class FirebaseCommunicationTestingScreen extends StatefulWidget {
  const FirebaseCommunicationTestingScreen({super.key});

  @override
  State<FirebaseCommunicationTestingScreen> createState() =>
      _FirebaseCommunicationTestingScreenState();
}

class _FirebaseCommunicationTestingScreenState
    extends State<FirebaseCommunicationTestingScreen> {
  String _statusMessage = 'Ready to test communication';
  bool _isLoading = false;

  void _handleTestCommunication() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing communication...';
    });

    try {
    await FirebaseFirestore.instance
        .collection('communication_tests')
        .add({
        'status': 'Testing is completed',
        'timestamp': FieldValue.serverTimestamp(),
    });

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Communication test completed successfully!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firebase Communication Test Triggered!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Communication test failed: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Test Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Firebase Communication Testing',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_sync_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Firebase Communication',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.subtextDark,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 240,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleTestCommunication,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.wifi_tethering_rounded, size: 20),
                  label: Text(
                    'Test Communication',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
