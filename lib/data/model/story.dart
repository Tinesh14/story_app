import 'package:json_annotation/json_annotation.dart';

part 'story.g.dart';

@JsonSerializable(explicitToJson: true)
class Story {
  final String? id;
  final String? name;
  final String? description;
  final String? photoUrl;
  final double? lat;
  final double? lon;

  Story({
    this.id,
    this.name,
    this.description,
    this.photoUrl,
    this.lat,
    this.lon,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DetailStory {
  final bool? error;
  final String? message;
  final Story? story;

  DetailStory({
    this.error,
    this.message,
    this.story,
  });

  factory DetailStory.fromJson(Map<String, dynamic> json) =>
      _$DetailStoryFromJson(json);

  Map<String, dynamic> toJson() => _$DetailStoryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ListStory {
  final bool? error;
  final String? message;
  final List<Story>? listStory;

  ListStory({
    this.error,
    this.message,
    this.listStory,
  });

  factory ListStory.fromJson(Map<String, dynamic> json) =>
      _$ListStoryFromJson(json);

  Map<String, dynamic> toJson() => _$ListStoryToJson(this);
}
