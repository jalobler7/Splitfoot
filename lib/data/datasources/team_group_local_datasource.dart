import 'package:hive/hive.dart';

import '../models/player_model.dart';
import '../models/team_group_model.dart';

const String defaultTeamGroupName = 'Meus atletas';

class TeamGroupValidationException implements Exception {
  final String message;

  const TeamGroupValidationException(this.message);

  @override
  String toString() => message;
}

class TeamGroupLocalDataSource {
  final Box<TeamGroupModel> _groupBox = Hive.box<TeamGroupModel>('team_groups');
  final Box<PlayerModel> _playerBox = Hive.box<PlayerModel>('players');

  List<TeamGroupModel> getAllGroups() {
    final groups = _groupBox.values.toList();
    groups.sort((a, b) {
      final createdCompare = a.createdAt.compareTo(b.createdAt);
      if (createdCompare != 0) return createdCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return groups;
  }

  TeamGroupModel? getGroupById(String id) {
    return _groupBox.get(id);
  }

  bool existsByName(String name, {String? excludeGroupId}) {
    final normalizedName = _normalizeName(name);
    return _groupBox.values.any((group) {
      if (excludeGroupId != null && group.id == excludeGroupId) {
        return false;
      }
      return _normalizeName(group.name) == normalizedName;
    });
  }

  Future<void> addGroup(TeamGroupModel group) async {
    _validateGroup(group);
    await _groupBox.put(group.id, group);
  }

  Future<void> updateGroup(TeamGroupModel group) async {
    _validateGroup(group, excludeGroupId: group.id);
    await _groupBox.put(group.id, group);
  }

  Future<void> deleteGroup(String groupId) async {
    final hasPlayers = _playerBox.values.any(
      (player) => player.teamGroupId == groupId,
    );

    if (hasPlayers) {
      throw const TeamGroupValidationException(
        'Este grupo possui atletas vinculados. Remova ou edite esses atletas antes de excluir o grupo.',
      );
    }

    await _groupBox.delete(groupId);
  }

  int countPlayersForGroup(String groupId) {
    return _playerBox.values.where((player) => player.teamGroupId == groupId).length;
  }

  void _validateGroup(TeamGroupModel group, {String? excludeGroupId}) {
    final trimmedName = group.name.trim();
    if (trimmedName.isEmpty) {
      throw const TeamGroupValidationException('Informe o nome do grupo.');
    }

    if (trimmedName.length < 2) {
      throw const TeamGroupValidationException('Nome do grupo muito curto.');
    }

    if (existsByName(trimmedName, excludeGroupId: excludeGroupId)) {
      throw const TeamGroupValidationException('Ja existe um grupo com este nome.');
    }
  }

  static String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }
}
