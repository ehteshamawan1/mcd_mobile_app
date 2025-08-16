import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/case_model.dart';
import '../../../presentation/providers/case_provider.dart';
import '../../../presentation/providers/auth_provider.dart';

class BeneficiaryVerificationScreen extends StatefulWidget {
  const BeneficiaryVerificationScreen({super.key});

  @override
  State<BeneficiaryVerificationScreen> createState() => 
      _BeneficiaryVerificationScreenState();
}

class _BeneficiaryVerificationScreenState 
    extends State<BeneficiaryVerificationScreen> {
  final List<Map<String, dynamic>> _pendingVerifications = [
    {
      'id': '1',
      'name': 'Ahmad Ali',
      'cnic': '42101-1234567-8',
      'phone': '+923001234567',
      'location': 'Karachi',
      'familyMembers': 5,
      'monthlyIncome': 'PKR 25,000',
      'requestDate': DateTime.now().subtract(const Duration(days: 2)),
      'documents': ['CNIC Copy', 'Income Certificate', 'Utility Bills'],
      'needDescription': 'Medical treatment for chronic illness',
    },
    {
      'id': '2',
      'name': 'Fatima Bibi',
      'cnic': '42101-9876543-2',
      'phone': '+923009876543',
      'location': 'Lahore',
      'familyMembers': 7,
      'monthlyIncome': 'PKR 15,000',
      'requestDate': DateTime.now().subtract(const Duration(days: 5)),
      'documents': ['CNIC Copy', 'Death Certificate', 'School Fee Vouchers'],
      'needDescription': 'Educational expenses for orphaned children',
    },
    {
      'id': '3',
      'name': 'Muhammad Hassan',
      'cnic': '42101-5555555-5',
      'phone': '+923005555555',
      'location': 'Islamabad',
      'familyMembers': 4,
      'monthlyIncome': 'PKR 30,000',
      'requestDate': DateTime.now().subtract(const Duration(days: 1)),
      'documents': ['CNIC Copy', 'Medical Reports'],
      'needDescription': 'Emergency surgery expenses',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        title: const Text(
          'Verify Beneficiary Cases',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _pendingVerifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending verifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All beneficiaries are verified',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingVerifications.length,
              itemBuilder: (context, index) {
                final beneficiary = _pendingVerifications[index];
                final daysSince = DateTime.now()
                    .difference(beneficiary['requestDate'] as DateTime)
                    .inDays;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.all(16),
                    childrenPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: ColorUtils.withOpacity(
                        AppTheme.primaryColor,
                        0.1,
                      ),
                      child: Text(
                        beneficiary['name'].split(' ').map((n) => n[0]).join(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      beneficiary['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'CNIC: ${beneficiary['cnic']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$daysSince days ago',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorUtils.withOpacity(
                            AppTheme.primaryColor,
                            0.05,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Phone',
                              beneficiary['phone'],
                              Icons.phone,
                            ),
                            _buildDetailRow(
                              'Location',
                              beneficiary['location'],
                              Icons.location_on,
                            ),
                            _buildDetailRow(
                              'Family Members',
                              '${beneficiary['familyMembers']}',
                              Icons.family_restroom,
                            ),
                            _buildDetailRow(
                              'Monthly Income',
                              beneficiary['monthlyIncome'],
                              Icons.attach_money,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Need Description:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              beneficiary['needDescription'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.greyColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Submitted Documents:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (beneficiary['documents'] as List)
                                  .map((doc) => Chip(
                                        label: Text(
                                          doc,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: AppTheme.whiteColor,
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Verification Checklist:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildChecklistItem('CNIC verified'),
                            _buildChecklistItem('Phone number verified'),
                            _buildChecklistItem('Address verified'),
                            _buildChecklistItem('Need assessment complete'),
                            _buildChecklistItem('Documents reviewed'),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _rejectVerification(
                                      beneficiary['id'],
                                      beneficiary['name'],
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppTheme.errorColor,
                                    ),
                                    label: const Text(
                                      'Reject',
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppTheme.errorColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _approveVerification(
                                      beneficiary['id'],
                                      beneficiary['name'],
                                    ),
                                    icon: const Icon(
                                      Icons.check,
                                      color: AppTheme.whiteColor,
                                    ),
                                    label: const Text(
                                      'Approve',
                                      style: TextStyle(
                                        color: AppTheme.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.greyColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_box_outline_blank,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            item,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _approveVerification(String id, String name) {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Find the beneficiary data
    final beneficiary = _pendingVerifications.firstWhere((b) => b['id'] == id);
    
    // Create a new case from the verified beneficiary
    final newCase = CaseModel(
      id: 'case_${DateTime.now().millisecondsSinceEpoch}',
      beneficiaryName: beneficiary['name'],
      beneficiaryId: beneficiary['id'],
      title: beneficiary['needDescription'].toString().substring(0, 
          beneficiary['needDescription'].toString().length > 50 ? 50 : beneficiary['needDescription'].toString().length),
      description: beneficiary['needDescription'],
      type: _getCaseTypeFromNeed(beneficiary['needType'] ?? 'other'),
      targetAmount: double.tryParse(beneficiary['requestedAmount'] ?? '50000') ?? 50000,
      raisedAmount: 0,
      location: beneficiary['location'] ?? 'Unknown',
      mosqueId: authProvider.user?.additionalInfo?['mosqueId'] ?? 'mosque_001',
      mosqueName: authProvider.user?.additionalInfo?['mosqueName'] ?? 'Unknown Mosque',
      isImamVerified: true,
      isAdminApproved: false,
      status: CaseStatus.pending,
      createdAt: DateTime.now(),
      documentUrls: (beneficiary['documents'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrls: [],
    );
    
    // Add the case to the provider
    caseProvider.addCase(newCase);
    
    setState(() {
      _pendingVerifications.removeWhere((b) => b['id'] == id);
    });
    
    Fluttertoast.showToast(
      msg: '$name has been verified and case created successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successColor,
      textColor: AppTheme.whiteColor,
    );
  }
  
  CaseType _getCaseTypeFromNeed(String needType) {
    switch (needType.toLowerCase()) {
      case 'medical':
        return CaseType.medical;
      case 'education':
        return CaseType.education;
      case 'emergency':
        return CaseType.emergency;
      case 'housing':
        return CaseType.housing;
      case 'food':
        return CaseType.food;
      default:
        return CaseType.other;
    }
  }

  void _rejectVerification(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject $name\'s verification?'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Optional',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pendingVerifications.removeWhere((b) => b['id'] == id);
              });
              Navigator.pop(context);
              
              Fluttertoast.showToast(
                msg: '$name\'s verification has been rejected',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: AppTheme.errorColor,
                textColor: AppTheme.whiteColor,
              );
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}