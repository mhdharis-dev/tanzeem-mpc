// Library: about_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _supportPhone = '9544234298';
  final String _supportEmail = 'support@tanzeem.org';
  String _faqQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Launch WhatsApp Message Directly
  Future<void> _launchWhatsApp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/91$_supportPhone?text=Hello%20Tanzeem%20Meelad%20Support%2C%20I%20need%20assistance%20with%20the%20coordinator%20app.',
    );

    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('⚠️ Could not open WhatsApp natively. Opening web browser...'),
            backgroundColor: AppColors.warning,
          ),
        );
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error opening WhatsApp: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Launch Direct Phone Call
  Future<void> _launchPhoneCall(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final Uri phoneUrl = Uri.parse('tel:+91$_supportPhone');
    try {
      await launchUrl(phoneUrl);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('📞 Helpline Number: +91 $_supportPhone'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  // Launch Email Support
  Future<void> _launchEmail(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final Uri emailUrl = Uri.parse('mailto:$_supportEmail?subject=Tanzeem%20Meelad%20Coordinator%20Support');
    try {
      await launchUrl(emailUrl);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('✉️ Support Email: $_supportEmail'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showReleaseNotesModal(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Release Notes - v2.4.0',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Latest System Enhancements',
                  style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                ),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReleaseItem('⚡ Real-time Side Event & Stage Synchronization with Secured Encrypted Database.'),
              _buildReleaseItem('🎨 Chrome-style Multi-Tab Batch Entry System for Single, Group & Side Events.'),
              _buildReleaseItem('🚫 Category Duplicate Protection & Multi-Student Program Selection.'),
              _buildReleaseItem('🏆 Dynamic Team Standings and Medal Tally Auto-Calculation.'),
              _buildReleaseItem('📄 Instant High-Resolution PDF Certificate and Scorecard Exports.'),
              _buildReleaseItem('📞 Direct WhatsApp Support Integration (+91 9544234298).'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildReleaseItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12.5, height: 1.4))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PREMIUM HERO BRANDING BANNER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
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
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    bottom: -30,
                    child: Icon(
                      Icons.mosque_rounded,
                      size: 220,
                      color: Colors.white.withAlpha(12),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App Logo Container
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white.withAlpha(90), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/tanzeem_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('T', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    Text(
                                      'Tanzeem Meelad Coordinator',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF59E0B).withAlpha(100),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'PRO v2.4.0',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Next-Generation Meelad Festival Suite for Madrasa Management, Live Stage Operations & Multi-Event Scoring.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withAlpha(220),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // System Metadata Badges Row
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          _buildHeaderBadge(Icons.shield_outlined, 'Secured Encrypted Database', const Color(0xFF10B981)),
                          _buildHeaderBadge(Icons.domain_rounded, 'Madrasa ID: ${appState.madrasaId}', Colors.white.withAlpha(35)),
                          _buildHeaderBadge(Icons.verified_user_rounded, 'Role: ${appState.userRole}', Colors.white.withAlpha(35)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- QUICK WHATSAPP & HELPLINE CONTACT BANNER IN HERO ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withAlpha(40)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF25D366),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Need Quick Technical Assistance?',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Connect directly with technical support via WhatsApp helpline (+91 9544234298)',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withAlpha(200),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _launchWhatsApp(context),
                              icon: const Icon(Icons.send_rounded, size: 15),
                              label: Text(
                                '💬 Quick WhatsApp',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => _launchPhoneCall(context),
                              icon: const Icon(Icons.call_rounded, size: 15),
                              label: Text(
                                '📞 Call Helpline',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        Icon(Icons.developer_board_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('About Software'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Privacy Policy'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Terms & Conditions'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.headset_mic_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Help & Support'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. TAB CONTENT VIEWS ---
            SizedBox(
              height: 560,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: ABOUT SOFTWARE
                  _buildAboutSoftwareTab(context, isDark),

                  // TAB 2: PRIVACY POLICY
                  _buildPrivacyPolicyTab(isDark),

                  // TAB 3: TERMS & CONDITIONS
                  _buildTermsTab(isDark),

                  // TAB 4: HELP & SUPPORT
                  _buildHelpSupportTab(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: ABOUT SOFTWARE ---
  Widget _buildAboutSoftwareTab(BuildContext context, bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Core System Architecture & Modules',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(
          'Tanzeem Meelad Coordinator provides a complete digital framework for madrasas to coordinate live stage programs, side events, scoring, student rosters, and real-time team standings.',
          style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark, height: 1.5),
        ),
        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          childAspectRatio: 2.1,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFeatureCard(Icons.live_tv_rounded, 'Live Stage Control', 'Real-time countdown timer, judge score cards, and live stage status indicator.', isDark),
            _buildFeatureCard(Icons.calendar_month_rounded, 'Auto-Scheduler Engine', 'Collision-free timeline generator with custom break insertions & hotkey controls.', isDark),
            _buildFeatureCard(Icons.account_balance_rounded, 'Side Events Suite', 'Multi-round contest manager with category duplicate protection & batch entry tabs.', isDark),
            _buildFeatureCard(Icons.emoji_events_rounded, 'Real-time Scoreboard', 'Instant overall house points, tied rank calculations, and medal tallies.', isDark),
            _buildFeatureCard(Icons.assignment_ind_rounded, 'Participant Directory', 'Category-filtered student list with single and group program links.', isDark),
            _buildFeatureCard(Icons.picture_as_pdf_rounded, 'PDF Export Engine', 'High-definition printable certificate exports and scorecards.', isDark),
          ],
        ),

        const SizedBox(height: 22),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showReleaseNotesModal(context, isDark),
              icon: const Icon(Icons.history_rounded, size: 18),
              label: Text('View Full Release Notes & Version History', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withAlpha(80)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? AppColors.textLight : AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 11.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: PRIVACY POLICY ---
  Widget _buildPrivacyPolicyTab(bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Privacy Policy & Data Protection',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        _buildPolicyCard(
          '1. Secured Encrypted Database Storage',
          'All festival records, program details, judge marks, and team standings are stored in a Secured Encrypted Database using enterprise-grade AES-256 & TLS 1.3 end-to-end encryption. All records are partitioned strictly by Madrasa ID.',
          Icons.security_rounded,
          isDark,
        ),
        _buildPolicyCard(
          '2. Role-Based Access Isolation',
          'Coordinators authenticate via secure email credentials. Access is strictly scoped to authorized madrasa data. Unauthenticated requests are rejected at the database rule layer.',
          Icons.admin_panel_settings_rounded,
          isDark,
        ),
        _buildPolicyCard(
          '3. Offline Cache Security',
          'Local offline drafts created on browser/device storage use encrypted SharedPreferences and are automatically cleared upon successful sync to the Secured Encrypted Database.',
          Icons.phonelink_lock_rounded,
          isDark,
        ),
        _buildPolicyCard(
          '4. Student Confidentiality',
          'Student names, registration numbers, and scorecards are maintained solely for festival scoring and official certificate exports. No data is shared with third-party networks.',
          Icons.privacy_tip_rounded,
          isDark,
        ),
      ],
    );
  }

  // --- TAB 3: TERMS & CONDITIONS ---
  Widget _buildTermsTab(bool isDark) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Terms of Service & Usage Guidelines',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        _buildPolicyCard(
          '1. Score Verification & Finality',
          'Coordinators must ensure all stage marks and side event scores are verified prior to setting event status to "Completed". Completed status triggers automatic team scoreboard calculations.',
          Icons.fact_check_rounded,
          isDark,
        ),
        _buildPolicyCard(
          '2. Stage & Timeline Rules',
          'Schedules generated by the Auto-Scheduler must adhere to allocated Madrasa break slots and participant category timing constraints.',
          Icons.schedule_rounded,
          isDark,
        ),
        _buildPolicyCard(
          '3. Coordinator Responsibilities',
          'Coordinators are responsible for preserving login credentials and ensuring accurate student entry across single, group, and side event sheets.',
          Icons.gavel_rounded,
          isDark,
        ),
        _buildPolicyCard(
          '4. Software Licensing',
          'Tanzeem Meelad Coordinator is proprietary software licensed exclusively for registered Madrasa festival events.',
          Icons.copyright_rounded,
          isDark,
        ),
      ],
    );
  }

  Widget _buildPolicyCard(String title, String content, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark)),
                const SizedBox(height: 6),
                Text(content, style: GoogleFonts.poppins(fontSize: 12.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: HELP & SUPPORT (WITH QUICK WHATSAPP & PHONE ACTION CARDS) ---
  Widget _buildHelpSupportTab(BuildContext context, bool isDark) {
    final filteredFaqs = _faqList.where((f) {
      if (_faqQuery.isEmpty) return true;
      return f['q']!.toLowerCase().contains(_faqQuery.toLowerCase()) || f['a']!.toLowerCase().contains(_faqQuery.toLowerCase());
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Help Desk & Technical Support',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
        ),
        Text(
          'Need urgent technical assistance during live stage or scoring operations? Contact support directly.',
          style: GoogleFonts.poppins(fontSize: 12.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
        ),
        const SizedBox(height: 18),

        // Support Contact Action Grid
        Row(
          children: [
            // QUICK WHATSAPP CARD
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withAlpha(18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF25D366).withAlpha(90), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                      child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text('WhatsApp Quick Message', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF25D366))),
                    const SizedBox(height: 4),
                    Text('+91 $_supportPhone', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchWhatsApp(context),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text('Open WhatsApp Chat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // HELPLINE CALL CARD
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary.withAlpha(90), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text('Phone Helpline Call', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('+91 $_supportPhone', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchPhoneCall(context),
                        icon: const Icon(Icons.call_rounded, size: 16),
                        label: Text('Call Helpline', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // EMAIL SUPPORT CARD
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle),
                      child: const Icon(Icons.email_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text('Email Support Desk', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF3B82F6))),
                    const SizedBox(height: 4),
                    Text(_supportEmail, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchEmail(context),
                        icon: const Icon(Icons.mail_outline_rounded, size: 16),
                        label: Text('Send Support Email', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),

        // Frequently Asked Questions Section
        Row(
          children: [
            Text('Frequently Asked Questions (FAQ)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark)),
            const Spacer(),
            SizedBox(
              width: 260,
              height: 38,
              child: TextField(
                onChanged: (val) => setState(() => _faqQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search FAQ answers...',
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
        const SizedBox(height: 12),

        if (filteredFaqs.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'No matching FAQ topics found.',
                style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
              ),
            ),
          )
        else
          ...filteredFaqs.map((faq) => _buildFaqTile(faq['q']!, faq['a']!, isDark)),
      ],
    );
  }

  final List<Map<String, String>> _faqList = [
    {
      'q': 'How do I add a new program or side event?',
      'a': 'Navigate to Programs or Side Events from the sidebar menu and click "+ Host New Event" or "+ Add Program". Use the multi-tab batch entry sheet to quickly configure events and categories.'
    },
    {
      'q': 'Why are some student names disabled during student registration?',
      'a': 'Students already registered in another single event tab or for the same group program name are greyed out to prevent duplicate registrations.'
    },
    {
      'q': 'How are overall team scores and medal tallies calculated?',
      'a': 'Scores and medal tallies (Gold: 1st, Silver: 2nd, Bronze: 3rd) automatically recalculate whenever a stage or side event status is updated to "Completed".'
    },
    {
      'q': 'What happens if a duplicate side event name is entered?',
      'a': 'The sheet automatically detects existing events on the Secured Encrypted Database for the selected category and displays a red alert badge ("Event X is already exists for Category Y").'
    },
  ];

  Widget _buildFaqTile(String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        title: Text(question, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5, color: isDark ? AppColors.textLight : AppColors.textDark)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18, right: 18, bottom: 16),
            child: Text(answer, style: GoogleFonts.poppins(fontSize: 12.5, color: isDark ? AppColors.subtextLight : AppColors.subtextDark, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
