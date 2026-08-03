import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/app_state.dart';
import '../core/theme/app_colors.dart';
import 'widgets/sidebar.dart';
import 'widgets/header_appbar.dart';
import 'widgets/command_palette.dart';

import 'dashboard/dashboard_screen.dart';
import 'programs/programs_list_screen.dart';
import 'programs/add_program_dialog.dart';
import 'schedule/schedule_screen.dart';
import 'live_stage/live_stage_screen.dart';
import 'participants/participants_screen.dart';
import 'super_admin/super_admin_screen.dart';
import 'super_admin/coordinators_screen.dart';
import 'coordination/mark_coordination_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

import 'widgets/logout_dialog.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final List<Widget> pages = appState.userRole == 'Super Admin'
        ? [
            const DashboardScreen(),
            const SuperAdminScreen(),
            const CoordinatorsScreen(),
            const MarkCoordinationScreen(),
            const ReportsScreen(),
          ]
        : [
            const DashboardScreen(),
            const ProgramsListScreen(),
            const ScheduleScreen(),
            const LiveStageScreen(),
            const ParticipantsScreen(),
            const MarkCoordinationScreen(),
            const ReportsScreen(),
            const SettingsScreen(),
          ];

    void openCommandPalette() {
      showDialog(
        context: context,
        builder: (context) => const CommandPaletteDialog(),
      );
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Command Palette Search Modal
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): openCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): openCommandPalette,
        // Add New Program Dialog Shortcut
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (appState.userRole != 'Super Admin') {
            showDialog(
              context: context,
              builder: (context) => const AddProgramDialog(),
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () {
          if (appState.userRole != 'Super Admin') {
            showDialog(
              context: context,
              builder: (context) => const AddProgramDialog(),
            );
          }
        },
        // Dashboard Shortcut
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): () => appState.setTabIndex(0),
        const SingleActivator(LogicalKeyboardKey.keyD, meta: true): () => appState.setTabIndex(0),
        // Programs / Madrasas Directory Shortcut
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () => appState.setTabIndex(1),
        const SingleActivator(LogicalKeyboardKey.keyP, meta: true): () => appState.setTabIndex(1),
        // Toggle Dark/Light Theme Shortcut
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () => appState.toggleTheme(),
        const SingleActivator(LogicalKeyboardKey.keyT, meta: true): () => appState.toggleTheme(),
        // Toggle Sidebar Collapse Shortcut
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () => appState.toggleSidebar(),
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () => appState.toggleSidebar(),
        // Live Stage / Coordinators Shortcut
        const SingleActivator(LogicalKeyboardKey.keyL, control: true): () => appState.setTabIndex(appState.userRole == 'Super Admin' ? 2 : 3),
        const SingleActivator(LogicalKeyboardKey.keyL, meta: true): () => appState.setTabIndex(appState.userRole == 'Super Admin' ? 2 : 3),
        // Reports & Analytics Shortcut
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () => appState.setTabIndex(appState.userRole == 'Super Admin' ? 3 : 5),
        const SingleActivator(LogicalKeyboardKey.keyR, meta: true): () => appState.setTabIndex(appState.userRole == 'Super Admin' ? 3 : 5),
        // Schedule & Timeline Engine Shortcut
        const SingleActivator(LogicalKeyboardKey.keyM, control: true): () {
          if (appState.userRole != 'Super Admin') appState.setTabIndex(2);
        },
        const SingleActivator(LogicalKeyboardKey.keyM, meta: true): () {
          if (appState.userRole != 'Super Admin') appState.setTabIndex(2);
        },
        // Participants Directory Shortcut
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () => appState.setTabIndex(appState.userRole == 'Super Admin' ? 2 : 4),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): () => appState.setTabIndex(appState.userRole == 'Super Admin' ? 2 : 4),
        // System Settings Shortcut (Program Coordinator only)
        const SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true): () {
          if (appState.userRole != 'Super Admin') appState.setTabIndex(6);
        },
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true, shift: true): () {
          if (appState.userRole != 'Super Admin') appState.setTabIndex(6);
        },
        // Auto-Schedule Timings Shortcut
        const SingleActivator(LogicalKeyboardKey.keyH, control: true): () {
          appState.generateAutoSchedule();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚡ Auto-schedule regenerated via hotkey (Ctrl + H)!'), backgroundColor: AppColors.primary),
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyH, meta: true): () {
          appState.generateAutoSchedule();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚡ Auto-schedule regenerated via hotkey (Ctrl + H)!'), backgroundColor: AppColors.primary),
          );
        },
        // Logout Shortcut with confirmation dialog
        const SingleActivator(LogicalKeyboardKey.keyQ, control: true, shift: true): () => showLogoutConfirmationDialog(context, appState),
        const SingleActivator(LogicalKeyboardKey.keyQ, meta: true, shift: true): () => showLogoutConfirmationDialog(context, appState),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          body: Row(
            children: [
              // Collapsible Left Navigation Sidebar
              const AppSidebar(),

              // Main Body Shell (Sticky Top Bar + Active Screen View)
              Expanded(
                child: Column(
                  children: [
                    const HeaderAppBar(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: pages[appState.activeTabIndex.clamp(0, pages.length - 1)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
