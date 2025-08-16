import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final UserRole selectedRole;

  const LoginScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _cnicController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getRoleTitle() {
    switch (widget.selectedRole) {
      case UserRole.imam:
        return 'Imam Login';
      case UserRole.donor:
        return 'Donor Login';
      case UserRole.beneficiary:
        return 'Beneficiary Login';
    }
  }

  Color _getRoleColor() {
    switch (widget.selectedRole) {
      case UserRole.imam:
        return AppTheme.primaryColor;
      case UserRole.donor:
        return AppTheme.secondaryColor;
      case UserRole.beneficiary:
        return Colors.green;
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.login(
      _cnicController.text,
      _phoneController.text,
      selectedRole: widget.selectedRole,
    );

    if (!mounted) return;

    if (success) {
      // Navigate to appropriate dashboard based on selected role
      switch (widget.selectedRole) {
        case UserRole.imam:
          context.go('/imam/dashboard');
          break;
        case UserRole.donor:
          context.go('/donor/dashboard');
          break;
        case UserRole.beneficiary:
          context.go('/beneficiary/dashboard');
          break;
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Invalid credentials. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        textColor: AppTheme.whiteColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: roleColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: roleColor,
                ),
                const SizedBox(height: 24),
                Text(
                  _getRoleTitle(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your credentials to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // CNIC Field
                TextFormField(
                  controller: _cnicController,
                  decoration: InputDecoration(
                    labelText: 'CNIC Number',
                    hintText: AppConstants.cnicHint,
                    prefixIcon: Icon(Icons.credit_card, color: roleColor),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                    _CnicInputFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your CNIC';
                    }
                    if (!RegExp(AppConstants.cnicPattern).hasMatch(value)) {
                      return 'Please enter a valid CNIC (12345-1234567-1)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: AppConstants.phoneHint,
                    prefixIcon: Icon(Icons.phone, color: roleColor),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    LengthLimitingTextInputFormatter(13),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(AppConstants.phonePattern).hasMatch(value)) {
                      return 'Please enter a valid phone (+923001234567)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: roleColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.whiteColor,
                                ),
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppTheme.greyColor),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/register', extra: {'role': widget.selectedRole});
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Demo Credentials Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorUtils.withOpacity(roleColor, 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorUtils.withOpacity(roleColor, 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Credentials',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CNIC: 42101-1234567-8',
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        'Phone: +923001234567',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
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

class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('-', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 5 || i == 12) {
        buffer.write('-');
      }
      buffer.write(text[i]);
    }
    
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}