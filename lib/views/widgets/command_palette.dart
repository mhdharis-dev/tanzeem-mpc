import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class CommandPaletteDialog extends StatefulWidget {
  const CommandPaletteDialog({super.key});

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final commands = [
      {'icon': Icons.home_rounded, 'title': 'Go to Dashboard', 'action': () => appState.setTabIndex(0)},
      {'icon': Icons.assignment_ind_rounded, 'title': 'View Participants Directory', 'action': () => appState.setTabIndex(1)},
      {'icon': Icons.mic_rounded, 'title': 'View All Programs', 'action': () => appState.setTabIndex(2)},
      {'icon': Icons.groups_rounded, 'title': 'Teams & House Roster', 'action': () => appState.setTabIndex(3)},
      {'icon': Icons.account_balance_rounded, 'title': 'Side Events & Exhibitions', 'action': () => appState.setTabIndex(4)},
      {'icon': Icons.calendar_month_rounded, 'title': 'Auto-Generate Schedule', 'action': () => appState.setTabIndex(5)},
      {'icon': Icons.star_rounded, 'title': 'Mark Coordination', 'action': () => appState.setTabIndex(6)},
      {'icon': Icons.check_circle_rounded, 'title': 'Hajar / Present Coordination', 'action': () => appState.setTabIndex(7)},
      {'icon': Icons.live_tv_rounded, 'title': 'Open Live Stage LED Display', 'action': () => appState.setTabIndex(8)},
      {'icon': Icons.emoji_events_rounded, 'title': 'Championship Scoreboard', 'action': () => appState.setTabIndex(9)},
      {'icon': Icons.bar_chart_rounded, 'title': 'Reports & Analytics', 'action': () => appState.setTabIndex(10)},
      {'icon': Icons.person_rounded, 'title': 'Profile / Settings', 'action': () => appState.setTabIndex(11)},
      {
        'icon': isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        'title': 'Toggle Dark / Light Theme',
        'action': () => appState.toggleTheme()
      },
    ];

    final filtered = commands.where((c) {
      final title = (c['title'] as String).toLowerCase();
      return title.contains(_query.toLowerCase());
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                      onChanged: (val) => setState(() => _query = val),
                      decoration: const InputDecoration(
                        hintText: 'Type a command or search action (e.g. "Live", "Add")...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ESC',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),

            // Command Items List
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.subtextDark),
                    onTap: () {
                      Navigator.pop(context);
                      (item['action'] as VoidCallback)();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
