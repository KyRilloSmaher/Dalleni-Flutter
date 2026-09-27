String formatUtc(DateTime dateTime) {
  final utc = dateTime.toUtc();

  String twoDigits(int value) => value.toString().padLeft(2, '0');
  String threeDigits(int value) => value.toString().padLeft(3, '0');

  return '${utc.year}-'
      '${twoDigits(utc.month)}-'
      '${twoDigits(utc.day)} '
      '${twoDigits(utc.hour)}:'
      '${twoDigits(utc.minute)}:'
      '${twoDigits(utc.second)}.'
      '${threeDigits(utc.millisecond)} UTC';
}