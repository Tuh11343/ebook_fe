import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Author extends Equatable {
  final String authorId;
  final String name;
  final String? bio;
  final String? avatarUrl;

  const Author({
    required this.authorId,
    required this.name,
    this.bio,
    this.avatarUrl,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      authorId: json['authorId'] as String? ?? json['author_id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId.isEmpty ? const Uuid().v4() : authorId,
      'name': name,
      'bio': bio,
      'avatarUrl': avatarUrl,
    };
  }

  Author copyWith({
    String? authorId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) {
    return Author(
      authorId: authorId ?? this.authorId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [authorId, name, bio, avatarUrl];
}