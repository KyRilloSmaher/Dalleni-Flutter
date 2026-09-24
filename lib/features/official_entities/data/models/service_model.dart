import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    super.name,
    super.description,
    super.requiredDocuments,
    super.fees,
    super.category,
    super.categoryId,
    super.isAvailable = true,
    super.officialEntityId,
    super.officialEntityName,
    super.isOfficialEntityVerified = false,
    super.createdAt,
    super.updatedAt,
    super.averageRating = 0.0,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      description: json['description'] as String?,
      requiredDocuments: json['requiredDocuments'] as String?,
      fees: (json['fees'] as num?)?.toDouble(),
      category: json['category'] as String?,
      categoryId: json['categoryId']?.toString(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      officialEntityId: json['officialEntityId']?.toString(),
      officialEntityName: json['officialEntityName'] as String?,
      isOfficialEntityVerified:
          json['isOfficialEntityVerified'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'requiredDocuments': requiredDocuments,
      'fees': fees,
      'category': category,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'officialEntityId': officialEntityId,
      'officialEntityName': officialEntityName,
      'isOfficialEntityVerified': isOfficialEntityVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'averageRating': averageRating,
    };
  }
}