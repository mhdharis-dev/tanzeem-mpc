import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final totalProgs = appState.programs.length;
    final completedProgs = appState.programs.where((p) => p.status == ProgramStatus.completed).length;
    final pendingProgs = appState.programs.where((p) => p.status == ProgramStatus.pending).length;
    final liveProgs = appState.programs.where((p) => p.status == ProgramStatus.live).length;

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return SingleChildScrollView(
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
                // Soft background gradient decorative glow
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
                                  appState.userRole == 'Super Admin'
                                      ? 'Welcome, Super Admin 👑'
                                      : 'Good Morning, Coordinator 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textLight : AppColors.textDark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: appState.userRole == 'Super Admin'
                                        ? AppColors.accent.withAlpha(40)
                                        : AppColors.primary.withAlpha(40),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: appState.userRole == 'Super Admin'
                                          ? AppColors.accent.withAlpha(100)
                                          : AppColors.primary.withAlpha(100),
                                    ),
                                  ),
                                  child: Text(
                                    appState.userRole == 'Super Admin' ? 'SUPER ADMIN' : 'MEELAD 2026',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: appState.userRole == 'Super Admin' ? AppColors.accent : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appState.userRole == 'Super Admin'
                                  ? '$dateStr  •  Central Zone Administration Portal'
                                  : '$dateStr  •  Venue: Grand Auditorium Stage A',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),

                        // Weather & System Status Badge Card
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
                                appState.userRole == 'Super Admin' ? Icons.shield_rounded : Icons.wb_sunny_rounded,
                                color: AppColors.accent,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.userRole == 'Super Admin' ? 'System Health 99.9%' : '28°C Calicut',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark ? AppColors.textLight : AppColors.textDark,
                                    ),
                                  ),
                                  Text(
                                    appState.userRole == 'Super Admin' ? '12 Madrasas Synced' : 'Clear Sky • Humidity 62%',
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

                    // Quick Action Buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: appState.userRole == 'Super Admin'
                          ? [
                              ElevatedButton.icon(
                                onPressed: () => appState.setTabIndex(1), // Madrasas tab
                                icon: const Icon(Icons.domain_rounded, size: 18),
                                label: const Text('Manage Madrasa Network'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => appState.setTabIndex(2), // Coordinators tab
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

          // Statistics Cards Grid
          Text(
            'Overview Statistics',
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
                children: appState.userRole == 'Super Admin'
                    ? [
                        _buildStatCard(
                          context,
                          title: 'Madrasas Registered',
                          value: '${appState.madrasas.length}',
                          subtitle: 'Central Zone Cluster',
                          icon: Icons.domain_rounded,
                          color: AppColors.primary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Authorized Coordinators',
                          value: '48 Active',
                          subtitle: 'Active session tokens',
                          icon: Icons.admin_panel_settings_rounded,
                          color: AppColors.secondary,
                        ),
                        _buildStatCard(
                          context,
                          title: 'Total Competitions',
                          value: '154 Entries',
                          subtitle: 'Sub-Junior to Senior',
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.accent,
                        ),
                        _buildStatCard(
                          context,
                          title: 'System Health',
                          value: '99.9%',
                          subtitle: 'Zero sync failures',
                          icon: Icons.health_and_safety_rounded,
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

          // Main Analytics Charts & Upcoming Stage Feed Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: appState.userRole == 'Super Admin'
                ? [
                    // Left Column: Super Admin Madrasa Network Overview
                    Expanded(
                      flex: 6,
                      child: _buildSuperAdminMadrasasOverview(context, appState, isDark),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: System Audit & Activity Logs
                    Expanded(
                      flex: 4,
                      child: _buildSuperAdminAuditLogs(context, isDark),
                    ),
                  ]
                : [
                    // Left Column: Analytics Charts
                    Expanded(
                      flex: 6,
                      child: Column(
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

                                // Custom Animated Bar Chart Visualization
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
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right Column: Live Stage Preview Card & Upcoming Items
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          // Live Stage Active Card
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

                          // Upcoming Timeline Quick View
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
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminMadrasasOverview(BuildContext context, AppState appState, bool isDark) {
    return GlassCard(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Madrasa Network Directory Overview',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: () => appState.setTabIndex(1),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                label: Text('View All Network', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowHeight: 44,
              columns: const [
                DataColumn(label: Text('Madrasa Name')),
                DataColumn(label: Text('Address')),
                DataColumn(label: Text('Coordinator')),
                DataColumn(label: Text('Email Account')),
              ],
              rows: appState.madrasas.map((m) {
                return DataRow(
                  cells: [
                    DataCell(Text(m.madrasaName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark))),
                    DataCell(Text(m.address, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark))),
                    DataCell(Text(m.coordinatorName, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textLight : AppColors.textDark))),
                    DataCell(Text(m.email, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminAuditLogs(BuildContext context, bool isDark) {
    final logs = [
      {'time': 'Just now', 'event': 'Madrasa Al-Azhar updated schedule sync'},
      {'time': '10 mins ago', 'event': 'Coordinator session started (Zone B)'},
      {'time': '30 mins ago', 'event': 'System automated database snapshot created'},
      {'time': '1 hour ago', 'event': 'Cluster North prayer timing updated'},
      {'time': '2 hours ago', 'event': 'New Madrasa registration approved'},
    ];

    return GlassCard(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Audit & Security Logs',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              const Icon(Icons.shield_outlined, color: AppColors.accent, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 16, color: Colors.white10),
            itemBuilder: (context, idx) {
              final log = logs[idx];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, size: 14, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['event']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textLight : AppColors.textDark,
                          ),
                        ),
                        Text(
                          log['time']!,
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.subtextDark),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassBarItem(BuildContext context, String label, double ratio, String progCount, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark)),
              Text(progCount, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(count, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
