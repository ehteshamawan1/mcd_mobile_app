import 'package:equatable/equatable.dart';

class MosqueModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String imamId;
  final String imamName;
  final bool isVerified;
  final DateTime createdAt;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.imamId,
    required this.imamName,
    required this.isVerified,
    required this.createdAt,
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    return MosqueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      imamId: json['imamId'] as String,
      imamName: json['imamName'] as String,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'imamId': imamId,
      'imamName': imamName,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MosqueModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? imamId,
    String? imamName,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return MosqueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      imamId: imamId ?? this.imamId,
      imamName: imamName ?? this.imamName,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        imamId,
        imamName,
        isVerified,
        createdAt,
      ];
}