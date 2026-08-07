import 'package:divide_time/core/utils/team_share_text_builder.dart';
import 'package:divide_time/data/models/player_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the generated teams and call to action legibly', () {
    final text = buildShareText(
      title: 'Times gerados pelo Splitfoot',
      teamA: [_player('1', 'Ana')],
      teamB: [_player('2', 'Bruno')],
    );

    expect(
      text,
      'Times gerados pelo Splitfoot\n\n'
      'Time A:\n'
      '- Ana\n\n'
      'Time B:\n'
      '- Bruno\n\n'
      'Monte seu time voc\u00EA tamb\u00E9m: https://splitfoot.netlify.app',
    );
  });
}

PlayerModel _player(String id, String name) {
  return PlayerModel(
    id: id,
    name: name,
    attack: 50,
    defense: 50,
    stamina: 50,
    position: 'Ala',
    sport: 'Futsal',
    teamGroupId: 'group-1',
  );
}
