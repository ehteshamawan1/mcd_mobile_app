import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/donation_model.dart';

class DonationProvider extends ChangeNotifier {
  final List<DonationModel> _donations = [];
  bool _isProcessing = false;
  bool _isLoading = false;
  String _errorMessage = '';
  final _uuid = const Uuid();

  List<DonationModel> get donations => _donations;
  bool get isProcessing => _isProcessing;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<DonationModel> getDonationsByUserId(String userId) {
    return _donations.where((d) => d.donorId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<DonationModel> getDonationsByCaseId(String caseId) {
    return _donations.where((d) => d.caseId == caseId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  double getTotalDonationsByUser(String userId) {
    return _donations
        .where((d) => d.donorId == userId)
        .fold(0, (sum, d) => sum + d.amount);
  }

  double getTotalDonationsForCase(String caseId) {
    return _donations
        .where((d) => d.caseId == caseId)
        .fold(0, (sum, d) => sum + d.amount);
  }

  Future<void> loadDonationHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load mock donations if not already loaded
      if (_donations.isEmpty) {
        loadMockDonations();
      }
    } catch (e) {
      _errorMessage = 'Failed to load donation history: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processDonation({
    required String donorId,
    required String caseId,
    required double amount,
    required String paymentMethod,
  }) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      final donation = DonationModel(
        id: _uuid.v4(),
        donorId: donorId,
        caseId: caseId,
        amount: amount,
        timestamp: DateTime.now(),
        paymentMethod: paymentMethod,
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        status: 'completed',
      );

      _donations.add(donation);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Payment processing failed: $e';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> makeDonation(DonationModel donation, {Function(double)? onDonationSuccess}) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));
      
      _donations.add(donation);
      
      // Call the callback to update case amount if provided
      if (onDonationSuccess != null) {
        onDonationSuccess(donation.amount);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Payment processing failed: $e';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void loadMockDonations() {
    _donations.addAll([
      DonationModel(
        id: 'don_001',
        donorId: 'user_donor_001',
        caseId: 'case_001',
        caseName: 'Medical Emergency - Heart Surgery',
        amount: 5000,
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        paymentMethod: 'JazzCash',
        transactionId: 'TXN1234567890',
        status: 'completed',
      ),
      DonationModel(
        id: 'don_002',
        donorId: 'user_donor_001',
        caseId: 'case_002',
        caseName: 'Education Support for Orphans',
        amount: 2500,
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        paymentMethod: 'EasyPaisa',
        transactionId: 'TXN1234567891',
        status: 'completed',
      ),
      DonationModel(
        id: 'don_003',
        donorId: 'user_donor_002',
        caseId: 'case_001',
        caseName: 'Medical Emergency - Heart Surgery',
        amount: 10000,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        paymentMethod: 'Bank Transfer',
        transactionId: 'TXN1234567892',
        status: 'completed',
      ),
      DonationModel(
        id: 'don_004',
        donorId: 'user_donor_003',
        caseId: 'case_003',
        caseName: 'House Reconstruction After Fire',
        amount: 15000,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        paymentMethod: 'Credit Card',
        transactionId: 'TXN1234567893',
        status: 'completed',
      ),
      DonationModel(
        id: 'don_005',
        donorId: 'user_donor_001',
        caseId: 'case_005',
        caseName: 'Monthly Food Support for Family',
        amount: 7500,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: 'JazzCash',
        transactionId: 'TXN1234567894',
        status: 'completed',
      ),
    ]);
    notifyListeners();
  }

  Map<String, dynamic> getDonationStatistics(String userId) {
    final userDonations = getDonationsByUserId(userId);
    
    return {
      'totalDonations': userDonations.length,
      'totalAmount': getTotalDonationsByUser(userId),
      'averageDonation': userDonations.isEmpty 
          ? 0 
          : getTotalDonationsByUser(userId) / userDonations.length,
      'lastDonationDate': userDonations.isEmpty 
          ? null 
          : userDonations.first.timestamp,
      'preferredPaymentMethod': _getMostUsedPaymentMethod(userId),
    };
  }

  String _getMostUsedPaymentMethod(String userId) {
    final userDonations = getDonationsByUserId(userId);
    if (userDonations.isEmpty) return 'None';
    
    final methodCounts = <String, int>{};
    for (final donation in userDonations) {
      methodCounts[donation.paymentMethod] = 
          (methodCounts[donation.paymentMethod] ?? 0) + 1;
    }
    
    return methodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}