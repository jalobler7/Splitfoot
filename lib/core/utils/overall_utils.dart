class OverallUtils {
  static int calculateOverall({
    required int attack,
    required int defense,
    required int stamina,
  }) {
    return ((attack + defense + stamina) / 3).floor();
  }
}