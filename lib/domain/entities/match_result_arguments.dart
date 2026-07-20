import 'match_generation_request.dart';
import 'team_result.dart';

class MatchResultArguments {
  final MatchGenerationRequest request;
  final List<TeamResult> results;

  MatchResultArguments({
    required this.request,
    required List<TeamResult> results,
  }) : results = List<TeamResult>.unmodifiable(results);
}
