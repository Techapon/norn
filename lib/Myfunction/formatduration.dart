
String formatDuration(Duration duration) {
  // 1) แสดงเป็น day
  if (duration.inHours >= 24) {
    int days = duration.inDays;
    return "$days day";
  }

  // 2) แสดงเป็น hours
  if (duration.inHours >= 1) {
    int hours = duration.inHours;
    return "$hours hours";
  }

  // 3) แสดงผลเป็น mm:ss (น้อยกว่า 1 ชม.)
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds % 60;

  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');

  return "$mm:$ss minute";
}
