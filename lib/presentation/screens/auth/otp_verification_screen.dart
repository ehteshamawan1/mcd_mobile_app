import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter OTP sent to $phoneNumber'),
            const SizedBox(height: 20),
            const Text('Enter any 4 digits'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/donor/dashboard');
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}