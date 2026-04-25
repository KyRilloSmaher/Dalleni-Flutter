import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  static Map<String, dynamic> decodePayload(String token) {
    final segments = token.split('.');
    if (segments.length != 3) {
      return <String, dynamic>{};
    }

    final normalized = base64Url.normalize(segments[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return json.decode(payload) as Map<String, dynamic>;
  }

  static DateTime? extractExpiry(String token) {
    final payload = decodePayload(token);
    final exp = payload['exp'];
    if (exp is! num) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  }

  static String? extractUserId(String token) {
    final payload = decodePayload(token);
    return payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
        as String?;
  }
}
