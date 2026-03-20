import '../../data/models/player_model.dart';

class RankingService {
  List<PlayerModel> rankPlayers(List<PlayerModel> players) {
    final sorted = List<PlayerModel>.from(players);

    sorted.sort((a, b) {
      // 1. Overall
      final overallCompare = b.overall.compareTo(a.overall);
      if (overallCompare != 0) return overallCompare;

      // 2. Ataque
      final attackCompare = b.attack.compareTo(a.attack);
      if (attackCompare != 0) return attackCompare;

      // 3. Defesa
      final defenseCompare = b.defense.compareTo(a.defense);
      if (defenseCompare != 0) return defenseCompare;

      // 4. Fôlego
      final staminaCompare = b.stamina.compareTo(a.stamina);
      if (staminaCompare != 0) return staminaCompare;

      // 5. Nome
      return a.name.compareTo(b.name);
    });

    return sorted;
  }
}