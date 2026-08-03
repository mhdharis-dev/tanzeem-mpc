import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _festNameController;
  late TextEditingController _madrasaController;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _festNameController = TextEditingController(text: appState.festivalName);
    _madrasaController = TextEditingController(text: appState.madrasaName);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Settings & Preferences',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            Text(
              'Configure festival details, default timing parameters, and theme appearance.',
              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
            ),

            const SizedBox(height: 24),

            GlassCard(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Festival & Organization Identity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 16),
                  Text('Festival Event Title', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextField(controller: _festNameController),
                  const SizedBox(height: 16),
                  Text('Host Madrasa / Campus Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                  const SizedBox(height: 6),
                  TextField(controller: _madrasaController),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      appState.festivalName = _festNameController.text;
                      appState.madrasaName = _madrasaController.text;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings saved successfully!'), backgroundColor: AppColors.success),
                      );
                    },
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Keyboard Shortcuts & Hotkeys Reference Card
            GlassCard(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.keyboard_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global Keyboard Shortcuts & Productivity Hotkeys',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Press these shortcut keys anywhere in the application for rapid navigation.',
                            style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;
                      final shortcuts = [
                        {
                          'key': 'Ctrl + S',
                          'action': 'Command Search Palette',
                          'desc': 'Opens global search modal to search programs, students & commands',
                          'icon': Icons.search_rounded,
                        },
                        {
                          'key': 'Ctrl + N',
                          'action': 'Add New Program Modal',
                          'desc': 'Opens program entry creation dialog directly',
                          'icon': Icons.add_circle_outline_rounded,
                        },
                        {
                          'key': 'Ctrl + D',
                          'action': 'Overview Dashboard',
                          'desc': 'Instantly jumps to the main Dashboard screen',
                          'icon': Icons.grid_view_rounded,
                        },
                        {
                          'key': 'Ctrl + P',
                          'action': 'Programs / Madrasas',
                          'desc': 'Navigates to Program entries or Madrasa network table',
                          'icon': Icons.assignment_outlined,
                        },
                        {
                          'key': 'Ctrl + M',
                          'action': 'Schedule & Timeline Engine',
                          'desc': 'Jumps to automatic timing calculator & reorder timeline',
                          'icon': Icons.event_note_rounded,
                        },
                        {
                          'key': 'Ctrl + L',
                          'action': 'Live Stage / Coordinators',
                          'desc': 'Launches Auditorium LED projector display or Coordinators tab',
                          'icon': Icons.live_tv_rounded,
                        },
                        {
                          'key': 'Ctrl + F',
                          'action': 'Participants Directory',
                          'desc': 'Opens student participant directory and profile listings',
                          'icon': Icons.people_alt_outlined,
                        },
                        {
                          'key': 'Ctrl + R',
                          'action': 'Reports & Analytics',
                          'desc': 'Navigates to printable PDF export & Excel reports screen',
                          'icon': Icons.analytics_outlined,
                        },
                        {
                          'key': 'Ctrl + Shift + S',
                          'action': 'System Settings',
                          'desc': 'Opens System Preferences & Organization identity panel',
                          'icon': Icons.settings_outlined,
                        },
                        {
                          'key': 'Ctrl + H',
                          'action': 'Auto-Recalculate Schedule',
                          'desc': 'Triggers instant automatic schedule recalculation algorithm',
                          'icon': Icons.auto_awesome_rounded,
                        },
                        {
                          'key': 'Ctrl + T',
                          'action': 'Toggle Theme Mode',
                          'desc': 'Switches between Dark Mode and Light Mode seamlessly',
                          'icon': Icons.brightness_6_rounded,
                        },
                        {
                          'key': 'Ctrl + B',
                          'action': 'Toggle Sidebar',
                          'desc': 'Collapses or expands the navigation sidebar menu',
                          'icon': Icons.view_sidebar_rounded,
                        },
                        {
                          'key': 'Ctrl + Shift + Q',
                          'action': 'Sign Out Portal',
                          'desc': 'Ends current active session and returns to login screen',
                          'icon': Icons.logout_rounded,
                        },
                      ];

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: shortcuts.map((s) {
                          return SizedBox(
                            width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(25),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.primary.withAlpha(80)),
                                    ),
                                    child: Text(
                                      s['key'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s['action'] as String,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.textLight : AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          s['desc'] as String,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
