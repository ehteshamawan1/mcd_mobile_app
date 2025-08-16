import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/user_model.dart';

class RegisterScreen extends StatelessWidget {
  final UserRole selectedRole;
  
  const RegisterScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Register as ${selectedRole.toString().split('.').last}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.push('/otp-verification', extra: {'phoneNumber': '+923001234567'});
              },
              child: const Text('Continue to OTP'),
            ),
          ],
        ),
      ),
    );
  }
}