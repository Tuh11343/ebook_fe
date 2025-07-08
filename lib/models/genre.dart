import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Genre extends Equatable {
  final String genreId;
  final String name;
  final String? description;

  const Genre({
    required this.genreId,
    required this.name,
    this.description,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genreId: json['genreId'] as String? ?? json['genre_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genreId': genreId.isEmpty ? const Uuid().v4() : genreId,
      'name': name,
      'description': description,
    };
  }

  Genre copyWith({
    String? genreId,
    String? name,
    String? description,
  }) {
    return Genre(
      genreId: genreId ?? this.genreId,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [genreId, name, description];
}