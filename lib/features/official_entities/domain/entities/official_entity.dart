typedef OfficialEntity = OfficialEntityEntity;

class OfficialEntityEntity {
  const OfficialEntityEntity({
    required this.id,
    this.name,
    this.description,
    this.logoUrl,
    this.websiteUrl,
    this.isVerified = false,
    this.servicesCount = 0,
  });

  final String id;
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? websiteUrl;
  final bool isVerified;
  final int servicesCount;
}
