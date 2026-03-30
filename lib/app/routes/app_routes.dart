import 'package:go_router/go_router.dart';
import '../../data/models/player_model.dart';
import '../../domain/entities/team_result.dart';
import '../../presentation/pages/help/help_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/match_setup/match_setup_page.dart';
import '../../presentation/pages/players/players_page.dart';
import '../../presentation/pages/ranking/ranking_page.dart';
import '../../presentation/pages/rankings/rankings_page.dart';
import '../../presentation/pages/result/result_page.dart';

class AppRoutes {
  static const home = '/';
  static const players = '/players';
  static const matchSetup = '/match-setup';
  static const result = '/result';
  static const ranking = '/ranking';
  static const rankings = '/rankings';
  static const help = '/help';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.players,
      builder: (context, state) => const PlayersPage(),
    ),
    GoRoute(
      path: AppRoutes.matchSetup,
      builder: (context, state) => const MatchSetupPage(),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => const HelpPage(),
    ),
    GoRoute(
      path: AppRoutes.result,
      builder: (context, state) {
        final results = state.extra as List<TeamResult>;
        return ResultPage(results: results);
      },
    ),
    GoRoute(
      path: AppRoutes.ranking,
      builder: (context, state) {
        final players = state.extra as List<PlayerModel>;
        return RankingPage(players: players);
      },
    ),
    GoRoute(
      path: AppRoutes.rankings,
      builder: (context, state) => const RankingsPage(),
    ),
  ],
);
