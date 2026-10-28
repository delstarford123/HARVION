import 'quote_model.dart';

class QuoteRepository {
  // Your massive list of 100 quotes! (I added 3 as an example, you can add the rest)
  static final List<DailyQuote> _offlineQuotes = [
    DailyQuote(
      id: 'q1',
      text: 'The Lord is my shepherd; I shall not want.',
      reference: 'Psalm 23:1',
      displayDate: DateTime.now(),
    ),
    DailyQuote(
      id: 'q2',
      text: 'I can do all things through Christ which strengtheneth me.',
      reference: 'Philippians 4:13',
      displayDate: DateTime.now(),
    ),
    DailyQuote(
      id: 'q3',
      text: 'For God so loved the world, that he gave his only begotten Son...',
      reference: 'John 3:16',
      displayDate: DateTime.now(),
    ),
    // ... ADD YOUR 97 OTHER QUOTES HERE ...
  ];

  // The Magic Algorithm: Automatically changes the quote every 24 hours
  static DailyQuote getTodaysQuote() {
    // 1. Get the current day of the year (1 through 365)
    final int dayOfYear = int.parse(
        "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}");

    // 2. Use modulo math to pick a quote.
    // If you have 100 quotes, this ensures the index is always between 0 and 99.
    final int quoteIndex = dayOfYear % _offlineQuotes.length;

    return _offlineQuotes[quoteIndex];
  }
}
