import '../../data/models/player_model.dart';

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

  return sections.join('\n\n');
}

String _buildTeamSection(String title, List<PlayerModel> players) {
  final lines = players.map((player) => '- ${player.name}').join('\n');
  return lines.isEmpty ? '$title:' : '$title:\n$lines';
}
