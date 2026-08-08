import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

import 'logout_dialog.dart';

class AppSidebar extends StatelessWidget {
  final bool isDrawer;
  const AppSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isCollapsed = isDrawer ? false : appState.isSidebarCollapsed;

    final List<Map<String, dynamic>> menuItems = appState.userRole == 'Super Admin'
        ? [
            {'icon': Icons.grid_view_rounded, 'label': 'Dashboard'},
            {'icon': Icons.domain_rounded, 'label': 'Madrasas Network'},
            {'icon': Icons.people_alt_outlined, 'label': 'Coordinators'},
            {'icon': Icons.analytics_outlined, 'label': 'Reports'},
            {'icon': Icons.info_outline_rounded, 'label': 'About'},
          ]
        : [
            {'icon': Icons.home_rounded, 'label': 'Dashboard'},
            {'icon': Icons.assignment_ind_rounded, 'label': 'Participants'},
            {'icon': Icons.mic_rounded, 'label': 'Programs'},
            {'icon': Icons.groups_rounded, 'label': 'Teams'},
            {'icon': Icons.account_balance_rounded, 'label': 'Side Events'},
            {'icon': Icons.calendar_month_rounded, 'label': 'Schedule'},
            {'icon': Icons.star_rounded, 'label': 'Mark Coordination'},
            {'icon': Icons.check_circle_rounded, 'label': 'Present Coordination'},
            {'icon': Icons.live_tv_rounded, 'label': 'Live Stage'},
            {'icon': Icons.emoji_events_rounded, 'label': 'Scoreboard'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
            {'icon': Icons.info_outline_rounded, 'label': 'About'},
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isDrawer ? 280 : (isCollapsed ? 80 : 260),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header Logo & Branding
          Container(
            height: 84,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                // Prominent High-Visibility Logo Card
                Container(
                  width: 55,
                  height: 55,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withAlpha(50),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/tanzeem_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          'T',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tanzeem',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 19,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withAlpha(80),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                'PRO',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Smart Meelad System',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Navigation Links
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, idx) {
                final item = menuItems[idx];
                final isSelected = appState.activeTabIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: InkWell(
                    onTap: () {
                      if (isDrawer && Scaffold.maybeOf(context)?.hasDrawer == true) {
                        Navigator.of(context).pop();
                      }
                      if (appState.activeTabIndex != idx) {
                        appState.setTabIndex(idx);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: isCollapsed ? 12 : 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.primary.withAlpha(50) : AppColors.primary.withAlpha(20))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: AppColors.primary.withAlpha(100), width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            size: 22,
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: GoogleFonts.poppins(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.textLight : AppColors.textDark),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sidebar Bottom: Collapse Toggle & Profile
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Collapse button
                IconButton(
                  onPressed: () => appState.toggleSidebar(),
                  icon: Icon(
                    isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                  ),
                  tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                ),
                const SizedBox(height: 8),
                // User Profile Box
                Container(
                  padding: EdgeInsets.all(isCollapsed ? 8 : 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Text('MC', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.userEmail.isNotEmpty ? appState.userEmail : 'User Account',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                appState.userRole,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: appState.userRole == 'Super Admin' ? AppColors.accent : AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                          onPressed: () => showLogoutConfirmationDialog(context, appState),
                          tooltip: 'Sign Out',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
