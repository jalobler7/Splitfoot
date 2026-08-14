import 'package:divide_time/core/enums/balance_mode.dart';
import 'package:divide_time/core/enums/sport_type.dart';
import 'package:divide_time/data/models/player_model.dart';
import 'package:divide_time/domain/entities/match_generation_request.dart';
import 'package:divide_time/domain/entities/team_result.dart';
import 'package:divide_time/domain/services/team_balance_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = TeamBalanceService();

  test('keeps the exact results for a small overall match', () {
    final players = _players(4);

    final results = service.balanceTopByOverall(
      players: players,
      teamASize: 2,
      teamBSize: 2,
    );

    expect(results, hasLength(3));
    _expectValidResults(results, players, teamASize: 2, teamBSize: 2);
  });

  test('generates valid results for all balance criteria', () {
    final players = _players(10);

    for (final mode in BalanceMode.values) {
      final results = service.generate(
        MatchGenerationRequest(
          players: players,
          sport: SportType.futsal,
          teamASize: 5,
          teamBSize: 5,
          groupId: 'group-1',
          balanceMode: mode,
        ),
      );

      _expectValidResults(results, players, teamASize: 5, teamBSize: 5);
    }
  });

  test('uses the bounded strategy for 22-player matches', () {
    final players = _players(22);

    for (final mode in BalanceMode.values) {
      final stopwatch = Stopwatch()..start();
      final results = service.generate(
        MatchGenerationRequest(
          players: players,
          sport: SportType.fut11,
          teamASize: 11,
          teamBSize: 11,
          groupId: 'group-1',
          balanceMode: mode,
        ),
      );
      stopwatch.stop();

      _expectValidResults(results, players, teamASize: 11, teamBSize: 11);
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    }
  });
}

List<PlayerModel> _players(int count) {
  const positions = ['Pivo', 'Ala', 'Fixo'];

  return List.generate(
    count,
    (index) => PlayerModel(
      id: 'player-$index',
      name: 'Jogador $index',
      attack: 35 + (index * 11) % 60,
      defense: 30 + (index * 7) % 65,
      stamina: 40 + (index * 13) % 55,
      position: positions[index % positions.length],
      sport: 'Futsal',
      teamGroupId: 'group-1',
    ),
  );
}

void _expectValidResults(
  List<TeamResult> results,
  List<PlayerModel> players, {
  required int teamASize,
  required int teamBSize,
}) {
  expect(results, isNotEmpty);
  expect(results.length, lessThanOrEqualTo(5));
  expect(
    results.map((result) => result.canonicalKey).toSet().length,
    results.length,
  );

  for (var index = 1; index < results.length; index++) {
    expect(results[index - 1].score, lessThanOrEqualTo(results[index].score));
  }

  final expectedIds = players.map((player) => player.id).toSet();
  for (final result in results) {
    expect(result.teamA, hasLength(teamASize));
    expect(result.teamB, hasLength(teamBSize));

    final resultIds = [
      ...result.teamA.map((player) => player.id),
      ...result.teamB.map((player) => player.id),
    ];
    expect(resultIds, hasLength(teamASize + teamBSize));
    expect(resultIds.toSet(), hasLength(resultIds.length));
    expect(resultIds.toSet(), expectedIds);
  }
}
