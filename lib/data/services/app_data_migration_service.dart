import 'package:hive/hive.dart';

import '../datasources/team_group_local_datasource.dart';
import '../models/player_model.dart';
import '../models/team_group_model.dart';

class AppDataMigrationService {
  final Box<PlayerModel> _playerBox = Hive.box<PlayerModel>('players');
  final Box<TeamGroupModel> _groupBox = Hive.box<TeamGroupModel>('team_groups');

  Future<void> ensureGroupsMigration() async {
    final groups = _groupBox.values.toList();
    final players = _playerBox.values.toList();

    TeamGroupModel? fallbackGroup;
    for (final group in groups) {
      if (group.name.trim().toLowerCase() == defaultTeamGroupName.toLowerCase()) {
        fallbackGroup = group;
        break;
      }
    }

    final hasPlayersWithoutGroup = players.any((player) => player.teamGroupId.trim().isEmpty);

    if (fallbackGroup == null && (players.isNotEmpty || hasPlayersWithoutGroup)) {
      fallbackGroup = TeamGroupModel(
        id: 'default-team-group',
        name: defaultTeamGroupName,
        createdAt: DateTime.now(),
      );
      await _groupBox.put(fallbackGroup.id, fallbackGroup);
    }

    if (fallbackGroup == null) {
      return;
    }

    for (final player in players) {
      if (player.teamGroupId.trim().isNotEmpty) {
        continue;
      }

      await _playerBox.put(
        player.id,
        player.copyWith(teamGroupId: fallbackGroup.id),
      );
    }
  }
}
