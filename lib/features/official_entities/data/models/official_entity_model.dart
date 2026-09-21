import '../../domain/entities/official_entity.dart';

class OfficialEntityModel extends OfficialEntity {
  const OfficialEntityModel({
    required super.id,
    super.name,
    super.description,
    super.logoUrl,
    super.websiteUrl,
    super.isVerified = false,
    super.servicesCount = 0,
  });

  factory OfficialEntityModel.fromJson(Map<String, dynamic> json) {
    return OfficialEntityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      servicesCount: (json['servicesCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'isVerified': isVerified,
      'servicesCount': servicesCount,
    };
  }
}
