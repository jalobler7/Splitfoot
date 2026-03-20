import '../../data/models/player_model.dart';

class TeamResult {
  final List<PlayerModel> teamA;
  final List<PlayerModel> teamB;
  final num score;
  final String scoreLabel;

  const TeamResult({
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.scoreLabel,
  });

  double get teamAOverallAverage {
    if (teamA.isEmpty) return 0;
    final total = teamA.fold<int>(0, (sum, player) => sum + player.overall);
    return total / teamA.length;
  }

  double get teamBOverallAverage {
    if (teamB.isEmpty) return 0;
    final total = teamB.fold<int>(0, (sum, player) => sum + player.overall);
    return total / teamB.length;
  }

  int get teamAAttackTotal {
    return teamA.fold<int>(0, (sum, player) => sum + player.attack);
  }

  int get teamBAttackTotal {
    return teamB.fold<int>(0, (sum, player) => sum + player.attack);
  }

  int get teamADefenseTotal {
    return teamA.fold<int>(0, (sum, player) => sum + player.defense);
  }

  int get teamBDefenseTotal {
    return teamB.fold<int>(0, (sum, player) => sum + player.defense);
  }

  int get teamAStaminaTotal {
    return teamA.fold<int>(0, (sum, player) => sum + player.stamina);
  }

  int get teamBStaminaTotal {
    return teamB.fold<int>(0, (sum, player) => sum + player.stamina);
  }

  double get overallDifference {
    return (teamAOverallAverage - teamBOverallAverage).abs();
  }

  int get attackDifference {
    return (teamAAttackTotal - teamBAttackTotal).abs();
  }

  int get defenseDifference {
    return (teamADefenseTotal - teamBDefenseTotal).abs();
  }

  int get staminaDifference {
    return (teamAStaminaTotal - teamBStaminaTotal).abs();
  }

  int get attributeDifferenceScore {
    return attackDifference + defenseDifference + staminaDifference;
  }

  String get canonicalKey {
    final teamAIds = teamA.map((player) => player.id).toList()..sort();
    final teamBIds = teamB.map((player) => player.id).toList()..sort();

    final keyA = teamAIds.join('|');
    final keyB = teamBIds.join('|');

    if (teamA.length == teamB.length) {
      final pair = [keyA, keyB]..sort();
      return '${pair[0]}::${pair[1]}';
    }

    return '$keyA::$keyB';
  }
}