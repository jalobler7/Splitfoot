import 'package:go_router/go_router.dart';
import '../../data/models/player_model.dart';
import '../../domain/entities/match_result_arguments.dart';
import '../../presentation/pages/help/help_page.dart';
import '../../presentation/pages/groups/team_groups_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/legal/privacy_policy_page.dart';
import '../../presentation/pages/legal/terms_of_use_page.dart';
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
  static const groups = '/groups';
  static const teamGroups = '/team-groups';
  static const privacyPolicy = '/privacy-policy';
  static const termsOfUse = '/terms-of-use';
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
      path: AppRoutes.teamGroups,
      builder: (context, state) => const TeamGroupsPage(),
    ),
    GoRoute(
      path: AppRoutes.groups,
      redirect: (context, state) => AppRoutes.teamGroups,
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: AppRoutes.termsOfUse,
      builder: (context, state) => const TermsOfUsePage(),
    ),
    GoRoute(
      path: AppRoutes.result,
      redirect: (context, state) =>
          state.extra is MatchResultArguments ? null : AppRoutes.matchSetup,
      builder: (context, state) {
        final arguments = state.extra;
        if (arguments is! MatchResultArguments) {
          return const MatchSetupPage();
        }
        return ResultPage(arguments: arguments);
      },
    ),
    GoRoute(
      path: AppRoutes.ranking,
      redirect: (context, state) =>
          state.extra is List<PlayerModel> ? null : AppRoutes.rankings,
      builder: (context, state) {
        final players = state.extra;
        if (players is! List<PlayerModel>) {
          return const RankingsPage();
        }
        return RankingPage(players: players);
      },
    ),
    GoRoute(
      path: AppRoutes.rankings,
      builder: (context, state) => const RankingsPage(),
    ),
  ],
);
