import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/logout_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _festNameController;
  late TextEditingController _madrasaController;
  String _shortcutSearchQuery = '';

  bool _isFestivalExpanded = true;
  bool _isEditingFestival = false;

  bool _isMadrasaExpanded = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _festNameController = TextEditingController(text: appState.festivalName);
    _madrasaController = TextEditingController(text: appState.madrasaName);
  }

  @override
  void dispose() {
    _festNameController.dispose();
    _madrasaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    // Active Madrasa profile
    final activeMadrasa = appState.madrasas.firstWhere(
      (m) => m.email.toLowerCase() == appState.userEmail.toLowerCase(),
      orElse: () => appState.madrasas.first,
    );

    final shortcuts = [
      {
        'key': 'Ctrl + S',
        'action': 'Command Search Palette',
        'desc': 'Opens global search modal to search programs, students & commands',
        'category': 'Navigation',
        'icon': Icons.search_rounded,
      },
      {
        'key': 'Ctrl + N',
        'action': 'Add New Program Modal',
        'desc': 'Opens program entry creation dialog directly',
        'category': 'Management',
        'icon': Icons.add_circle_outline_rounded,
      },
      {
        'key': 'Ctrl + D',
        'action': 'Overview Dashboard',
        'desc': 'Instantly jumps to the main Dashboard screen',
        'category': 'Navigation',
        'icon': Icons.grid_view_rounded,
      },
      {
        'key': 'Ctrl + P',
        'action': 'Programs / Madrasas',
        'desc': 'Navigates to Program entries or Madrasa network table',
        'category': 'Navigation',
        'icon': Icons.assignment_outlined,
      },
      {
        'key': 'Ctrl + M',
        'action': 'Schedule & Timeline Engine',
        'desc': 'Jumps to automatic timing calculator & reorder timeline',
        'category': 'Navigation',
        'icon': Icons.event_note_rounded,
      },
      {
        'key': 'Ctrl + L',
        'action': 'Live Stage / Coordinators',
        'desc': 'Launches Auditorium LED projector display or Coordinators tab',
        'category': 'Stage Control',
        'icon': Icons.live_tv_rounded,
      },
      {
        'key': 'Ctrl + F',
        'action': 'Participants Directory',
        'desc': 'Opens student participant directory and profile listings',
        'category': 'Directory',
        'icon': Icons.people_alt_outlined,
      },
      {
        'key': 'Ctrl + R',
        'action': 'Reports & Analytics',
        'desc': 'Navigates to printable PDF export & Excel reports screen',
        'category': 'Analytics',
        'icon': Icons.analytics_outlined,
      },
      {
        'key': 'Ctrl + Shift + S',
        'action': 'System Settings',
        'desc': 'Opens System Preferences & Organization identity panel',
        'category': 'Settings',
        'icon': Icons.settings_outlined,
      },
      {
        'key': 'Ctrl + H',
        'action': 'Auto-Recalculate Schedule',
        'desc': 'Triggers instant automatic schedule recalculation algorithm',
        'category': 'Automation',
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'key': 'Ctrl + T',
        'action': 'Toggle Theme Mode',
        'desc': 'Switches between Dark Mode and Light Mode seamlessly',
        'category': 'Appearance',
        'icon': Icons.brightness_6_rounded,
      },
      {
        'key': 'Ctrl + B',
        'action': 'Toggle Sidebar',
        'desc': 'Collapses or expands the navigation sidebar menu',
        'category': 'Layout',
        'icon': Icons.view_sidebar_rounded,
      },
      {
        'key': 'Ctrl + Shift + Q',
        'action': 'Sign Out Portal',
        'desc': 'Opens confirmation dialog to end session and return to login',
        'category': 'Account',
        'icon': Icons.logout_rounded,
      },
    ];

    final filteredShortcuts = shortcuts.where((s) {
      final q = _shortcutSearchQuery.toLowerCase();
      return (s['key'] as String).toLowerCase().contains(q) ||
          (s['action'] as String).toLowerCase().contains(q) ||
          (s['desc'] as String).toLowerCase().contains(q) ||
          (s['category'] as String).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 14,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Control Preferences',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Manage Madrasa details, organization identity, and global keyboard hotkeys.',
                              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Role: ${appState.userRole}',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Section 1: Festival & Organization Identity Card with Edit / Non-Edit Toggle & Inline Save Button Box
            GlassCard(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => setState(() => _isFestivalExpanded = !_isFestivalExpanded),
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.corporate_fare_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Festival & Organization Identity',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _isEditingFestival ? AppColors.accent.withAlpha(30) : (isDark ? Colors.white10 : Colors.black.withAlpha(10)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _isEditingFestival ? 'Editing' : 'Read-Only',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: _isEditingFestival ? AppColors.accent : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Configure event title and campus registration names',
                                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isEditingFestival = !_isEditingFestival;
                                  if (_isEditingFestival) _isFestivalExpanded = true;
                                });
                              },
                              icon: Icon(_isEditingFestival ? Icons.lock_rounded : Icons.edit_outlined, size: 16),
                              label: Text(_isEditingFestival ? 'Lock (Read-Only)' : 'Edit Details'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                side: BorderSide(color: _isEditingFestival ? AppColors.accent : AppColors.primary),
                                foregroundColor: _isEditingFestival ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _isFestivalExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              size: 26,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),

                        Text('Festival Event Title', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _festNameController,
                          enabled: _isEditingFestival,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _isEditingFestival ? (isDark ? AppColors.textLight : AppColors.textDark) : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Meelad Fest 2026 - Central Zone',
                            prefixIcon: const Icon(Icons.celebration_outlined, size: 20),
                            fillColor: _isEditingFestival ? null : (isDark ? AppColors.surfaceDark.withAlpha(100) : Colors.grey.withAlpha(30)),
                            filled: !_isEditingFestival,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Host Madrasa / Campus Institute', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _madrasaController,
                          enabled: _isEditingFestival,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _isEditingFestival ? (isDark ? AppColors.textLight : AppColors.textDark) : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Al-Azhar Central Academy',
                            prefixIcon: const Icon(Icons.school_outlined, size: 20),
                            fillColor: _isEditingFestival ? null : (isDark ? AppColors.surfaceDark.withAlpha(100) : Colors.grey.withAlpha(30)),
                            filled: !_isEditingFestival,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Inline Save Button Box inside the card box
                        if (_isEditingFestival)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _festNameController.text = appState.festivalName;
                                    _madrasaController.text = appState.madrasaName;
                                    _isEditingFestival = false;
                                  });
                                },
                                child: Text('Cancel', style: GoogleFonts.poppins(color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  appState.festivalName = _festNameController.text.trim();
                                  appState.madrasaName = _madrasaController.text.trim();
                                  setState(() => _isEditingFestival = false);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('⚡ Festival & Organization details saved successfully!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.save_rounded, size: 18),
                                label: const Text('Save Settings'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    crossFadeState: _isFestivalExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Registered Madrasa Institute Details Card (Includes Logout & Password with Copy Actions)
            _buildCollapsibleCard(
              isDark: isDark,
              title: 'Registered Madrasa Institute Details',
              subtitle: 'Institute profile, credentials, coordinator info & connection state',
              icon: Icons.school_rounded,
              iconColor: AppColors.secondary,
              isExpanded: _isMadrasaExpanded,
              onToggle: () => setState(() => _isMadrasaExpanded = !_isMadrasaExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.domain_rounded, color: AppColors.secondary, size: 28),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: activeMadrasa.isOnline ? AppColors.success : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? AppColors.cardDark : Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeMadrasa.madrasaName,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Reg No: ${activeMadrasa.madrasaRegNo}',
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: activeMadrasa.isOnline ? AppColors.success : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        activeMadrasa.isOnline ? 'Online now' : activeMadrasa.lastActive,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: activeMadrasa.isOnline ? AppColors.success : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                          fontWeight: activeMadrasa.isOnline ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Logout Button inside Madrasa Details Card
                            ElevatedButton.icon(
                              onPressed: () => showLogoutConfirmationDialog(context, appState),
                              icon: const Icon(Icons.logout_rounded, size: 16),
                              label: const Text('Sign Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            _buildInfoTile('Madrasa ID', activeMadrasa.madrasaId, Icons.badge_outlined, isDark),
                            _buildInfoTile('Location / Address', activeMadrasa.address, Icons.location_on_outlined, isDark),
                            _buildInfoTile('Coordinator Name', activeMadrasa.coordinatorName, Icons.person_outline_rounded, isDark),
                            _buildInfoTile('Coordinator Phone', activeMadrasa.coordinatorPhone, Icons.phone_outlined, isDark),
                            // Email with Copy option
                            _buildInfoTile('Portal Email', activeMadrasa.email, Icons.email_outlined, isDark, canCopy: true),
                            // Password with Show/Hide toggle & Copy option
                            _buildInfoTile(
                              'Portal Password',
                              activeMadrasa.password,
                              Icons.lock_outline_rounded,
                              isDark,
                              canCopy: true,
                              isPassword: true,
                              isPasswordVisible: _isPasswordVisible,
                              onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            _buildInfoTile('Registration Date', activeMadrasa.createdAt, Icons.event_rounded, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Appearance & Theme Card
            GlassCard(
              borderRadius: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDark ? 'Dark Glassmorphism Theme' : 'Light Workspace Mode',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                          Text(
                            'Toggle application color theme aesthetics',
                            style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: isDark,
                    activeTrackColor: AppColors.accent,
                    onChanged: (val) => appState.toggleTheme(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Section 4: Keyboard Shortcuts & Productivity Hotkeys Section
            GlassCard(
              borderRadius: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.keyboard_rounded, color: AppColors.accent, size: 24),
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
                                'Press key combinations anywhere in the app for instant navigation.',
                                style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 240,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Filter shortcuts...',
                            prefixIcon: Icon(Icons.search_rounded, size: 18),
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (val) => setState(() => _shortcutSearchQuery = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, shortcutConstraints) {
                      final isTwoCol = shortcutConstraints.maxWidth > 700;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: filteredShortcuts.map((s) {
                          return SizedBox(
                            width: isTwoCol ? (shortcutConstraints.maxWidth - 16) / 2 : shortcutConstraints.maxWidth,
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
                                        Row(
                                          children: [
                                            Icon(s['icon'] as IconData, size: 14, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                s['action'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
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

  Widget _buildCollapsibleCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return GlassCard(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                  size: 26,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: child,
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool canCopy = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark.withAlpha(120) : Colors.white.withAlpha(180),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                  Text(
                    isPassword ? (isPasswordVisible ? value : '••••••••••••') : (value.isNotEmpty ? value : 'N/A'),
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isPassword && onTogglePassword != null)
              IconButton(
                icon: Icon(isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16, color: AppColors.accent),
                onPressed: onTogglePassword,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: isPasswordVisible ? 'Hide Password' : 'Show Password',
              ),
            if (canCopy)
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied to clipboard!'), backgroundColor: AppColors.primary),
                  );
                },
                padding: const EdgeInsets.only(left: 4),
                constraints: const BoxConstraints(),
                tooltip: 'Copy $label',
              ),
          ],
        ),
      ),
    );
  }
}
