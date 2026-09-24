class PagedList<T> {
  const PagedList({
    required this.items,
    required this.pageNumber,
    this.pageSize = 10,
    required this.totalPages,
    required this.totalCount,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  final bool hasPreviousPage;
  final bool hasNextPage;

  factory PagedList.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PagedList<T>(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => fromJsonT(item))
          .toList(),
      pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasPreviousPage:
          json['hasPreviousPage'] as bool? ?? json['hasPrevious'] as bool? ?? false,
      hasNextPage:
          json['hasNextPage'] as bool? ?? json['hasNext'] as bool? ?? false,
    );
  }
}
