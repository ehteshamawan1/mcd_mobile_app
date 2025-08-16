class AppConstants {
  // App Info
  static const String appName = 'Muslim Charity Donation';
  static const String appVersion = '1.0.0';
  
  // API Base URL (Mock Server)
  static const String baseUrl = 'http://localhost:3001/api';
  
  // Storage Keys
  static const String userStorageKey = 'user_data';
  static const String tokenStorageKey = 'auth_token';
  static const String roleStorageKey = 'user_role';
  
  // CNIC Format
  static const String cnicPattern = r'^\d{5}-\d{7}-\d{1}$';
  static const String cnicHint = '12345-1234567-1';
  
  // Phone Format
  static const String phonePattern = r'^\+92[0-9]{10}$';
  static const String phoneHint = '+923001234567';
  
  // Mock OTP
  static const String mockOtp = '1234';
  
  // Pakistani Cities
  static const List<String> cities = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
    'Peshawar',
    'Quetta',
    'Sialkot',
    'Gujranwala',
  ];
  
  // Case Types Labels
  static const Map<String, String> caseTypeLabels = {
    'medical': 'Medical',
    'education': 'Education',
    'emergency': 'Emergency',
    'housing': 'Housing',
    'food': 'Food',
    'other': 'Other',
  };
  
  // Case Status Labels
  static const Map<String, String> caseStatusLabels = {
    'pending': 'Pending',
    'active': 'Active',
    'completed': 'Completed',
    'rejected': 'Rejected',
  };
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'JazzCash',
    'EasyPaisa',
    'Bank Transfer',
    'Credit Card',
    'Debit Card',
  ];
  
  // Quick Donation Amounts
  static const List<double> quickDonationAmounts = [
    500,
    1000,
    2500,
    5000,
    10000,
    25000,
    50000,
  ];
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // Padding and Margins
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Border Radius
  static const double defaultRadius = 8.0;
  static const double largeRadius = 12.0;
  static const double circularRadius = 100.0;
}