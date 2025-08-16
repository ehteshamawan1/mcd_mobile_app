import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/case_model.dart';
import '../../providers/case_provider.dart';

class ImamCaseDetailsScreen extends StatefulWidget {
  final String caseId;

  const ImamCaseDetailsScreen({
    super.key,
    required this.caseId,
  });

  @override
  State<ImamCaseDetailsScreen> createState() => _ImamCaseDetailsScreenState();
}

class _ImamCaseDetailsScreenState extends State<ImamCaseDetailsScreen> {
  CaseModel? caseDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCaseDetails();
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

  Future<void> _approveCase() async {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await caseProvider.updateCase(
      caseDetails!.copyWith(
        isImamVerified: true,
        status: CaseStatus.active,
      ),
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _rejectCase() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Case'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Enter reason...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'Rejected by Imam'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null) {
      final caseProvider = Provider.of<CaseProvider>(context, listen: false);
      
      final success = await caseProvider.updateCase(
        caseDetails!.copyWith(
          status: CaseStatus.rejected,
        ),
      );

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case rejected'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Case Details'),
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
          title: const Text('Case Details'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
        ),
        body: const Center(
          child: Text('Case not found'),
        ),
      );
    }

    final progress = (caseDetails!.raisedAmount / caseDetails!.targetAmount) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
        actions: [
          if (caseDetails!.status == CaseStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/imam/edit-case/${caseDetails!.id}');
              },
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            if (caseDetails!.status != CaseStatus.active)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: _getStatusColor(caseDetails!.status),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(caseDetails!.status),
                      color: AppTheme.whiteColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(caseDetails!.status),
                      style: const TextStyle(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Case Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    ColorUtils.withOpacity(AppTheme.primaryColor, 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(caseDetails!.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      caseDetails!.type.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    caseDetails!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppTheme.whiteColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        caseDetails!.beneficiaryName,
                        style: const TextStyle(
                          color: AppTheme.whiteColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorUtils.withOpacity(Colors.black, 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PKR ${caseDetails!.raisedAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const Text(
                            'Raised so far',
                            style: TextStyle(
                              color: AppTheme.greyColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PKR ${caseDetails!.targetAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Target',
                            style: TextStyle(
                              color: AppTheme.greyColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 100 ? Colors.green : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.toStringAsFixed(1)}% completed',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Description Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorUtils.withOpacity(Colors.black, 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Case Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    caseDetails!.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.greyColor,
                    ),
                  ),
                ],
              ),
            ),

            // Verification Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorUtils.withOpacity(Colors.black, 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verification Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        caseDetails!.isImamVerified ? Icons.check_circle : Icons.pending,
                        color: caseDetails!.isImamVerified ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        caseDetails!.isImamVerified 
                            ? 'Verified by Imam' 
                            : 'Pending Imam Verification',
                        style: TextStyle(
                          fontSize: 16,
                          color: caseDetails!.isImamVerified ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        caseDetails!.isAdminApproved ? Icons.check_circle : Icons.pending,
                        color: caseDetails!.isAdminApproved ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        caseDetails!.isAdminApproved 
                            ? 'Approved by Admin' 
                            : 'Pending Admin Approval',
                        style: TextStyle(
                          fontSize: 16,
                          color: caseDetails!.isAdminApproved ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons for Pending Cases
            if (caseDetails!.status == CaseStatus.pending && !caseDetails!.isImamVerified)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _rejectCase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _approveCase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Approve',
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
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(CaseType type) {
    switch (type) {
      case CaseType.medical:
        return Colors.red;
      case CaseType.education:
        return Colors.blue;
      case CaseType.emergency:
        return Colors.orange;
      case CaseType.housing:
        return Colors.green;
      case CaseType.food:
        return Colors.brown;
      case CaseType.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Colors.orange;
      case CaseStatus.active:
        return Colors.green;
      case CaseStatus.completed:
        return Colors.blue;
      case CaseStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return Icons.pending;
      case CaseStatus.active:
        return Icons.check_circle;
      case CaseStatus.completed:
        return Icons.done_all;
      case CaseStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusText(CaseStatus status) {
    switch (status) {
      case CaseStatus.pending:
        return 'Pending Verification';
      case CaseStatus.active:
        return 'Active Case';
      case CaseStatus.completed:
        return 'Case Completed';
      case CaseStatus.rejected:
        return 'Case Rejected';
    }
  }
}