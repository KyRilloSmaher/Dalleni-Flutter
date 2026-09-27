class PushNotificationData {
  const PushNotificationData({
    this.notificationId,
    this.type,
    this.entityType,
    this.entityId,
    this.actorId,
    this.title,
    this.body,
  });

  final String? notificationId;
  final String? type;
  final String? entityType;
  final String? entityId;
  final String? actorId;
  final String? title;
  final String? body;

  factory PushNotificationData.fromJson(
    Map<String, dynamic> json, {
    String? title,
    String? body,
  }) {
    return PushNotificationData(
      notificationId: json['notificationId']?.toString(),
      type: json['type']?.toString(),
      entityType: json['entityType']?.toString(),
      entityId: json['entityId']?.toString(),
      actorId: json['actorId']?.toString(),
      title: title ?? json['title']?.toString(),
      body: body ?? json['body']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (notificationId != null) 'notificationId': notificationId,
      if (type != null) 'type': type,
      if (entityType != null) 'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
      if (actorId != null) 'actorId': actorId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
    };
  }

  @override
  String toString() {
    return 'PushNotificationData(notificationId: $notificationId, type: $type, '
        'entityType: $entityType, entityId: $entityId, actorId: $actorId, '
        'title: $title, body: $body)';
  }
}
