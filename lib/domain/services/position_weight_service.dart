import '../../core/enums/sport_type.dart';

class PositionWeight {
  final int attack;
  final int defense;
  final int stamina;

  const PositionWeight({
    required this.attack,
    required this.defense,
    required this.stamina,
  });
}

class PositionWeightService {
  static final Map<SportType, Map<String, PositionWeight>> weights = {
    SportType.futsal: {
      'Pivo': PositionWeight(attack: 3, defense: 1, stamina: 2),
      'Ala': PositionWeight(attack: 2, defense: 2, stamina: 2),
      'Fixo': PositionWeight(attack: 1, defense: 3, stamina: 1),
    },
    SportType.fut7: {
      'Fixo': PositionWeight(attack: 1, defense: 3, stamina: 2),
      'Ala': PositionWeight(attack: 2, defense: 2, stamina: 3),
      'Meia': PositionWeight(attack: 3, defense: 2, stamina: 2),
      'Atacante': PositionWeight(attack: 3, defense: 1, stamina: 2),
    },
    SportType.fut11: {
      'Zagueiro': PositionWeight(attack: 1, defense: 3, stamina: 2),
      'Volante': PositionWeight(attack: 2, defense: 3, stamina: 3),
      'Lateral Esquerdo': PositionWeight(attack: 2, defense: 2, stamina: 3),
      'Lateral Direito': PositionWeight(attack: 2, defense: 2, stamina: 3),
      'Meia-Atacante': PositionWeight(attack: 3, defense: 2, stamina: 2),
      'Ponta': PositionWeight(attack: 3, defense: 1, stamina: 3),
      'Centroavante': PositionWeight(attack: 3, defense: 1, stamina: 2),
    },
  };

  PositionWeight getWeight(SportType sport, String position) {
    return weights[sport]?[position] ??
        const PositionWeight(attack: 2, defense: 2, stamina: 2);
  }
}