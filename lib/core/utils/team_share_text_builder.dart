import '../../data/models/player_model.dart';

const String _appShareCallToAction =
    'Monte seu time voc\u00EA tamb\u00E9m:https://splitfoot.netlify.app';

String buildShareText({
  required List<PlayerModel> teamA,
  required List<PlayerModel> teamB,
  String? title,
}) {
  final sections = <String>[];

  if (title != null && title.isNotEmpty) {
    sections.add(title);
  }

  sections.add(_buildTeamSection('Time A', teamA));
  sections.add(_buildTeamSection('Time B', teamB));
  sections.add(_appShareCallToAction);

  return sections.join('\n\n');
}

String _buildTeamSection(String title, List<PlayerModel> players) {
  final lines = players.map((player) => '- ${player.name}').join('\n');
  return lines.isEmpty ? '$title:' : '$title:\n$lines';
}
