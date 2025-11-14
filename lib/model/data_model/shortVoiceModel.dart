
class Shortvoicemodel {
  final int id;
  // DateTime start;
  // DateTime end;
  // Duration totalseconds;
  double shortValue;
  String? aiResult;
  bool ended;

  Shortvoicemodel(
    {
    required this.id,
    // required this.start,
    // required this.end,
    // required this.totalseconds,
    required this.shortValue,
    this.aiResult,
    required this.ended
    }
  );
}