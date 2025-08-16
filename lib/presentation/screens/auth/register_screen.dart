import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../presentation/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole selectedRole;
  
  const RegisterScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Role-specific controllers
  final _mosqueNameController = TextEditingController();
  final _mosqueAddressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _familyMembersController = TextEditingController();
  
  String? _selectedCity;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _mosqueNameController.dispose();
    _mosqueAddressController.dispose();
    _occupationController.dispose();
    _monthlyIncomeController.dispose();
    _familyMembersController.dispose();
    super.dispose();
  }

  String _getRoleTitle() {
    switch (widget.selectedRole) {
      case UserRole.imam:
        return 'Imam Registration';
      case UserRole.donor:
        return 'Donor Registration';
      case UserRole.beneficiary:
        return 'Beneficiary Registration';
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

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      Fluttertoast.showToast(
        msg: 'Please agree to terms and conditions',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        textColor: AppTheme.whiteColor,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Create additional info based on role
    Map<String, dynamic>? additionalInfo;
    switch (widget.selectedRole) {
      case UserRole.imam:
        additionalInfo = {
          'mosqueName': _mosqueNameController.text,
          'mosqueAddress': _mosqueAddressController.text,
        };
        break;
      case UserRole.donor:
        additionalInfo = {
          'occupation': _occupationController.text,
          'preferredCategories': [],
        };
        break;
      case UserRole.beneficiary:
        additionalInfo = {
          'monthlyIncome': _monthlyIncomeController.text,
          'familyMembers': _familyMembersController.text,
          'needsVerification': true,
        };
        break;
    }

    final newUser = UserModel(
      id: _uuid.v4(),
      cnic: _cnicController.text,
      phoneNumber: _phoneController.text,
      name: _nameController.text,
      email: _emailController.text,
      location: '$_selectedCity, ${_locationController.text}',
      role: widget.selectedRole,
      isVerified: false,
      additionalInfo: additionalInfo,
      createdAt: DateTime.now(),
    );

    final success = await authProvider.register(newUser);

    if (!mounted) return;

    if (success) {
      context.push('/otp-verification', extra: {'phoneNumber': _phoneController.text});
    } else {
      Fluttertoast.showToast(
        msg: 'Registration failed. Please try again.',
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
        title: Text(
          _getRoleTitle(),
          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.whiteColor,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: ColorUtils.withOpacity(roleColor, 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Basic Information Section
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person, color: roleColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // CNIC
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
                const SizedBox(height: 16),
                
                // Phone Number
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
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email, color: roleColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // City Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city, color: roleColor),
                  ),
                  items: AppConstants.cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Address
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Complete Address',
                    prefixIcon: Icon(Icons.location_on, color: roleColor),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // Role-specific fields
                if (widget.selectedRole == UserRole.imam) ...[
                  Text(
                    'Mosque Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mosqueNameController,
                    decoration: InputDecoration(
                      labelText: 'Mosque Name',
                      prefixIcon: Icon(Icons.mosque, color: roleColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mosque name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mosqueAddressController,
                    decoration: InputDecoration(
                      labelText: 'Mosque Address',
                      prefixIcon: Icon(Icons.location_on, color: roleColor),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mosque address';
                      }
                      return null;
                    },
                  ),
                ] else if (widget.selectedRole == UserRole.donor) ...[
                  Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _occupationController,
                    decoration: InputDecoration(
                      labelText: 'Occupation (Optional)',
                      prefixIcon: Icon(Icons.work, color: roleColor),
                    ),
                  ),
                ] else if (widget.selectedRole == UserRole.beneficiary) ...[
                  Text(
                    'Family Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _familyMembersController,
                    decoration: InputDecoration(
                      labelText: 'Number of Family Members',
                      prefixIcon: Icon(Icons.family_restroom, color: roleColor),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of family members';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _monthlyIncomeController,
                    decoration: InputDecoration(
                      labelText: 'Monthly Income (PKR)',
                      prefixIcon: Icon(Icons.attach_money, color: roleColor),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
                const SizedBox(height: 30),
                
                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: roleColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _agreedToTerms = !_agreedToTerms;
                          });
                        },
                        child: const Text(
                          'I agree to the Terms of Service and Privacy Policy',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegistration,
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
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.whiteColor,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppTheme.greyColor),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/login', extra: {'role': widget.selectedRole});
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
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
    
    for (int i = 0; i < text.length && i < 13; i++) {
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