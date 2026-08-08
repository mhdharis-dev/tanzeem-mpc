import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'command_palette.dart';

class HeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HeaderAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isMobile = Responsive.isMobile(context);

    final unreadCount = appState.notifications.where((n) => !n.isRead).length;

    // Real dynamic user identity and madrasa info
    final isSuperAdmin = appState.userRole == 'Super Admin';
    final userName = isSuperAdmin
        ? 'Super Admin'
        : (appState.madrasaName.isNotEmpty ? appState.madrasaName : 'Madrasa Coordinator');
    final userInitial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'M';
    final madrasaTag = appState.madrasaId.isNotEmpty ? 'MADRASA #${appState.madrasaId}' : 'COORDINATOR';

    return Container(
      height: 80,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(220) : Colors.white.withAlpha(220),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
            width: 1.2,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isMobile) ...[
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, size: 24),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          tooltip: 'Open Navigation Menu',
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Command Palette Search Trigger Button (Left Aligned)
                      SizedBox(
                        width: Responsive.isCompactMobile(context)
                            ? 130
                            : (isMobile ? 180 : 340),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const CommandPaletteDialog(),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Search ${appState.programs.length} programs, ${appState.participants.length} participants...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isMobile)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Ctrl + S',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Actions Group (Right Aligned)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Real Authenticated Role & Madrasa ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSuperAdmin
                              ? AppColors.accent.withAlpha(30)
                              : const Color(0xFF0D9488).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSuperAdmin ? AppColors.accent : const Color(0xFF0D9488),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSuperAdmin
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.verified_user_rounded,
                              size: 16,
                              color: isSuperAdmin ? AppColors.accent : const Color(0xFF0D9488),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSuperAdmin ? 'Super Admin' : 'Program Coordinator',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSuperAdmin ? AppColors.accent : const Color(0xFF0D9488),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Real Notifications Popover Button
                      PopupMenuButton(
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                                size: 20,
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
                          PopupMenuItem(
                            enabled: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Notifications',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  '$unreadCount new',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          if (appState.notifications.isEmpty)
                            PopupMenuItem(
                              enabled: false,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text('No active notifications', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.subtextDark)),
                              ),
                            )
                          else
                            ...appState.notifications.map((item) => PopupMenuItem(
                              onTap: () => appState.markNotificationAsRead(item.id),
                              child: Container(
                                width: 300,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: item.type == 'live' ? AppColors.success.withAlpha(40) : AppColors.primary.withAlpha(40),
                                      child: Icon(
                                        item.type == 'live' ? Icons.live_tv_rounded : Icons.notifications_active_rounded,
                                        size: 16,
                                        color: item.type == 'live' ? AppColors.success : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                                              color: isDark ? AppColors.textLight : AppColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            item.message,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            item.timestamp,
                                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.subtextDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // Real User Profile Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isSuperAdmin ? AppColors.accent : const Color(0xFF0D9488),
                              child: Text(
                                userInitial,
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  madrasaTag,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
