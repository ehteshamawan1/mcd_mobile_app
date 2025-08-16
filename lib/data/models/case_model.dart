import 'package:equatable/equatable.dart';

enum CaseType { medical, education, emergency, housing, food, other }
enum CaseStatus { pending, active, completed, rejected }

class CaseModel extends Equatable {
  final String id;
  final String beneficiaryName;
  final String beneficiaryId;
  final String title;
  final String description;
  final CaseType type;
  final double targetAmount;
  final double raisedAmount;
  final String location;
  final String mosqueId;
  final String mosqueName;
  final bool isImamVerified;
  final bool isAdminApproved;
  final CaseStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> documentUrls;
  final List<String> imageUrls;

  const CaseModel({
    required this.id,
    required this.beneficiaryName,
    required this.beneficiaryId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetAmount,
    required this.raisedAmount,
    required this.location,
    required this.mosqueId,
    required this.mosqueName,
    required this.isImamVerified,
    required this.isAdminApproved,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.documentUrls = const [],
    this.imageUrls = const [],
  });

  double get progressPercentage => 
      targetAmount > 0 ? (raisedAmount / targetAmount) * 100 : 0;

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id'] as String,
      beneficiaryName: json['beneficiaryName'] as String,
      beneficiaryId: json['beneficiaryId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: CaseType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CaseType.other,
      ),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      raisedAmount: (json['raisedAmount'] as num).toDouble(),
      location: json['location'] as String,
      mosqueId: json['mosqueId'] as String,
      mosqueName: json['mosqueName'] as String,
      isImamVerified: json['isImamVerified'] as bool,
      isAdminApproved: json['isAdminApproved'] as bool,
      status: CaseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CaseStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      documentUrls: (json['documentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beneficiaryName': beneficiaryName,
      'beneficiaryId': beneficiaryId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'targetAmount': targetAmount,
      'raisedAmount': raisedAmount,
      'location': location,
      'mosqueId': mosqueId,
      'mosqueName': mosqueName,
      'isImamVerified': isImamVerified,
      'isAdminApproved': isAdminApproved,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'documentUrls': documentUrls,
      'imageUrls': imageUrls,
    };
  }

  CaseModel copyWith({
    String? id,
    String? beneficiaryName,
    String? beneficiaryId,
    String? title,
    String? description,
    CaseType? type,
    double? targetAmount,
    double? raisedAmount,
    String? location,
    String? mosqueId,
    String? mosqueName,
    bool? isImamVerified,
    bool? isAdminApproved,
    CaseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? documentUrls,
    List<String>? imageUrls,
  }) {
    return CaseModel(
      id: id ?? this.id,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      location: location ?? this.location,
      mosqueId: mosqueId ?? this.mosqueId,
      mosqueName: mosqueName ?? this.mosqueName,
      isImamVerified: isImamVerified ?? this.isImamVerified,
      isAdminApproved: isAdminApproved ?? this.isAdminApproved,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documentUrls: documentUrls ?? this.documentUrls,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  @override
  List<Object?> get props => [
        id,
        beneficiaryName,
        beneficiaryId,
        title,
        description,
        type,
        targetAmount,
        raisedAmount,
        location,
        mosqueId,
        mosqueName,
        isImamVerified,
        isAdminApproved,
        status,
        createdAt,
        updatedAt,
        documentUrls,
        imageUrls,
      ];
}