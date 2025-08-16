import 'package:equatable/equatable.dart';

enum UserRole { imam, donor, beneficiary }

class UserModel extends Equatable {
  final String id;
  final String cnic;
  final String phoneNumber;
  final String name;
  final String email;
  final String location;
  final UserRole role;
  final bool isVerified;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.cnic,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.location,
    required this.role,
    required this.isVerified,
    this.additionalInfo,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      cnic: json['cnic'] as String,
      phoneNumber: json['phoneNumber'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      location: json['location'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.donor,
      ),
      isVerified: json['isVerified'] as bool,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnic': cnic,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'location': location,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? cnic,
    String? phoneNumber,
    String? name,
    String? email,
    String? location,
    UserRole? role,
    bool? isVerified,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      cnic: cnic ?? this.cnic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      location: location ?? this.location,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cnic,
        phoneNumber,
        name,
        email,
        location,
        role,
        isVerified,
        additionalInfo,
        createdAt,
      ];
}