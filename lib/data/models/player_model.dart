import 'package:hive/hive.dart';
import '../../core/utils/overall_utils.dart';

part 'player_model.g.dart';

@HiveType(typeId: 0)
class PlayerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int attack;

  @HiveField(3)
  final int defense;

  @HiveField(4)
  final int stamina;

  @HiveField(5)
  final String position;

  PlayerModel({
    required this.id,
    required this.name,
    required this.attack,
    required this.defense,
    required this.stamina,
    required this.position,
  });

  int get overall => OverallUtils.calculateOverall(
    attack: attack,
    defense: defense,
    stamina: stamina,
  );
}