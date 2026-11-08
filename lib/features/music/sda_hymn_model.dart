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

  factory SdaHymn.fromJson(Map<String, dynamic> json) {
    return SdaHymn(
      number: json['number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      keySignature: json['keySignature'] as String? ?? 'G Major',
      stanzas: (json['stanzas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      chorus: json['chorus'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'category': category,
      'keySignature': keySignature,
      'stanzas': stanzas,
      'chorus': chorus,
      'audioUrl': audioUrl,
    };
  }

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

