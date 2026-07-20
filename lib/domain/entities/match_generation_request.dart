import '../../core/enums/balance_mode.dart';
import '../../core/enums/sport_type.dart';
import '../../data/models/player_model.dart';

class MatchGenerationRequest {
  final List<PlayerModel> players;
  final SportType sport;
  final int teamASize;
  final int teamBSize;
  final String groupId;
  final BalanceMode balanceMode;

  MatchGenerationRequest({
    required List<PlayerModel> players,
    required this.sport,
    required this.teamASize,
    required this.teamBSize,
    required this.groupId,
    required this.balanceMode,
  }) : players = List<PlayerModel>.unmodifiable(players);

  MatchGenerationRequest copyWith({BalanceMode? balanceMode}) {
    return MatchGenerationRequest(
      players: players,
      sport: sport,
      teamASize: teamASize,
      teamBSize: teamBSize,
      groupId: groupId,
      balanceMode: balanceMode ?? this.balanceMode,
    );
  }
}
