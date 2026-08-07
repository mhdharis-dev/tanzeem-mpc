// Library: coordinators_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

import '../../core/utils/whatsapp_helper.dart';

class CoordinatorsScreen extends StatefulWidget {
  const CoordinatorsScreen({super.key});

  @override
  State<CoordinatorsScreen> createState() => _CoordinatorsScreenState();
}

class _CoordinatorsScreenState extends State<CoordinatorsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Online', 'Offline'
  final Map<String, bool> _visiblePasswords = {};

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final allMadrasas = appState.madrasas;
    final totalCoordinators = allMadrasas.length;
    final onlineCount = allMadrasas.where((m) => m.isOnline).length;
    final offlineCount = totalCoordinators - onlineCount;

    // Filter Madrasa Coordinators dynamically from real Firestore Madrasas
    final filteredCoordinators = allMadrasas.where((m) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = m.coordinatorName.toLowerCase().contains(q) ||
          m.coordinatorPhone.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.madrasaName.toLowerCase().contains(q) ||
          m.madrasaRegNo.toLowerCase().contains(q) ||
          m.address.toLowerCase().contains(q);

      if (!matchesSearch) return false;

      if (_statusFilter == 'Online') return m.isOnline;
      if (_statusFilter == 'Offline') return !m.isOnline;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner & Stats Shell
            GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 16,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withAlpha(80)),
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Madrasa Coordinators Directory',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Authorized Madrasa Coordinators managing real-time festival participants.',
                                style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Quick Stats Counter Cards
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          _buildHeaderStatBadge(
                            label: 'Total Coordinators',
                            value: '$totalCoordinators',
                            icon: Icons.supervisor_account_rounded,
                            color: AppColors.primary,
                            isDark: isDark,
                          ),
                          _buildHeaderStatBadge(
                            label: 'Online Now',
                            value: '$onlineCount Active',
                            icon: Icons.circle,
                            color: AppColors.success,
                            isDark: isDark,
                          ),
                          _buildHeaderStatBadge(
                            label: 'Offline',
                            value: '$offlineCount',
                            icon: Icons.circle_outlined,
                            color: Colors.grey,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Search Bar & Filter Tabs
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      // Search Input Box
                      Container(
                        width: 340,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search coordinator, phone, email, madrasa...',
                            hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),

                      // Status Filter Tabs
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildFilterChip('All', 'All ($totalCoordinators)', isDark),
                          _buildFilterChip('Online', '🟢 Online ($onlineCount)', isDark),
                          _buildFilterChip('Offline', '⚪ Offline ($offlineCount)', isDark),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Coordinators Cards Grid Section
            if (filteredCoordinators.isEmpty)
              GlassCard(
                borderRadius: 24,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_search_rounded, size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Coordinators Found',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No madrasa coordinators match your current search query or filter selection.',
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 440,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  mainAxisExtent: 335,
                ),
                itemCount: filteredCoordinators.length,
                itemBuilder: (context, idx) {
                  final m = filteredCoordinators[idx];
                  final isPassVisible = _visiblePasswords[m.madrasaId] ?? false;

                  return GlassCard(
                    borderRadius: 22,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header: Avatar, Name, Online Status & Reg No Badge
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, AppColors.secondary],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withAlpha(60),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      m.coordinatorName.isNotEmpty ? m.coordinatorName[0].toUpperCase() : 'C',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: m.isOnline ? AppColors.success : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? AppColors.cardDark : Colors.white, width: 2.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.coordinatorName,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: m.isOnline ? AppColors.success : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        m.isOnline ? 'Online now' : m.lastActive,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: m.isOnline ? AppColors.success : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                          fontWeight: m.isOnline ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: Text(
                                'Reg: ${m.madrasaRegNo}',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Details Box Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Madrasa Name & Address
                              _buildDetailRow(
                                icon: Icons.school_rounded,
                                iconColor: AppColors.primary,
                                label: 'Madrasa Institute',
                                value: '${m.madrasaName} (${m.address})',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 8),

                              // Coordinator Phone
                              _buildDetailRow(
                                icon: Icons.phone_outlined,
                                iconColor: AppColors.secondary,
                                label: 'Phone Number',
                                value: m.coordinatorPhone.isNotEmpty ? m.coordinatorPhone : 'N/A',
                                isDark: isDark,
                                canCopy: true,
                                isPhone: true,
                              ),
                              const SizedBox(height: 8),

                              // Portal Email
                              _buildDetailRow(
                                icon: Icons.email_outlined,
                                iconColor: AppColors.accent,
                                label: 'Portal Email',
                                value: m.email,
                                isDark: isDark,
                                canCopy: true,
                              ),
                              const SizedBox(height: 8),

                              // Portal Password
                              _buildDetailRow(
                                icon: Icons.lock_outline_rounded,
                                iconColor: AppColors.warning,
                                label: 'Portal Password',
                                value: isPassVisible ? m.password : '••••••••••••',
                                isDark: isDark,
                                canCopy: true,
                                rawCopyValue: m.password,
                                isPassword: true,
                                isPasswordVisible: isPassVisible,
                                onTogglePassword: () {
                                  setState(() {
                                    _visiblePasswords[m.madrasaId] = !isPassVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStatBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
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
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
              Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label, bool isDark) {
    final isSelected = _statusFilter == filterKey;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _statusFilter = filterKey);
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
    bool canCopy = false,
    bool isPhone = false,
    String? rawCopyValue,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isPhone && value != 'N/A')
          IconButton(
            icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF25D366)),
            onPressed: () => WhatsAppHelper.openWhatsAppChat(context: context, phone: value),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Quick WhatsApp Message',
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
              Clipboard.setData(ClipboardData(text: rawCopyValue ?? value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard!'), backgroundColor: AppColors.primary),
              );
            },
            padding: const EdgeInsets.only(left: 6),
            constraints: const BoxConstraints(),
            tooltip: 'Copy $label',
          ),
      ],
    );
  }
}
