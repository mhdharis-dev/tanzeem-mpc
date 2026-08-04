import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

import 'logout_dialog.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isCollapsed = appState.isSidebarCollapsed;

    final List<Map<String, dynamic>> menuItems = appState.userRole == 'Super Admin'
        ? [
            {'icon': Icons.grid_view_rounded, 'label': 'Dashboard'},
            {'icon': Icons.domain_rounded, 'label': 'Madrasas Network'},
            {'icon': Icons.people_alt_outlined, 'label': 'Coordinators'},
            {'icon': Icons.analytics_outlined, 'label': 'Reports'},
          ]
        : [
            {'icon': Icons.grid_view_rounded, 'label': 'Dashboard'},
            {'icon': Icons.assignment_outlined, 'label': 'Programs'},
            {'icon': Icons.event_note_rounded, 'label': 'Schedule'},
            {'icon': Icons.live_tv_rounded, 'label': 'Live Stage'},
            {'icon': Icons.people_alt_outlined, 'label': 'Participants'},
            {'icon': Icons.grade_rounded, 'label': 'Mark & Present'},
            {'icon': Icons.analytics_outlined, 'label': 'Reports'},
            {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 260,
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
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/tanzeem_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        'T',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PRO',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Smart Meelad System',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
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
                    onTap: () => appState.setTabIndex(idx),
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
