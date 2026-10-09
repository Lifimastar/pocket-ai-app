class NoteModel {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Sin titulo',
      content: json['content'] as String? ?? '',
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'summary': summary};
  }
}
