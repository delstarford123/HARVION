class SdaHymn {
  final int number;
  final String title;
  final String category;
  final String keySignature;
  final List<String> stanzas;
  final String chorus;
  final String? audioUrl;

  const SdaHymn({
    required this.number,
    required this.title,
    required this.category,
    this.keySignature = 'G Major',
    required this.stanzas,
    this.chorus = '',
    this.audioUrl,
  });

  String get fullLyrics {
    final buffer = StringBuffer();
    for (int i = 0; i < stanzas.length; i++) {
      buffer.writeln('Stanza ${i + 1}:');
      buffer.writeln(stanzas[i]);
      buffer.writeln();
      if (chorus.isNotEmpty) {
        buffer.writeln('Chorus:');
        buffer.writeln(chorus);
        buffer.writeln();
      }
    }
    return buffer.toString().trim();
  }
}

