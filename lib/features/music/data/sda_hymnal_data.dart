import '../sda_hymn_model.dart';
import 'sda_hymns_catalog.dart';

class SdaHymnalData {
  /// Complete collection of all 695 SDA Hymnal songs (1985 edition)
  static List<SdaHymn> get hymns => SdaHymnsCatalog.all695Hymns;

  /// Fast lookup of a hymn by number (1 to 695)
  static SdaHymn? getByNumber(int number) {
    if (number < 1 || number > 695) return null;
    final index = number - 1;
    if (index >= 0 && index < hymns.length && hymns[index].number == number) {
      return hymns[index];
    }
    return hymns.firstWhere(
      (h) => h.number == number,
      orElse: () => hymns.first,
    );
  }
}
