
class Shortvoicemodel {
  int id;
  String? filePath;
  double shortValue;
  String? aianalyzereault;
  double? aivoicevolume;
  bool ended;

  DateTime shortstart;
  DateTime shortend;

  Shortvoicemodel(
    {
    required this.id,
    required this.filePath,
    required this.shortValue,
    this.aianalyzereault,
    this.aivoicevolume,
    required this.ended,
    required this.shortstart,
    required this.shortend,
    }
  );
}