/// Parsed .zshrc file content with freezed
class ZshrcContent {
  const ZshrcContent({required this.content});

  factory ZshrcContent.fromJson(Map<String, Object?> json) {
    return ZshrcContent(
      content: (json['content']! as Map<String, Object?>).map(
        (k, e) => MapEntry(
          k,
          (e! as Map<String, Object?>).map(
            (k, e) => MapEntry(
              int.parse(k),
              e! as String,
            ),
          ),
        ),
      ),
    );
  }

  final Map<String, Map<int, dynamic>> content;

  Map<String, Object?> toJson() {
    return {
      'content': content.map(
        (k, e) => MapEntry(
          k,
          e.map(
            (k, e) => MapEntry(
              k.toString(),
              e,
            ),
          ),
        ),
      ),
    };
  }
}
