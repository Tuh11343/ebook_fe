import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class PremiumPlan extends Equatable {
  final String planId;
  final String name;
  final String? description;
  final double price;
  final int durationDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PremiumPlan({
    required this.planId,
    required this.name,
    this.description,
    required this.price,
    required this.durationDays,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PremiumPlan.fromJson(Map<String, dynamic> json) {
    return PremiumPlan(
      planId: json['planId'] as String? ?? json['plan_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(), // 'price' đã là camelCase
      durationDays: json['durationDays'] as int? ?? json['duration_days'] as int,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId.isEmpty ? const Uuid().v4() : planId,
      'name': name,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PremiumPlan copyWith({
    String? planId,
    String? name,
    String? description,
    double? price,
    int? durationDays,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PremiumPlan(
      planId: planId ?? this.planId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    planId,
    name,
    description,
    price,
    durationDays,
    isActive,
    createdAt,
    updatedAt,
  ];
}