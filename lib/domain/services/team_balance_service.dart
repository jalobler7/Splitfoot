import '../../core/enums/sport_type.dart';
import '../../data/models/player_model.dart';
import '../entities/team_result.dart';
import 'position_weight_service.dart';

class TeamBalanceService {
  final PositionWeightService _weightService = PositionWeightService();

  List<TeamResult> balanceTopByOverall({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    int limit = 5,
  }) {
    if (players.length != teamASize + teamBSize) {
      throw Exception('Quantidade de jogadores inválida para os times');
    }

    final results = <TeamResult>[];
    final seenKeys = <String>{};

    final combinations = _combine(players, teamASize);

    for (final teamA in combinations) {
      final teamB = players.where((player) => !teamA.contains(player)).toList();

      if (teamB.length != teamBSize) {
        continue;
      }

      final averageA = _averageOverall(teamA);
      final averageB = _averageOverall(teamB);
      final difference = (averageA - averageB).abs();

      final result = TeamResult(
        teamA: List<PlayerModel>.from(teamA),
        teamB: List<PlayerModel>.from(teamB),
        score: difference,
        scoreLabel: 'Diferença de overall médio',
      );

      if (seenKeys.add(result.canonicalKey)) {
        results.add(result);
      }
    }

    results.sort((a, b) {
      final scoreCompare = a.score.compareTo(b.score);
      if (scoreCompare != 0) return scoreCompare;

      final overallCompare =
      a.overallDifference.compareTo(b.overallDifference);
      if (overallCompare != 0) return overallCompare;

      return a.teamA
          .map((player) => player.name)
          .join('|')
          .compareTo(b.teamA.map((player) => player.name).join('|'));
    });

    return results.take(limit).toList();
  }

  List<TeamResult> balanceTopByAttributes({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    int limit = 5,
  }) {
    if (players.length != teamASize + teamBSize) {
      throw Exception('Quantidade de jogadores inválida para os times');
    }

    final results = <TeamResult>[];
    final seenKeys = <String>{};

    final combinations = _combine(players, teamASize);

    for (final teamA in combinations) {
      final teamB = players.where((player) => !teamA.contains(player)).toList();

      if (teamB.length != teamBSize) {
        continue;
      }

      final attackDiff = (_sumAttack(teamA) - _sumAttack(teamB)).abs();
      final defenseDiff = (_sumDefense(teamA) - _sumDefense(teamB)).abs();
      final staminaDiff = (_sumStamina(teamA) - _sumStamina(teamB)).abs();

      final score = attackDiff + defenseDiff + staminaDiff;

      final result = TeamResult(
        teamA: List<PlayerModel>.from(teamA),
        teamB: List<PlayerModel>.from(teamB),
        score: score,
        scoreLabel: 'Diferença total de atributos',
      );

      if (seenKeys.add(result.canonicalKey)) {
        results.add(result);
      }
    }

    results.sort((a, b) {
      final scoreCompare = a.score.compareTo(b.score);
      if (scoreCompare != 0) return scoreCompare;

      final overallCompare =
      a.overallDifference.compareTo(b.overallDifference);
      if (overallCompare != 0) return overallCompare;

      return a.teamA
          .map((player) => player.name)
          .join('|')
          .compareTo(b.teamA.map((player) => player.name).join('|'));
    });

    return results.take(limit).toList();
  }

  List<TeamResult> balanceTopByPosition({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    required SportType sport,
    int limit = 5,
  }) {
    if (players.length != teamASize + teamBSize) {
      throw Exception('Quantidade de jogadores inválida para os times');
    }

    final results = <TeamResult>[];
    final seenKeys = <String>{};

    final combinations = _combine(players, teamASize);

    for (final teamA in combinations) {
      final teamB = players.where((player) => !teamA.contains(player)).toList();

      if (teamB.length != teamBSize) {
        continue;
      }

      final scoreA = _teamScore(teamA, sport);
      final scoreB = _teamScore(teamB, sport);
      final difference = (scoreA - scoreB).abs();

      final result = TeamResult(
        teamA: List<PlayerModel>.from(teamA),
        teamB: List<PlayerModel>.from(teamB),
        score: difference,
        scoreLabel: 'Diferença ponderada por posição',
      );

      if (seenKeys.add(result.canonicalKey)) {
        results.add(result);
      }
    }

    results.sort((a, b) {
      final scoreCompare = a.score.compareTo(b.score);
      if (scoreCompare != 0) return scoreCompare;

      final overallCompare =
      a.overallDifference.compareTo(b.overallDifference);
      if (overallCompare != 0) return overallCompare;

      return a.teamA
          .map((player) => player.name)
          .join('|')
          .compareTo(b.teamA.map((player) => player.name).join('|'));
    });

    return results.take(limit).toList();
  }

  double _teamScore(List<PlayerModel> players, SportType sport) {
    double total = 0;

    for (final player in players) {
      final weight = _weightService.getWeight(sport, player.position);

      total += (player.attack * weight.attack) +
          (player.defense * weight.defense) +
          (player.stamina * weight.stamina);
    }

    return total;
  }

  double _averageOverall(List<PlayerModel> players) {
    if (players.isEmpty) return 0;

    final total = players.fold<int>(
      0,
          (sum, player) => sum + player.overall,
    );

    return total / players.length;
  }

  int _sumAttack(List<PlayerModel> players) {
    return players.fold<int>(0, (sum, player) => sum + player.attack);
  }

  int _sumDefense(List<PlayerModel> players) {
    return players.fold<int>(0, (sum, player) => sum + player.defense);
  }

  int _sumStamina(List<PlayerModel> players) {
    return players.fold<int>(0, (sum, player) => sum + player.stamina);
  }

  List<List<PlayerModel>> _combine(List<PlayerModel> players, int size) {
    final List<List<PlayerModel>> result = [];
    _combineRecursive(players, size, 0, [], result);
    return result;
  }

  void _combineRecursive(
      List<PlayerModel> players,
      int size,
      int start,
      List<PlayerModel> current,
      List<List<PlayerModel>> result,
      ) {
    if (current.length == size) {
      result.add(List<PlayerModel>.from(current));
      return;
    }

    for (int i = start; i < players.length; i++) {
      current.add(players[i]);
      _combineRecursive(players, size, i + 1, current, result);
      current.removeLast();
    }
  }
}