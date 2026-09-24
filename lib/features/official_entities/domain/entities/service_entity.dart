typedef Service = ServiceEntity;

class ServiceEntity {
  const ServiceEntity({
    required this.id,
    this.name,
    this.description,
    this.requiredDocuments,
    this.fees,
    this.category,
    this.categoryId,
    this.isAvailable = true,
    this.officialEntityId,
    this.officialEntityName,
    this.isOfficialEntityVerified = false,
    this.createdAt,
    this.updatedAt,
    this.averageRating = 0.0,
  });

  final String id;
  final String? name;
  final String? description;
  final String? requiredDocuments;
  final double? fees;
  final String? category;
  final String? categoryId;
  final bool isAvailable;
  final String? officialEntityId;
  final String? officialEntityName;
  final bool isOfficialEntityVerified;
  final String? createdAt;
  final String? updatedAt;
  final double averageRating;
}

class ServiceCategory {
  const ServiceCategory({
    this.id,
    this.name,
    this.description,
    this.iconPath,
    this.imagePath,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? iconPath;
  final String? imagePath;
}

class QuickAccessItem {
  const QuickAccessItem({this.id, this.title, this.subtitle, this.iconPath});

  final String? id;
  final String? title;
  final String? subtitle;
  final String? iconPath;
}

class FeaturedCategory {
  const FeaturedCategory({this.id, this.title, this.tags, this.imagePath});

  final String? id;
  final String? title;
  final List<String>? tags;
  final String? imagePath;
}