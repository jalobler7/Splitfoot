import 'dart:math';

import '../../core/enums/sport_type.dart';
import '../../core/enums/balance_mode.dart';
import '../../data/models/player_model.dart';
import '../entities/team_result.dart';
import '../entities/match_generation_request.dart';

class TeamBalanceService {
  static const int _exactSearchCombinationLimit = 50000;
  static const int _heuristicCandidateCount = 32;

  List<TeamResult> generate(MatchGenerationRequest request, {int limit = 5}) {
    switch (request.balanceMode) {
      case BalanceMode.overallAverage:
        return balanceTopByOverall(
          players: request.players,
          teamASize: request.teamASize,
          teamBSize: request.teamBSize,
          limit: limit,
        );
      case BalanceMode.attributes:
        return balanceTopByAttributes(
          players: request.players,
          teamASize: request.teamASize,
          teamBSize: request.teamBSize,
          limit: limit,
        );
      case BalanceMode.positions:
        return balanceTopByPosition(
          players: request.players,
          teamASize: request.teamASize,
          teamBSize: request.teamBSize,
          sport: request.sport,
          limit: limit,
        );
    }
  }

  List<TeamResult> balanceTopByOverall({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    int limit = 5,
  }) {
    _validateTeamSizes(
      players: players,
      teamASize: teamASize,
      teamBSize: teamBSize,
    );

    if (_combinationCountExceedsLimit(players.length, teamASize)) {
      return _generateHeuristicResults(
        players: players,
        teamASize: teamASize,
        teamBSize: teamBSize,
        limit: limit,
        scoreLabel: 'Overall m\u00E9dio',
        calculateScore: (teamA, teamB) =>
            (_averageOverall(teamA) - _averageOverall(teamB)).abs(),
      );
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
        scoreLabel: 'Overall m\u00E9dio',
      );

      if (seenKeys.add(result.canonicalKey)) {
        results.add(result);
      }
    }

    _sortResults(results);
    return results.take(limit).toList();
  }

  List<TeamResult> balanceTopByAttributes({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    int limit = 5,
  }) {
    _validateTeamSizes(
      players: players,
      teamASize: teamASize,
      teamBSize: teamBSize,
    );

    if (_combinationCountExceedsLimit(players.length, teamASize)) {
      return _generateHeuristicResults(
        players: players,
        teamASize: teamASize,
        teamBSize: teamBSize,
        limit: limit,
        scoreLabel: 'Atributos',
        calculateScore: (teamA, teamB) =>
            (_sumAttack(teamA) - _sumAttack(teamB)).abs() +
            (_sumDefense(teamA) - _sumDefense(teamB)).abs() +
            (_sumStamina(teamA) - _sumStamina(teamB)).abs(),
      );
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
        scoreLabel: 'Atributos',
      );

      if (seenKeys.add(result.canonicalKey)) {
        results.add(result);
      }
    }

    _sortResults(results);
    return results.take(limit).toList();
  }

  List<TeamResult> balanceTopByPosition({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    required SportType sport,
    int limit = 5,
  }) {
    final _ = sport;

    _validateTeamSizes(
      players: players,
      teamASize: teamASize,
      teamBSize: teamBSize,
    );

    final playersByPosition = _groupPlayersByPosition(players);
    final teamACountByPosition = _calculateTeamACountByPosition(
      playersByPosition: playersByPosition,
      teamASize: teamASize,
      totalPlayers: players.length,
    );

    if (_positionCombinationCountExceedsLimit(
      playersByPosition: playersByPosition,
      teamACountByPosition: teamACountByPosition,
    )) {
      return _generateHeuristicResults(
        players: players,
        teamASize: teamASize,
        teamBSize: teamBSize,
        limit: limit,
        scoreLabel: 'Posi\u00E7\u00F5es',
        preservePositions: true,
        calculateScore: (teamA, teamB) =>
            (_sumOverall(teamA) - _sumOverall(teamB)).abs(),
      );
    }

    final validTeamACombinations = _generateValidTeamACombinations(
      playersByPosition: playersByPosition,
      teamACountByPosition: teamACountByPosition,
    );

    final results = <TeamResult>[];
    final seenKeys = <String>{};

    for (final teamA in validTeamACombinations) {
      final teamAIds = teamA.map((player) => player.id).toSet();
      final teamB = players
          .where((player) => !teamAIds.contains(player.id))
          .toList();

      if (teamA.length != teamASize || teamB.length != teamBSize) {
        continue;
      }

      if (!_matchesPositionDistribution(teamA, teamACountByPosition)) {
        continue;
      }

      final overallDifference = (_sumOverall(teamA) - _sumOverall(teamB)).abs();

      final result = TeamResult(
        teamA: List<PlayerModel>.from(teamA),
        teamB: List<PlayerModel>.from(teamB),
        score: overallDifference,
        scoreLabel: 'Posi\u00E7\u00F5es',
      );

      if (seenKeys.add(result.canonicalKey)) {
        results.add(result);
      }
    }

    _sortResults(results);
    return results.take(limit).toList();
  }

  bool _combinationCountExceedsLimit(int playerCount, int teamASize) {
    return _combinationCount(playerCount, teamASize) >
        BigInt.from(_exactSearchCombinationLimit);
  }

  bool _positionCombinationCountExceedsLimit({
    required Map<String, List<PlayerModel>> playersByPosition,
    required Map<String, int> teamACountByPosition,
  }) {
    var total = BigInt.one;
    final limit = BigInt.from(_exactSearchCombinationLimit);

    for (final entry in playersByPosition.entries) {
      total *= _combinationCount(
        entry.value.length,
        teamACountByPosition[entry.key] ?? 0,
      );
      if (total > limit) return true;
    }

    return false;
  }

  BigInt _combinationCount(int total, int selected) {
    final count = min(selected, total - selected);
    if (count < 0) return BigInt.zero;

    var result = BigInt.one;
    for (var index = 1; index <= count; index++) {
      result =
          result * BigInt.from(total - count + index) ~/ BigInt.from(index);
    }
    return result;
  }

  List<TeamResult> _generateHeuristicResults({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
    required int limit,
    required String scoreLabel,
    required num Function(List<PlayerModel> teamA, List<PlayerModel> teamB)
    calculateScore,
    bool preservePositions = false,
  }) {
    final results = <TeamResult>[];
    final seenKeys = <String>{};

    for (
      var candidateIndex = 0;
      candidateIndex < _heuristicCandidateCount;
      candidateIndex++
    ) {
      final teamA = _buildHeuristicTeamA(
        players: players,
        teamASize: teamASize,
        preservePositions: preservePositions,
        seed: _candidateSeed(players, candidateIndex),
      );
      final teamB = _playersOutsideTeam(players, teamA);

      _improveHeuristicCandidate(
        teamA: teamA,
        teamB: teamB,
        calculateScore: calculateScore,
        preservePositions: preservePositions,
      );

      if (teamA.length != teamASize || teamB.length != teamBSize) continue;

      final result = TeamResult(
        teamA: List<PlayerModel>.from(teamA),
        teamB: List<PlayerModel>.from(teamB),
        score: calculateScore(teamA, teamB),
        scoreLabel: scoreLabel,
      );

      if (seenKeys.add(result.canonicalKey)) results.add(result);
    }

    _sortResults(results);
    return results.take(limit).toList();
  }

  List<PlayerModel> _buildHeuristicTeamA({
    required List<PlayerModel> players,
    required int teamASize,
    required bool preservePositions,
    required int seed,
  }) {
    if (!preservePositions) {
      final shuffled = List<PlayerModel>.from(players)..shuffle(Random(seed));
      return shuffled.take(teamASize).toList();
    }

    final playersByPosition = _groupPlayersByPosition(players);
    final teamACountByPosition = _calculateTeamACountByPosition(
      playersByPosition: playersByPosition,
      teamASize: teamASize,
      totalPlayers: players.length,
    );
    final teamA = <PlayerModel>[];
    final positions = playersByPosition.keys.toList()..sort();

    for (var index = 0; index < positions.length; index++) {
      final position = positions[index];
      final positionPlayers = List<PlayerModel>.from(
        playersByPosition[position]!,
      )..shuffle(Random(seed + index + 1));
      teamA.addAll(positionPlayers.take(teamACountByPosition[position] ?? 0));
    }

    return teamA;
  }

  List<PlayerModel> _playersOutsideTeam(
    List<PlayerModel> players,
    List<PlayerModel> team,
  ) {
    final teamIds = team.map((player) => player.id).toSet();
    return players.where((player) => !teamIds.contains(player.id)).toList();
  }

  void _improveHeuristicCandidate({
    required List<PlayerModel> teamA,
    required List<PlayerModel> teamB,
    required num Function(List<PlayerModel> teamA, List<PlayerModel> teamB)
    calculateScore,
    required bool preservePositions,
  }) {
    var hasImprovement = true;
    var iterations = 0;

    while (hasImprovement && iterations < 64) {
      hasImprovement = false;
      iterations++;
      var bestScore = calculateScore(teamA, teamB);
      int? bestTeamAIndex;
      int? bestTeamBIndex;

      for (var teamAIndex = 0; teamAIndex < teamA.length; teamAIndex++) {
        for (var teamBIndex = 0; teamBIndex < teamB.length; teamBIndex++) {
          if (preservePositions &&
              teamA[teamAIndex].position != teamB[teamBIndex].position) {
            continue;
          }

          final playerA = teamA[teamAIndex];
          final playerB = teamB[teamBIndex];
          teamA[teamAIndex] = playerB;
          teamB[teamBIndex] = playerA;
          final score = calculateScore(teamA, teamB);
          teamA[teamAIndex] = playerA;
          teamB[teamBIndex] = playerB;

          if (score < bestScore) {
            bestScore = score;
            bestTeamAIndex = teamAIndex;
            bestTeamBIndex = teamBIndex;
          }
        }
      }

      if (bestTeamAIndex != null && bestTeamBIndex != null) {
        final playerA = teamA[bestTeamAIndex];
        teamA[bestTeamAIndex] = teamB[bestTeamBIndex];
        teamB[bestTeamBIndex] = playerA;
        hasImprovement = true;
      }
    }
  }

  int _candidateSeed(List<PlayerModel> players, int candidateIndex) {
    var seed = 17 + candidateIndex;
    for (final player in players) {
      for (final codeUnit in player.id.codeUnits) {
        seed = (seed * 31 + codeUnit) % 2147483647;
      }
    }
    return seed;
  }

  void _validateTeamSizes({
    required List<PlayerModel> players,
    required int teamASize,
    required int teamBSize,
  }) {
    if (players.length != teamASize + teamBSize) {
      throw Exception('Quantidade de jogadores invalida para os times');
    }
  }

  void _sortResults(List<TeamResult> results) {
    results.sort((a, b) {
      final scoreCompare = a.score.compareTo(b.score);
      if (scoreCompare != 0) return scoreCompare;

      final overallCompare = a.overallDifference.compareTo(b.overallDifference);
      if (overallCompare != 0) return overallCompare;

      return a.teamA
          .map((player) => player.name)
          .join('|')
          .compareTo(b.teamA.map((player) => player.name).join('|'));
    });
  }

  Map<String, List<PlayerModel>> _groupPlayersByPosition(
    List<PlayerModel> players,
  ) {
    final playersByPosition = <String, List<PlayerModel>>{};

    for (final player in players) {
      playersByPosition.putIfAbsent(player.position, () => []).add(player);
    }

    return playersByPosition;
  }

  Map<String, int> _calculateTeamACountByPosition({
    required Map<String, List<PlayerModel>> playersByPosition,
    required int teamASize,
    required int totalPlayers,
  }) {
    final teamACountByPosition = <String, int>{};
    final remainders = <_PositionRemainder>[];
    int assignedToTeamA = 0;

    final positions = playersByPosition.keys.toList()..sort();
    for (final position in positions) {
      final count = playersByPosition[position]!.length;
      final exactShare = (count * teamASize) / totalPlayers;
      final baseCount = exactShare.floor();

      teamACountByPosition[position] = baseCount;
      assignedToTeamA += baseCount;
      remainders.add(
        _PositionRemainder(
          position: position,
          remainder: exactShare - baseCount,
        ),
      );
    }

    int remainingSlots = teamASize - assignedToTeamA;

    remainders.sort((a, b) {
      final remainderCompare = b.remainder.compareTo(a.remainder);
      if (remainderCompare != 0) return remainderCompare;
      return a.position.compareTo(b.position);
    });

    for (final item in remainders) {
      if (remainingSlots <= 0) {
        break;
      }

      final currentCount = teamACountByPosition[item.position] ?? 0;
      final maxCount = playersByPosition[item.position]!.length;
      if (currentCount >= maxCount) {
        continue;
      }

      teamACountByPosition[item.position] = currentCount + 1;
      remainingSlots--;
    }

    if (remainingSlots != 0) {
      throw Exception(
        'N\u00E3o foi poss\u00EDvel dividir os jogadores por posi\u00E7\u00E3o',
      );
    }

    return teamACountByPosition;
  }

  List<List<PlayerModel>> _generateValidTeamACombinations({
    required Map<String, List<PlayerModel>> playersByPosition,
    required Map<String, int> teamACountByPosition,
  }) {
    final result = <List<PlayerModel>>[];
    final orderedPositions = playersByPosition.keys.toList()..sort();

    _buildValidTeamACombinations(
      orderedPositions: orderedPositions,
      playersByPosition: playersByPosition,
      teamACountByPosition: teamACountByPosition,
      positionIndex: 0,
      currentTeam: [],
      result: result,
    );

    return result;
  }

  void _buildValidTeamACombinations({
    required List<String> orderedPositions,
    required Map<String, List<PlayerModel>> playersByPosition,
    required Map<String, int> teamACountByPosition,
    required int positionIndex,
    required List<PlayerModel> currentTeam,
    required List<List<PlayerModel>> result,
  }) {
    if (positionIndex == orderedPositions.length) {
      result.add(List<PlayerModel>.from(currentTeam));
      return;
    }

    final position = orderedPositions[positionIndex];
    final positionPlayers = playersByPosition[position] ?? const [];
    final requiredCount = teamACountByPosition[position] ?? 0;
    final positionCombinations = _combine(positionPlayers, requiredCount);

    for (final combination in positionCombinations) {
      currentTeam.addAll(combination);

      _buildValidTeamACombinations(
        orderedPositions: orderedPositions,
        playersByPosition: playersByPosition,
        teamACountByPosition: teamACountByPosition,
        positionIndex: positionIndex + 1,
        currentTeam: currentTeam,
        result: result,
      );

      currentTeam.removeRange(
        currentTeam.length - combination.length,
        currentTeam.length,
      );
    }
  }

  bool _matchesPositionDistribution(
    List<PlayerModel> team,
    Map<String, int> expectedByPosition,
  ) {
    final currentByPosition = <String, int>{};
    for (final player in team) {
      currentByPosition[player.position] =
          (currentByPosition[player.position] ?? 0) + 1;
    }

    for (final entry in expectedByPosition.entries) {
      if ((currentByPosition[entry.key] ?? 0) != entry.value) {
        return false;
      }
    }

    return true;
  }

  int _sumOverall(List<PlayerModel> players) {
    return players.fold<int>(0, (sum, player) => sum + player.overall);
  }

  double _averageOverall(List<PlayerModel> players) {
    if (players.isEmpty) return 0;

    final total = _sumOverall(players);
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
      result.add(List<PlayerModel>.from(current));
      return;
    }

    for (int index = start; index < players.length; index++) {
      current.add(players[index]);
      _combineRecursive(players, size, index + 1, current, result);
      current.removeLast();
    }
  }
}

class _PositionRemainder {
  final String position;
  final double remainder;

  const _PositionRemainder({required this.position, required this.remainder});
}
