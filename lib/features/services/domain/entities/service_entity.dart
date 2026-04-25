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
