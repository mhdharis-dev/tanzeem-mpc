import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/models/participant_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../widgets/glass_card.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedClassFilter = 'All';
  String _selectedGenderFilter = 'All';

  void _showAddParticipantBottomSheet(BuildContext context, AppState appState) {
    final nextId = ParticipantModel.generateNextParticipantId(appState.realParticipants.length);

    final nameController = TextEditingController();
    final classController = TextEditingController(text: 'Class 5');
    final divisionController = TextEditingController(text: 'A');
    final parentNameController = TextEditingController();
    final phoneController = TextEditingController();

    String selectedGender = 'Male';
    String selectedCategory = 'Junior';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final isDark = Theme.of(bottomSheetContext).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
            ),
            padding: const EdgeInsets.all(24.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Register New Participant',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                              Text(
                                'Auto Generated ID: $nextId',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(bottomSheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Participant ID (Read-only Badge)
                            Text('Participant ID', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: Text(
                                nextId,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Student Name
                            Text('Student Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Ahammed Fayiz',
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Class & Division in a Row
                            Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Student Class', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: classController,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. Class 5',
                                          prefixIcon: Icon(Icons.school_outlined, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Division', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: divisionController,
                                        decoration: const InputDecoration(
                                          hintText: 'Default A',
                                          prefixIcon: Icon(Icons.grid_3x3_rounded, size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Gender Selection Choice Chips
                            Text('Gender', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            Row(
                              children: ['Male', 'Female'].map((g) {
                                final isSelected = selectedGender == g;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: ChoiceChip(
                                    label: Text(g, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                    selected: isSelected,
                                    onSelected: (val) {
                                      if (val) setState(() => selectedGender = g);
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),

                            // Competition Category Dropdown
                            Text('Category', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.category_outlined, size: 20),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Sub-Junior', child: Text('Sub-Junior')),
                                DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                                DropdownMenuItem(value: 'Senior', child: Text('Senior')),
                                DropdownMenuItem(value: 'Super Senior', child: Text('Super Senior')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedCategory = val);
                              },
                            ),
                            const SizedBox(height: 14),

                            // Parent Name
                            Text('Parent Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: parentNameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Usman Musliyar',
                                prefixIcon: Icon(Icons.family_restroom_rounded, size: 20),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Phone Number
                            Text('Phone Number', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 9876543210',
                                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter Student Name'), backgroundColor: AppColors.error),
                            );
                            return;
                          }

                          final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

                          final newParticipant = ParticipantModel(
                            participantId: nextId,
                            name: nameController.text.trim(),
                            studentClass: classController.text.trim(),
                            gender: selectedGender,
                            division: divisionController.text.trim().isNotEmpty ? divisionController.text.trim() : 'A',
                            category: selectedCategory,
                            parentName: parentNameController.text.trim(),
                            phoneNo: phoneController.text.trim(),
                            madrasaId: appState.madrasaId,
                            createdAt: nowStr,
                          );

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(bottomSheetContext);

                          await appState.addParticipantToFirestore(newParticipant);

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Participant ${newParticipant.name} (${newParticipant.participantId}) added to Firestore!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Save'),  
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategoryFilter = 'All';
      _selectedClassFilter = 'All';
      _selectedGenderFilter = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    final realParticipants = appState.realParticipants;

    // Filter Logic for Class, Category, Gender, and Search Query
    final filteredParticipants = realParticipants.where((p) {
      final q = _searchQuery.trim().toLowerCase();

      final matchesSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.participantId.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.studentClass.toLowerCase().contains(q) ||
          p.parentName.toLowerCase().contains(q) ||
          p.phoneNo.contains(q);

      if (!matchesSearch) return false;

      if (_selectedCategoryFilter != 'All' &&
          p.category.toLowerCase() != _selectedCategoryFilter.toLowerCase()) {
        return false;
      }

      if (_selectedClassFilter != 'All' &&
          p.studentClass.toLowerCase() != _selectedClassFilter.toLowerCase()) {
        return false;
      }

      if (_selectedGenderFilter != 'All' &&
          p.gender.toLowerCase() != _selectedGenderFilter.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();

    final hasActiveFilters = _searchQuery.isNotEmpty ||
        _selectedCategoryFilter != 'All' ||
        _selectedClassFilter != 'All' ||
        _selectedGenderFilter != 'All';

    final classOptions = ['All', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', 'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10','Class 11','Class 12'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title & Action Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 14,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Participant Directory',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Manage registered student competitors synced with Cloud Firestore.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    // Search Box
                    Container(
                      width: 280,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search participant, ID, class, parent...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _showAddParticipantBottomSheet(context, appState),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Add Participant'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Comprehensive Filter Toolbar Card (Category, Class, Gender)
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_alt_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Directory Filters',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
                          ),
                        ],
                      ),
                      if (hasActiveFilters)
                        TextButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
                          label: Text('Reset Filters', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.error)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      // 1. Category Filter Choice Chips
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: ['All', 'Sub-Junior', 'Junior', 'Senior', 'Super Senior'].map((cat) {
                              final isSel = _selectedCategoryFilter == cat;
                              return ChoiceChip(
                                label: Text(cat, style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedCategoryFilter = cat);
                                },
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // 2. Gender Filter Choice Chips
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            children: ['All', 'Male', 'Female'].map((gen) {
                              final isSel = _selectedGenderFilter == gen;
                              return ChoiceChip(
                                label: Text(
                                  gen == 'All' ? 'All Genders' : gen,
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                                ),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedGenderFilter = gen);
                                },
                                selectedColor: AppColors.secondary,
                                labelStyle: TextStyle(color: isSel ? Colors.white : (isDark ? AppColors.textLight : AppColors.textDark)),
                                backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      // 3. Class Wise Dropdown Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class Wise:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                          const SizedBox(height: 4),
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: classOptions.contains(_selectedClassFilter) ? _selectedClassFilter : 'All',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                                items: classOptions.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c == 'All' ? 'All Classes' : c),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedClassFilter = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Registered Participants Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cloud Participants (${filteredParticipants.length})',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                ),
                Text(
                  'Synced with Firestore',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Participant Grid or Empty State Card
            if (filteredParticipants.isEmpty)
              GlassCard(
                borderRadius: 24,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
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
                          'No Participants Found',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.textLight : AppColors.textDark),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasActiveFilters
                              ? 'No participants match the selected filter criteria. Try resetting filters.'
                              : 'No registered participants in Cloud Firestore. Click "Add Participant" to register.',
                          style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          textAlign: TextAlign.center,
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Reset All Filters'),
                          ),
                        ],
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
                  maxCrossAxisExtent: 380,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  mainAxisExtent: 195,
                ),
                itemCount: filteredParticipants.length,
                itemBuilder: (context, idx) {
                  final p = filteredParticipants[idx];
                  return GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p.participantId,
                                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                  if (p.phoneNo.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF25D366)),
                                      onPressed: () => WhatsAppHelper.openWhatsAppChat(context: context, phone: p.phoneNo),
                                      tooltip: 'WhatsApp Parent',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.name,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${p.studentClass} (Div ${p.division}) • ${p.category}',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Parent: ${p.parentName.isNotEmpty ? p.parentName : 'N/A'}',
                                style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Gender: ${p.gender} • Added: ${p.createdAt}',
                                style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
}
