import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userStorageKey);
      
      if (userData != null && userData.isNotEmpty) {
        // Parse user data from storage
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        _user = UserModel.fromJson(userMap);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
      // Clear corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userStorageKey);
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String cnic, String phoneNumber, {UserRole? selectedRole}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // For mock authentication, accept any valid CNIC format and phone number
      // and create user based on selected role
      if (_isValidCnic(cnic) && _isValidPhone(phoneNumber)) {
        final role = selectedRole ?? UserRole.donor;
        
        // Generate user based on role
        Map<String, dynamic>? additionalInfo;
        String name = '';
        
        switch (role) {
          case UserRole.imam:
            name = 'Ahmed Ali';
            additionalInfo = {
              'mosqueName': 'Masjid Al-Noor',
              'mosqueAddress': 'Block 5, Gulshan-e-Iqbal',
            };
            break;
          case UserRole.donor:
            name = 'Sara Khan';
            break;
          case UserRole.beneficiary:
            name = 'Fatima Ahmed';
            additionalInfo = {
              'familySize': 5,
              'monthlyIncome': 25000,
            };
            break;
        }
        
        _user = UserModel(
          id: 'user_${role.toString().split('.').last}_${DateTime.now().millisecondsSinceEpoch}',
          cnic: cnic,
          phoneNumber: phoneNumber,
          name: name,
          email: '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
          location: 'Karachi',
          role: role,
          isVerified: true,
          additionalInfo: additionalInfo,
          createdAt: DateTime.now(),
        );
        
        _isAuthenticated = true;
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(UserModel newUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      _user = newUser;
      _isAuthenticated = false; // Need OTP verification
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock OTP verification - accept any 4 digit code
      if (otp.length == 4) {
        _isAuthenticated = true;
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userStorageKey);
      await prefs.remove(AppConstants.tokenStorageKey);
      
      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        // Properly encode user data as JSON string
        final userJson = jsonEncode(_user!.toJson());
        await prefs.setString(AppConstants.userStorageKey, userJson);
        await prefs.setString(AppConstants.roleStorageKey, _user!.role.toString());
      }
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    _saveUserToStorage();
    notifyListeners();
  }

  bool _isValidCnic(String cnic) {
    // Basic CNIC format validation: 12345-1234567-1
    final regex = RegExp(r'^\d{5}-\d{7}-\d$');
    return regex.hasMatch(cnic);
  }

  bool _isValidPhone(String phone) {
    // Pakistani phone number format: +92XXXXXXXXXX
    final regex = RegExp(r'^\+92\d{10}$');
    return regex.hasMatch(phone);
  }
}