import 'package:equatable/equatable.dart';

class DonationModel extends Equatable {
  final String id;
  final String donorId;
  final String caseId;
  final String? caseName;
  final double amount;
  final DateTime timestamp;
  final String paymentMethod;
  final String transactionId;
  final String status;

  const DonationModel({
    required this.id,
    required this.donorId,
    required this.caseId,
    this.caseName,
    required this.amount,
    required this.timestamp,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String,
      donorId: json['donorId'] as String,
      caseId: json['caseId'] as String,
      caseName: json['caseName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'caseId': caseId,
      'caseName': caseName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
    };
  }

  DonationModel copyWith({
    String? id,
    String? donorId,
    String? caseId,
    String? caseName,
    double? amount,
    DateTime? timestamp,
    String? paymentMethod,
    String? transactionId,
    String? status,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      caseId: caseId ?? this.caseId,
      caseName: caseName ?? this.caseName,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        donorId,
        caseId,
        caseName,
        amount,
        timestamp,
        paymentMethod,
        transactionId,
        status,
      ];
}