import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

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
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String cnic, String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication - accept specific test credentials
      if (cnic == '42101-1234567-8' && phoneNumber == '+923001234567') {
        _user = UserModel(
          id: 'user_001',
          cnic: cnic,
          phoneNumber: phoneNumber,
          name: 'Ahmed Ali',
          email: 'ahmed.ali@example.com',
          location: 'Karachi',
          role: UserRole.imam,
          isVerified: true,
          additionalInfo: {
            'mosqueName': 'Masjid Al-Noor',
            'mosqueAddress': 'Block 5, Gulshan-e-Iqbal',
          },
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
      
      // Check if it's a donor login
      if (cnic.startsWith('42101') && phoneNumber.startsWith('+9230')) {
        _user = UserModel(
          id: 'user_donor_001',
          cnic: cnic,
          phoneNumber: phoneNumber,
          name: 'Sara Khan',
          email: 'sara.khan@example.com',
          location: 'Lahore',
          role: UserRole.donor,
          isVerified: true,
          createdAt: DateTime.now(),
        );
        _isAuthenticated = true;
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
      
      // Check if it's a beneficiary login
      if (cnic.startsWith('42102') && phoneNumber.startsWith('+9231')) {
        _user = UserModel(
          id: 'user_ben_001',
          cnic: cnic,
          phoneNumber: phoneNumber,
          name: 'Fatima Ahmed',
          email: 'fatima.ahmed@example.com',
          location: 'Islamabad',
          role: UserRole.beneficiary,
          isVerified: false,
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
        await prefs.setString(AppConstants.userStorageKey, _user!.toJson().toString());
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
}