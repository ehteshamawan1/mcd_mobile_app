import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/donation_model.dart';
import '../../providers/case_provider.dart';
import '../../providers/donation_provider.dart';
import '../../providers/auth_provider.dart';

class DonationScreen extends StatefulWidget {
  final String caseId;

  const DonationScreen({
    super.key,
    required this.caseId,
  });

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  CaseModel? caseDetails;
  bool isLoading = true;
  bool isProcessing = false;
  String? selectedPaymentMethod;
  double? selectedAmount;

  final List<double> presetAmounts = [500, 1000, 2500, 5000, 10000];
  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 'jazzcash', 'name': 'JazzCash', 'icon': Icons.phone_android},
    {'id': 'easypaisa', 'name': 'EasyPaisa', 'icon': Icons.phone_android},
    {'id': 'bank', 'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
  ];

  @override
  void initState() {
    super.initState();
    _loadCaseDetails();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCaseDetails() async {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final details = await caseProvider.getCaseById(widget.caseId);
    
    if (mounted) {
      setState(() {
        caseDetails = details;
        isLoading = false;
      });
    }
  }

  Future<void> _processDonation() async {
    if (_formKey.currentState!.validate() && selectedPaymentMethod != null) {
      setState(() {
        isProcessing = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final donationProvider = Provider.of<DonationProvider>(context, listen: false);
      final caseProvider = Provider.of<CaseProvider>(context, listen: false);
      
      final amount = selectedAmount ?? double.tryParse(_amountController.text) ?? 0;
      
      final donation = DonationModel(
        id: 'donation_${DateTime.now().millisecondsSinceEpoch}',
        donorId: authProvider.user?.id ?? 'anonymous',
        caseId: widget.caseId,
        amount: amount,
        timestamp: DateTime.now(),
        paymentMethod: selectedPaymentMethod!,
        transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        status: 'completed',
      );

      final success = await donationProvider.makeDonation(
        donation,
        onDonationSuccess: (donationAmount) {
          // Update the case's raised amount
          caseProvider.updateCaseRaisedAmount(widget.caseId, donationAmount);
        },
      );

      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        if (success) {
          _showSuccessDialog();
        } else {
          _showErrorDialog();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select amount and payment method'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorUtils.withOpacity(Colors.green, 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Donation Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you for your generous donation of PKR ${selectedAmount ?? _amountController.text}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.greyColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Donation Failed'),
        content: const Text('Something went wrong. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Make Donation'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (caseDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Make Donation'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
        ),
        body: const Center(
          child: Text('Case not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Donation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Case Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: ColorUtils.withOpacity(AppTheme.primaryColor, 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseDetails!.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beneficiary: ${caseDetails!.beneficiaryName}',
                      style: const TextStyle(
                        color: AppTheme.greyColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remaining: PKR ${(caseDetails!.targetAmount - caseDetails!.raisedAmount).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount Selection
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Preset amounts
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: presetAmounts.map((amount) {
                        final isSelected = selectedAmount == amount;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedAmount = amount;
                              _amountController.text = amount.toStringAsFixed(0);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.whiteColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              'PKR ${amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.whiteColor
                                    : AppTheme.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Custom amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter custom amount',
                        prefixText: 'PKR ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedAmount = double.tryParse(value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Payment Method
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...paymentMethods.map((method) {
                      final isSelected = selectedPaymentMethod == method['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedPaymentMethod = method['id'];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.whiteColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method['icon'],
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.greyColor,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    method['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.blackColor,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // Donate Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _processDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
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
                          'Donate Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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