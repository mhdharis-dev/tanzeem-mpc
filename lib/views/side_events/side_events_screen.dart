import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_card.dart';

class SideEventItem {
  final String id;
  final String title;
  final String category;
  final String venue;
  final String time;
  final String coordinator;
  int registeredCount;
  final int maxCapacity;
  String status; // 'Live', 'Scheduled', 'Completed'
  final Color themeColor;

  SideEventItem({
    required this.id,
    required this.title,
    required this.category,
    required this.venue,
    required this.time,
    required this.coordinator,
    required this.registeredCount,
    required this.maxCapacity,
    required this.status,
    required this.themeColor,
  });
}

class SideEventsScreen extends StatefulWidget {
  const SideEventsScreen({super.key});

  @override
  State<SideEventsScreen> createState() => _SideEventsScreenState();
}

class _SideEventsScreenState extends State<SideEventsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';

  final List<SideEventItem> _sideEvents = [
    SideEventItem(
      id: 'SE-01',
      title: 'Arabic Calligraphy Competition',
      category: 'Arts & Calligraphy',
      venue: 'Art Gallery - Hall B',
      time: '10:00 AM - 12:30 PM',
      coordinator: 'Ustad Jalal',
      registeredCount: 24,
      maxCapacity: 30,
      status: 'Live',
      themeColor: const Color(0xFF8B5CF6),
    ),
    SideEventItem(
      id: 'SE-02',
      title: 'Meelad Quiz Championship',
      category: 'Academic & Quiz',
      venue: 'Auditorium Stage 2',
      time: '02:00 PM - 04:00 PM',
      coordinator: 'Ustad Shafi',
      registeredCount: 16,
      maxCapacity: 20,
      status: 'Scheduled',
      themeColor: const Color(0xFF3B82F6),
    ),
    SideEventItem(
      id: 'SE-03',
      title: 'Islamic History Exhibition Stall',
      category: 'Exhibition',
      venue: 'Exhibition Hall 1',
      time: '09:00 AM - 05:00 PM',
      coordinator: 'Ustad Rafeeq',
      registeredCount: 45,
      maxCapacity: 50,
      status: 'Live',
      themeColor: const Color(0xFF10B981),
    ),
    SideEventItem(
      id: 'SE-04',
      title: 'Seerah Essay Writing',
      category: 'Literary Contests',
      venue: 'Exam Hall C',
      time: '11:00 AM - 01:00 PM',
      coordinator: 'Ustad Farooq',
      registeredCount: 28,
      maxCapacity: 35,
      status: 'Completed',
      themeColor: const Color(0xFFF59E0B),
    ),
    SideEventItem(
      id: 'SE-05',
      title: 'Meelad Poster & Banner Design',
      category: 'Arts & Calligraphy',
      venue: 'Media Lab 1',
      time: '03:00 PM - 05:00 PM',
      coordinator: 'Ustad Niyaz',
      registeredCount: 18,
      maxCapacity: 25,
      status: 'Scheduled',
      themeColor: const Color(0xFFEC4899),
    ),
  ];

  void _openAddSideEventModal() {
    final titleCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final coordinatorCtrl = TextEditingController();
    final capacityCtrl = TextEditingController(text: '30');
    String categoryVal = 'Arts & Calligraphy';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Provider.of<AppState>(context).isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.cardDark : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.festival_rounded, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Text('Add New Side Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Event Title',
                        hintText: 'e.g. Qur’an Recitation Side Contest',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoryVal,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: ['Arts & Calligraphy', 'Academic & Quiz', 'Exhibition', 'Literary Contests', 'Sports & Games']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 12))))
                          .toList(),
                      onChanged: (val) => setModalState(() => categoryVal = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: venueCtrl,
                      decoration: InputDecoration(
                        labelText: 'Venue / Hall Location',
                        hintText: 'e.g. Hall B / Ground A',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: timeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Schedule Time',
                        hintText: 'e.g. 10:30 AM - 12:00 PM',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: coordinatorCtrl,
                      decoration: InputDecoration(
                        labelText: 'Coordinator in Charge',
                        hintText: 'e.g. Ustad Haneef',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Maximum Participant Capacity',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _sideEvents.add(SideEventItem(
                        id: 'SE-0${_sideEvents.length + 1}',
                        title: titleCtrl.text.trim(),
                        category: categoryVal,
                        venue: venueCtrl.text.trim().isNotEmpty ? venueCtrl.text.trim() : 'Side Venue',
                        time: timeCtrl.text.trim().isNotEmpty ? timeCtrl.text.trim() : 'TBD',
                        coordinator: coordinatorCtrl.text.trim().isNotEmpty ? coordinatorCtrl.text.trim() : 'Staff Coordinator',
                        registeredCount: 0,
                        maxCapacity: int.tryParse(capacityCtrl.text) ?? 30,
                        status: 'Scheduled',
                        themeColor: AppColors.secondary,
                      ));
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✨ Side Event "${titleCtrl.text.trim()}" added!'), backgroundColor: AppColors.success),
                    );
                  }
                },
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text('Save Side Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final filteredEvents = _sideEvents.where((e) {
      final matchesSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.venue.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.coordinator.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All Categories' || e.category == _selectedCategory;
      final matchesStatus = _selectedStatus == 'All Status' || e.status == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    final liveCount = _sideEvents.where((e) => e.status == 'Live').length;
    final scheduledCount = _sideEvents.where((e) => e.status == 'Scheduled').length;
    final totalRegs = _sideEvents.fold<int>(0, (sum, e) => sum + e.registeredCount);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
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
                            color: AppColors.secondary.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.festival_rounded, color: AppColors.secondary, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Side Events & Exhibitions',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Coordinate off-stage contests, sports, calligraphy, and cultural stalls',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openAddSideEventModal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Add Side Event', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Metrics Overview Bar
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Side Events',
                    value: '${_sideEvents.length}',
                    subtitle: 'Scheduled Contests',
                    icon: Icons.event_available_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Live / Ongoing Contests 🔴',
                    value: '$liveCount Events',
                    subtitle: 'Currently Active Now',
                    icon: Icons.sensors_rounded,
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Scheduled Upcoming',
                    value: '$scheduledCount Events',
                    subtitle: 'Awaiting Start',
                    icon: Icons.schedule_rounded,
                    color: AppColors.secondary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'Total Participants Registered',
                    value: '$totalRegs Students',
                    subtitle: 'Across All Contests',
                    icon: Icons.how_to_reg_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Bar & Dropdown Filters
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search event title, venue or coordinator...',
                        hintStyle: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.secondary),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(height: 30, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                  const SizedBox(width: 16),
                  // Category Dropdown
                  DropdownButton<String>(
                    value: _selectedCategory,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                    items: ['All Categories', 'Arts & Calligraphy', 'Academic & Quiz', 'Exhibition', 'Literary Contests', 'Sports & Games']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                  const SizedBox(width: 16),
                  Container(height: 30, width: 1, color: isDark ? Colors.white24 : Colors.black12),
                  const SizedBox(width: 16),
                  // Status Dropdown
                  DropdownButton<String>(
                    value: _selectedStatus,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondary),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textLight : AppColors.textDark),
                    dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                    items: ['All Status', 'Live', 'Scheduled', 'Completed']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Side Events Grid Cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.6,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: filteredEvents.length,
              itemBuilder: (context, idx) {
                final event = filteredEvents[idx];

                Color statusColor = AppColors.secondary;
                String statusBadge = '⏳ Scheduled';
                if (event.status == 'Live') {
                  statusColor = AppColors.error;
                  statusBadge = '🔴 LIVE NOW';
                } else if (event.status == 'Completed') {
                  statusColor = AppColors.success;
                  statusBadge = '✅ Completed';
                }

                final capacityPct = (event.registeredCount / event.maxCapacity * 100).clamp(0, 100);

                return GlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: event.themeColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: event.themeColor.withAlpha(70)),
                            ),
                            child: Text(
                              event.category,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 10, color: event.themeColor),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: statusColor.withAlpha(80)),
                            ),
                            child: Text(
                              statusBadge,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11, color: statusColor),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        event.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(event.venue, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(width: 14),
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(event.time, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Coordinator: ${event.coordinator}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('${event.registeredCount} / ${event.maxCapacity} Registered', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: event.themeColor)),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Capacity Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: capacityPct / 100,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(event.themeColor),
                        ),
                      ),

                      const Spacer(),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (event.registeredCount < event.maxCapacity) {
                                  setState(() {
                                    event.registeredCount += 1;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('✅ Registered new candidate for ${event.title}!'), backgroundColor: AppColors.success),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('⚠️ Max capacity reached for this side event!'), backgroundColor: AppColors.error),
                                  );
                                }
                              },
                              icon: const Icon(Icons.person_add_rounded, size: 16),
                              label: Text('Register Student', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: event.themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              setState(() {
                                event.status = val;
                              });
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Live', child: Text('Set Status: LIVE')),
                              const PopupMenuItem(value: 'Scheduled', child: Text('Set Status: Scheduled')),
                              const PopupMenuItem(value: 'Completed', child: Text('Set Status: Completed')),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                              ),
                              child: const Icon(Icons.more_vert_rounded, size: 18),
                            ),
                          ),
                        ],
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

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
