import 'package:hive/hive.dart';
import '../models/player_model.dart';

class PlayerValidationException implements Exception {
  final String message;

  const PlayerValidationException(this.message);

  @override
  String toString() => message;
}

class PlayerLocalDataSource {
  final Box<PlayerModel> _box = Hive.box<PlayerModel>('players');

  List<PlayerModel> getAllPlayers() {
    return _box.values.toList();
  }

  static bool isValidSkill(int value) {
    return value >= 0 && value <= 99;
  }

  bool isNameUnique(
    String name,
    String sport,
    String teamGroupId, {
    String? excludePlayerId,
  }) {
    final normalizedName = _normalizeName(name);
    final normalizedSport = _normalizeSport(sport);
    final normalizedGroupId = _normalizeGroupId(teamGroupId);

    return _box.values.every((player) {
      if (excludePlayerId != null && player.id == excludePlayerId) {
        return true;
      }

      final sameSport = _normalizeSport(player.sport) == normalizedSport;
      final sameName = _normalizeName(player.name) == normalizedName;
      final sameGroup =
          _normalizeGroupId(player.teamGroupId) == normalizedGroupId;
      return !(sameSport && sameName && sameGroup);
    });
  }

  Future<void> addPlayer(PlayerModel player) async {
    _validatePlayer(player);
    await _box.put(player.id, player);
  }

  Future<void> updatePlayer(PlayerModel player) async {
    _validatePlayer(player, excludePlayerId: player.id);
    await _box.put(player.id, player);
  }

  Future<void> deletePlayer(String id) async {
    await _box.delete(id);
  }

  void _validatePlayer(PlayerModel player, {String? excludePlayerId}) {
    _validateSkill(player.attack, 'Ataque');
    _validateSkill(player.defense, 'Defesa');
    _validateSkill(player.stamina, 'Folego');

    if (player.teamGroupId.trim().isEmpty) {
      throw const PlayerValidationException(
        'Selecione um grupo para o atleta.',
      );
    }

    if (!isNameUnique(
      player.name,
      player.sport,
      player.teamGroupId,
      excludePlayerId: excludePlayerId,
    )) {
      throw const PlayerValidationException(
        'Ja existe um jogador com este nome neste esporte e grupo.',
      );
    }
  }

  void _validateSkill(int value, String label) {
    if (!isValidSkill(value)) {
      throw PlayerValidationException(
        '$label deve estar entre 0 e 99.',
      );
    }
  }

  static String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }

  static String _normalizeSport(String value) {
    return value.trim().toLowerCase();
  }

  static String _normalizeGroupId(String value) {
    return value.trim().toLowerCase();
  }
}
