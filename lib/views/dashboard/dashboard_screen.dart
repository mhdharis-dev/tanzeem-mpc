import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isSuperAdmin = appState.userRole == 'Super Admin';

    final totalMadrasas = appState.madrasas.length;
    final onlineCoordinators = appState.madrasas.where((m) => m.isOnline).length;
    final totalProgs = appState.programs.length;
    final completedProgs = appState.programs.where((p) => p.status == ProgramStatus.completed).length;
    final pendingProgs = appState.programs.where((p) => p.status == ProgramStatus.pending).length;
    final liveProgs = appState.programs.where((p) => p.status == ProgramStatus.live).length;

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Welcome Hero Section Card
          GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(28),
            customBgColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  top: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(30),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 20,
                      runSpacing: 16,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Text(
                                  isSuperAdmin ? 'Welcome, Super Admin 👑' : 'Good Morning, Coordinator 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSuperAdmin ? AppColors.accent.withAlpha(40) : AppColors.primary.withAlpha(40),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSuperAdmin ? AppColors.accent.withAlpha(100) : AppColors.primary.withAlpha(100),
                                    ),
                                  ),
                                  child: Text(
                                    isSuperAdmin ? 'SUPER ADMIN' : 'MEELAD 2026',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSuperAdmin ? AppColors.accent : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isSuperAdmin
                                  ? '$dateStr  •  Central Zone Administration Portal'
                                  : '$dateStr  •  Venue: Grand Auditorium Stage A',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),

                        // System Status Badge Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSuperAdmin ? Icons.cloud_done_rounded : Icons.wb_sunny_rounded,
                                color: isSuperAdmin ? AppColors.success : AppColors.accent,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSuperAdmin ? 'Firestore Live Sync' : '28°C Calicut',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? AppColors.textLight : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    isSuperAdmin ? '$totalMadrasas Madrasas Connected' : 'Clear Sky • Humidity 62%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
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

                    const SizedBox(height: 24),

                    // Quick Action Navigation Buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: isSuperAdmin
                          ? [
                              ElevatedButton.icon(
                                onPressed: () => appState.setTabIndex(1), // Madrasas Network tab
                                icon: const Icon(Icons.domain_rounded, size: 18),
                                label: const Text('Manage Madrasa Network'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => appState.setTabIndex(2), // Coordinators Directory tab
                                icon: const Icon(Icons.people_alt_outlined, size: 18),
                                label: const Text('Coordinators Directory'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => appState.setTabIndex(3), // Reports tab
                                icon: const Icon(Icons.analytics_outlined, size: 18),
                                label: const Text('System Audit Reports'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                            ]
                          : [
                              ElevatedButton.icon(
                                onPressed: () => appState.setTabIndex(3), // Live stage tab
                                icon: const Icon(Icons.live_tv_rounded, size: 18),
                                label: const Text('Launch Live Stage LED View'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => appState.setTabIndex(1),
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Add New Program'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => appState.setTabIndex(2),
                                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                                label: const Text('Regenerate Auto Schedule'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                            ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Overview Statistics Cards Grid
          Text(
            isSuperAdmin ? 'Real-Time System Overview' : 'Overview Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textLight : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 700
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: isSuperAdmin
                    ? [
                        _buildStatCard(
                          context,
                          title: 'Registered Madrasas',
                          value: '$totalMadrasas',
                          subtitle: 'Cloud Firestore Stream',
                          icon: Icons.domain_rounded,
                          color: AppColors.primary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Authorized Coordinators',
                          value: '$totalMadrasas Registered',
                          subtitle: '🟢 $onlineCoordinators Active Online',
                          icon: Icons.admin_panel_settings_rounded,
                          color: AppColors.secondary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Total Meelad Programs',
                          value: '$totalProgs Events',
                          subtitle: '$completedProgs Finished ($liveProgs Live)',
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.accent,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Cluster Database',
                          value: '100% Synced',
                          subtitle: 'Zero connection errors',
                          icon: Icons.verified_user_rounded,
                          color: AppColors.success,
                        ),
                      ]
                    : [
                        _buildStatCard(
                          context,
                          title: 'Total Programs',
                          value: '$totalProgs',
                          subtitle: 'Scheduled across 4 stages',
                          icon: Icons.assignment_rounded,
                          color: AppColors.primary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Live Now',
                          value: '$liveProgs',
                          subtitle: 'Active performance',
                          icon: Icons.podcasts_rounded,
                          color: AppColors.secondary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Completed',
                          value: '$completedProgs',
                          subtitle: '${totalProgs > 0 ? ((completedProgs / totalProgs) * 100).toStringAsFixed(0) : 0}% finish rate',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Pending Items',
                          value: '$pendingProgs',
                          subtitle: 'Awaiting call to stage',
                          icon: Icons.hourglass_top_rounded,
                          color: AppColors.warning,
                        ),
                      ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Main Analytics / Madrasas Table & Activity Feed Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return isSuperAdmin
                  ? (isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildSuperAdminMadrasasOverview(context, appState, isDark),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _buildSuperAdminAuditLogs(context, appState, isDark),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildSuperAdminMadrasasOverview(context, appState, isDark),
                            const SizedBox(height: 24),
                            _buildSuperAdminAuditLogs(context, appState, isDark),
                          ],
                        ))
                  : (isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildCoordinatorCharts(context, isDark),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _buildCoordinatorLiveFeed(context, appState, isDark),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCoordinatorCharts(context, isDark),
                            const SizedBox(height: 24),
                            _buildCoordinatorLiveFeed(context, appState, isDark),
                          ],
                        ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminMadrasasOverview(BuildContext context, AppState appState, bool isDark) {
    final realMadrasas = appState.madrasas;

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Madrasa Network Directory (${realMadrasas.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => appState.setTabIndex(1),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                label: Text('Manage Network', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (realMadrasas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No Madrasas registered in Cloud Firestore network.',
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: DataTable(
                columnSpacing: 22,
                headingRowHeight: 44,
                headingRowColor: WidgetStateProperty.all(isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                columns: [
                  DataColumn(label: Text('Reg No', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
                  DataColumn(label: Text('Madrasa Institute', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                  DataColumn(label: Text('Coordinator', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                  DataColumn(label: Text('Active Status', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                  DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                ],
                rows: realMadrasas.map((m) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(m.madrasaRegNo, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.madrasaName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            Text(m.address, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          ],
                        ),
                      ),
                      DataCell(Text(m.coordinatorName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: m.isOnline ? AppColors.success : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              m.isOnline ? 'Online' : m.lastActive,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: m.isOnline ? FontWeight.bold : FontWeight.normal,
                                color: m.isOnline ? AppColors.success : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF25D366)),
                          onPressed: () => WhatsAppHelper.openWhatsAppChat(context: context, phone: m.coordinatorPhone),
                          tooltip: 'WhatsApp Chat',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminAuditLogs(BuildContext context, AppState appState, bool isDark) {
    final realMadrasas = appState.madrasas;

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Cluster Activity Audit',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          if (realMadrasas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No cluster activity logs available.',
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: realMadrasas.length,
              separatorBuilder: (context, index) => const Divider(height: 14, color: Colors.white10),
              itemBuilder: (context, idx) {
                final m = realMadrasas[idx];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: m.isOnline ? AppColors.success.withAlpha(25) : AppColors.primary.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        m.isOnline ? Icons.circle : Icons.domain_rounded,
                        size: 12,
                        color: m.isOnline ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${m.madrasaName} (${m.coordinatorName})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                          ),
                          Text(
                            m.isOnline ? '🟢 Coordinator active online now' : 'Registered at: ${m.createdAt}',
                            style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCoordinatorCharts(BuildContext context, bool isDark) {
    return Column(
      children: [
        GlassCard(
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Program Distribution by Class',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '4 Classes',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildClassBarItem(context, 'Sub-Junior', 0.65, '8 Programs', AppColors.primary),
              _buildClassBarItem(context, 'Junior', 0.85, '12 Programs', AppColors.secondary),
              _buildClassBarItem(context, 'Senior', 0.90, '14 Programs', AppColors.accent),
              _buildClassBarItem(context, 'Super Senior', 0.50, '6 Programs', AppColors.info),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCategoryBadge('Qira\'at Recitation', '3', AppColors.primary),
                  _buildCategoryBadge('Na\'at Praise', '2', AppColors.secondary),
                  _buildCategoryBadge('Elocution / Speech', '2', AppColors.accent),
                  _buildCategoryBadge('Group Choir', '1', AppColors.success),
                  _buildCategoryBadge('Islamic Quiz', '1', AppColors.info),
                  _buildCategoryBadge('Calligraphy', '1', AppColors.warning),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinatorLiveFeed(BuildContext context, AppState appState, bool isDark) {
    return Column(
      children: [
        GlassCard(
          borderRadius: 24,
          customBgColor: AppColors.primary.withAlpha(25),
          customBorderColor: AppColors.primary.withAlpha(80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'STAGE A IS LIVE',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.error,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen_rounded, color: AppColors.primary),
                    onPressed: () => appState.setTabIndex(3),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (appState.programs.any((p) => p.status == ProgramStatus.live)) ...[
                Builder(builder: (context) {
                  final liveItem = appState.programs.firstWhere((p) => p.status == ProgramStatus.live);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveItem.item,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Participant: ${liveItem.studentName} (${liveItem.studentClass})',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                    ],
                  );
                }),
              ] else
                Text('No active live performance.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.subtextDark)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GlassCard(
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Timeline',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.programs.take(3).length,
                separatorBuilder: (context, index) => const Divider(height: 16, color: Colors.white10),
                itemBuilder: (context, index) {
                  final item = appState.programs.take(3).toList()[index];
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.startTime,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.item,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item.studentName} • ${item.stage}',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassBarItem(BuildContext context, String title, double progress, String count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
              ),
              Text(
                count,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
