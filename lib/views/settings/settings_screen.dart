// Library: settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/logout_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _festNameController;
  late TextEditingController _madrasaController;
  String _shortcutSearchQuery = '';

  bool _isEditingFestival = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final appState = Provider.of<AppState>(context, listen: false);
    _festNameController = TextEditingController(text: appState.festivalName);
    _madrasaController = TextEditingController(text: appState.madrasaName);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        'action': 'System Settings / Profile',
        'desc': 'Opens User Profile & Organization preferences panel',
        'category': 'Settings',
        'icon': Icons.person_rounded,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PROFILE HERO HEADER CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF0D9488), const Color(0xFF0F766E), const Color(0xFF115E59)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withAlpha(70),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile Avatar Box with Glow
                  Stack(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(25),
                          border: Border.all(color: Colors.white.withAlpha(90), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            activeMadrasa.coordinatorName.isNotEmpty
                                ? activeMadrasa.coordinatorName.substring(0, 1).toUpperCase()
                                : 'C',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              activeMadrasa.coordinatorName.isNotEmpty ? activeMadrasa.coordinatorName : 'Coordinator Account',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                appState.userRole,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeMadrasa.madrasaName,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withAlpha(220),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildProfileHeaderBadge(Icons.badge_outlined, 'Madrasa ID: ${activeMadrasa.madrasaId}'),
                            _buildProfileHeaderBadge(Icons.email_outlined, activeMadrasa.email),
                            _buildProfileHeaderBadge(Icons.phone_outlined, activeMadrasa.coordinatorPhone),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sign Out Button in Hero Header
                  ElevatedButton.icon(
                    onPressed: () => showLogoutConfirmationDialog(context, appState),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // --- 2. SEGMENTED TAB SWITCHER BAR ---
            Container(
              height: 54,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(90),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Profile & Identity'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.corporate_fare_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Organization Setup'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.palette_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Theme & Appearance'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.keyboard_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Hotkey Shortcuts'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. TAB CONTENT VIEWS ---
            SizedBox(
              height: 520,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: PROFILE & IDENTITY
                  _buildProfileIdentityTab(context, activeMadrasa, isDark),

                  // TAB 2: ORGANIZATION SETUP
                  _buildOrganizationSetupTab(context, appState, isDark),

                  // TAB 3: THEME & APPEARANCE
                  _buildThemeAppearanceTab(context, appState, isDark),

                  // TAB 4: HOTKEY SHORTCUTS
                  _buildHotkeyShortcutsTab(context, filteredShortcuts, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: PROFILE & IDENTITY ---
  Widget _buildProfileIdentityTab(BuildContext context, dynamic activeMadrasa, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Registered Institute & Coordinator Credentials',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
        ),
        Text(
          'Official portal account specifications and madrasa campus profile.',
          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 16,
          runSpacing: 14,
          children: [
            _buildProfileTile(
              label: 'Coordinator Name',
              value: activeMadrasa.coordinatorName,
              icon: Icons.person_rounded,
              isDark: isDark,
            ),
            _buildProfileTile(
              label: 'Contact Phone',
              value: activeMadrasa.coordinatorPhone,
              icon: Icons.phone_rounded,
              isDark: isDark,
              canCopy: true,
            ),
            _buildProfileTile(
              label: 'Portal Login Email',
              value: activeMadrasa.email,
              icon: Icons.email_rounded,
              isDark: isDark,
              canCopy: true,
            ),
            _buildProfileTile(
              label: 'Portal Password',
              value: activeMadrasa.password,
              icon: Icons.lock_rounded,
              isDark: isDark,
              canCopy: true,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            _buildProfileTile(
              label: 'Madrasa ID',
              value: activeMadrasa.madrasaId,
              icon: Icons.badge_rounded,
              isDark: isDark,
              canCopy: true,
            ),
            _buildProfileTile(
              label: 'Registration No',
              value: activeMadrasa.madrasaRegNo,
              icon: Icons.confirmation_number_rounded,
              isDark: isDark,
            ),
            _buildProfileTile(
              label: 'Campus Institute',
              value: activeMadrasa.madrasaName,
              icon: Icons.domain_rounded,
              isDark: isDark,
            ),
            _buildProfileTile(
              label: 'Location Address',
              value: activeMadrasa.address,
              icon: Icons.location_on_rounded,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  // --- TAB 2: ORGANIZATION SETUP ---
  Widget _buildOrganizationSetupTab(BuildContext context, AppState appState, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Festival & Campus Identity Settings',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                Text(
                  'Configure main festival title and institute display names across scorecards & certificates.',
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditingFestival = !_isEditingFestival;
                });
              },
              icon: Icon(_isEditingFestival ? Icons.lock_rounded : Icons.edit_outlined, size: 16),
              label: Text(_isEditingFestival ? 'Lock (Read-Only)' : 'Edit Identity'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                side: BorderSide(color: _isEditingFestival ? AppColors.accent : AppColors.primary),
                foregroundColor: _isEditingFestival ? AppColors.accent : AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Festival Event Title', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? AppColors.textLight : AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _festNameController,
                enabled: _isEditingFestival,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: _isEditingFestival ? (isDark ? AppColors.textLight : AppColors.textDark) : (isDark ? Colors.white70 : Colors.black87),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Meelad Fest 2026 - Central Zone',
                  prefixIcon: const Icon(Icons.celebration_rounded, size: 20, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  fillColor: _isEditingFestival ? null : (isDark ? AppColors.surfaceDark.withAlpha(100) : Colors.grey.withAlpha(30)),
                  filled: !_isEditingFestival,
                ),
              ),
              const SizedBox(height: 18),

              Text('Host Madrasa / Campus Institute', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? AppColors.textLight : AppColors.textDark)),
              const SizedBox(height: 8),
              TextField(
                controller: _madrasaController,
                enabled: _isEditingFestival,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: _isEditingFestival ? (isDark ? AppColors.textLight : AppColors.textDark) : (isDark ? Colors.white70 : Colors.black87),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Al-Azhar Central Academy',
                  prefixIcon: const Icon(Icons.school_rounded, size: 20, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  fillColor: _isEditingFestival ? null : (isDark ? AppColors.surfaceDark.withAlpha(100) : Colors.grey.withAlpha(30)),
                  filled: !_isEditingFestival,
                ),
              ),

              if (_isEditingFestival) ...[
                const SizedBox(height: 22),
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
                      child: Text('Cancel', style: GoogleFonts.poppins(color: isDark ? AppColors.subtextLight : AppColors.subtextDark, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        appState.festivalName = _festNameController.text.trim();
                        appState.madrasaName = _madrasaController.text.trim();
                        setState(() => _isEditingFestival = false);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✨ Festival & Organization details saved successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text('Save Identity Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 3: THEME & APPEARANCE ---
  Widget _buildThemeAppearanceTab(BuildContext context, AppState appState, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Application Visual Aesthetics & Theme',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
        ),
        Text(
          'Customize system interface color scheme between Dark Glassmorphism and Light Workspace.',
          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.accent, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDark ? 'Dark Glassmorphism Active' : 'Light Workspace Active',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.textLight : AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDark
                          ? 'Optimized for auditorium projection, low-light stages & high contrast.'
                          : 'Optimized for day outdoor coordination & high clarity print previews.',
                      style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                activeTrackColor: AppColors.accent,
                onChanged: (val) => appState.toggleTheme(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 4: HOTKEY SHORTCUTS ---
  Widget _buildHotkeyShortcutsTab(BuildContext context, List<Map<String, dynamic>> filteredShortcuts, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global Hotkeys & Productivity Shortcuts',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                Text(
                  'Press key combinations anywhere in the app for instant navigation.',
                  style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 240,
              height: 38,
              child: TextField(
                onChanged: (val) => setState(() => _shortcutSearchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Filter shortcuts...',
                  hintStyle: GoogleFonts.poppins(fontSize: 11),
                  prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, shortcutConstraints) {
            final isTwoCol = shortcutConstraints.maxWidth > 700;
            return Wrap(
              spacing: 14,
              runSpacing: 12,
              children: filteredShortcuts.map((s) {
                return SizedBox(
                  width: isTwoCol ? (shortcutConstraints.maxWidth - 14) / 2 : shortcutConstraints.maxWidth,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                              fontSize: 11.5,
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
                                maxLines: 1,
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
    );
  }

  Widget _buildProfileTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    bool canCopy = false,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                  const SizedBox(height: 2),
                  Text(
                    isPassword ? (isPasswordVisible ? value : '••••••••••••') : (value.isNotEmpty ? value : 'N/A'),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isPassword && onTogglePassword != null)
              IconButton(
                icon: Icon(isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.accent),
                onPressed: onTogglePassword,
                tooltip: isPasswordVisible ? 'Hide Password' : 'Show Password',
              ),
            if (canCopy)
              IconButton(
                icon: const Icon(Icons.content_copy_rounded, size: 16, color: AppColors.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  messenger.showSnackBar(
                    SnackBar(content: Text('📋 $label copied to clipboard!'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 2)),
                  );
                },
                tooltip: 'Copy $label',
              ),
          ],
        ),
      ),
    );
  }
}
