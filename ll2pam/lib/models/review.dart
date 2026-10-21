class ReviewModel {
  final String id;
  final String name;
  final String time;
  final int rating;
  final String avatarUrl;
  final String content;
  final bool isMine;

  const ReviewModel({
    required this.id,
    required this.name,
    required this.time,
    required this.rating,
    required this.avatarUrl,
    required this.content,
    this.isMine = false,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final authorName = (json['author'] ?? json['name'] ?? '') as String;
    final timeLabel = (json['createdAtLabel'] ?? json['time'] ?? '') as String;
    final textContent = (json['text'] ?? json['content'] ?? '') as String;

    return ReviewModel(
      id: json['id'] as String? ?? '',
      name: authorName,
      time: timeLabel,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      content: textContent,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'time': time,
    'rating': rating,
    'avatarUrl': avatarUrl,
    'content': content,
    'isMine': isMine,
  };
}
