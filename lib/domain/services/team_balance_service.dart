import '../../data/models/player_model.dart';
import '../entities/team_result.dart';
import 'position_weight_service.dart';
import '../../core/enums/sport_type.dart';

class TeamBalanceService {
  final PositionWeightService _weightService = PositionWeightService();

  TeamResult balanceByOverall({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
  }) {
    List<PlayerModel>? bestTeamA;
    double bestDifference = double.infinity;

    final combinations = _combine(players, teamASize);

    for (final teamA in combinations) {
      final teamB = players.where((p) => !teamA.contains(p)).toList();

      final diff =
      (_average(teamA) - _average(teamB)).abs();

      if (diff < bestDifference) {
        bestDifference = diff;
        bestTeamA = teamA;
      }
    }

    final finalTeamA = bestTeamA!;
    final finalTeamB =
    players.where((p) => !finalTeamA.contains(p)).toList();

    return TeamResult(teamA: finalTeamA, teamB: finalTeamB);
  }

  TeamResult balanceByAttributes({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
  }) {
    List<PlayerModel>? bestTeamA;
    int bestScore = 1 << 30;

    final combinations = _combine(players, teamASize);

    for (final teamA in combinations) {
      final teamB = players.where((p) => !teamA.contains(p)).toList();

      final score =
          (_sumAttack(teamA) - _sumAttack(teamB)).abs() +
              (_sumDefense(teamA) - _sumDefense(teamB)).abs() +
              (_sumStamina(teamA) - _sumStamina(teamB)).abs();

      if (score < bestScore) {
        bestScore = score;
        bestTeamA = teamA;
      }
    }

    final finalTeamA = bestTeamA!;
    final finalTeamB =
    players.where((p) => !finalTeamA.contains(p)).toList();

    return TeamResult(teamA: finalTeamA, teamB: finalTeamB);
  }

  TeamResult balanceByPosition({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    required SportType sport,
  }) {
    List<PlayerModel>? bestTeamA;
    double bestDifference = double.infinity;

    final combinations = _combine(players, teamASize);

    for (final teamA in combinations) {
      final teamB = players.where((p) => !teamA.contains(p)).toList();

      final scoreA = _teamScore(teamA, sport);
      final scoreB = _teamScore(teamB, sport);

      final diff = (scoreA - scoreB).abs();

      if (diff < bestDifference) {
        bestDifference = diff;
        bestTeamA = teamA;
      }
    }

    final finalTeamA = bestTeamA!;
    final finalTeamB =
    players.where((p) => !finalTeamA.contains(p)).toList();

    return TeamResult(teamA: finalTeamA, teamB: finalTeamB);
  }

  double _teamScore(List<PlayerModel> players, SportType sport) {
    double total = 0;

    for (final player in players) {
      final w = _weightService.getWeight(sport, player.position);

      total += (player.attack * w.attack) +
          (player.defense * w.defense) +
          (player.stamina * w.stamina);
    }

    return total;
  }

  double _average(List<PlayerModel> players) {
    final total = players.fold<int>(0, (s, p) => s + p.overall);
    return total / players.length;
  }

  int _sumAttack(List<PlayerModel> players) =>
      players.fold(0, (s, p) => s + p.attack);

  int _sumDefense(List<PlayerModel> players) =>
      players.fold(0, (s, p) => s + p.defense);

  int _sumStamina(List<PlayerModel> players) =>
      players.fold(0, (s, p) => s + p.stamina);

  List<List<PlayerModel>> _combine(List<PlayerModel> players, int size) {
    final result = <List<PlayerModel>>[];
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
      result.add(List.from(current));
      return;
    }

    for (int i = start; i < players.length; i++) {
      current.add(players[i]);
      _combineRecursive(players, size, i + 1, current, result);
      current.removeLast();
    }
  }
}