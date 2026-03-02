import 'package:flutter/material.dart';
import 'package:team_flow/features/teams/presentation/pages/teams_list_page.dart';

/// HomePage is now a thin wrapper that delegates to TeamsListPage.
/// All teams-related logic lives in the teams presentation layer.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamsListPage();
  }
}
