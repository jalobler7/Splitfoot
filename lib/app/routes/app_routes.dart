import 'package:go_router/go_router.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/players/players_page.dart';
import '../../presentation/pages/match_setup/match_setup_page.dart';
import '../../presentation/pages/result/result_page.dart';
import '../../presentation/pages/ranking/ranking_page.dart';

class AppRoutes {
  static const home = '/';
  static const players = '/players';
  static const matchSetup = '/match-setup';
  static const result = '/result';
  static const ranking = '/ranking';
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
      path: AppRoutes.result,
      builder: (context, state) => const ResultPage(),
    ),
    GoRoute(
      path: AppRoutes.ranking,
      builder: (context, state) => const RankingPage(),
    ),
  ],
);