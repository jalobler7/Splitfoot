import 'package:hive/hive.dart';

part 'team_group_model.g.dart';

@HiveType(typeId: 1)
class TeamGroupModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  TeamGroupModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  TeamGroupModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return TeamGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
