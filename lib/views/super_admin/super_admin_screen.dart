import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/madrasa_model.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../widgets/glass_card.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  // 1. Delete Confirmation Alert Dialog
  void _showDeleteMadrasaConfirmationDialog(BuildContext context, AppState appState, MadrasaModel madrasa) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Delete Madrasa Confirmation',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? AppColors.textLight : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this Madrasa from the network?',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.domain_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            madrasa.madrasaName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            'Reg No: ${madrasa.madrasaRegNo} • Coordinator: ${madrasa.coordinatorName}',
                            style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.subtextLight : AppColors.subtextDark,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                appState.deleteMadrasa(madrasa.madrasaId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${madrasa.madrasaName} deleted successfully.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Delete Madrasa',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. Add / Edit Madrasa Modal Bottom Sheet (Scrollable & Overflow-Protected)
  void _showMadrasaFormBottomSheet(BuildContext context, AppState appState, {MadrasaModel? madrasa}) {
    final isEditing = madrasa != null;
    final nameController = TextEditingController(text: madrasa?.madrasaName ?? '');
    final regNoController = TextEditingController(text: madrasa?.madrasaRegNo ?? '');
    final addressController = TextEditingController(text: madrasa?.address ?? '');
    final coordNameController = TextEditingController(text: madrasa?.coordinatorName ?? '');
    final coordPhoneController = TextEditingController(text: madrasa?.coordinatorPhone ?? '');

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
                final currentRegNo = regNoController.text;
                final currentCoordName = coordNameController.text;

                final autoMadrasaId = MadrasaModel.generateMadrasaId(currentRegNo);
                final autoEmail = MadrasaModel.generateEmail(currentCoordName, currentRegNo);
                final autoPassword = MadrasaModel.generatePassword(currentCoordName, currentRegNo);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Indicator Bar
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
                          child: Icon(isEditing ? Icons.edit_note_rounded : Icons.domain_add_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEditing ? 'Edit Madrasa Details' : 'Register New Madrasa',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? AppColors.textLight : AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            // Fillable Field 1: Madrasa Name
                            Text('Madrasa Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Al-Azhar Central Academy',
                                prefixIcon: Icon(Icons.school_outlined, size: 20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),

                            // Fillable Field 2: Registration Number
                            Text('Madrasa Registration No (RegNo)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: regNoController,
                              enabled: !isEditing,
                              decoration: const InputDecoration(
                                hintText: 'e.g. REG101',
                                prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),

                            // Fillable Field 3: Address
                            Text('Address / Campus Location', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Grand Campus, Calicut Zone A',
                                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),

                            // Fillable Field 4: Coordinator Name
                            Text('Coordinator Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: coordNameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Usthad Ahmed Hudawi',
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),

                            // Fillable Field 5: Coordinator Phone No
                            Text('Coordinator Phone No', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.textLight : AppColors.textDark)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: coordPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'e.g. +91 9876543210',
                                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 20),

                            // Auto-Generated Properties Preview Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Auto-Generated Credentials:',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAutoDetailRow('Madrasa ID:', isEditing ? madrasa.madrasaId : autoMadrasaId, isDark),
                                  const SizedBox(height: 6),
                                  _buildAutoDetailRow('Coordinator Email:', isEditing ? madrasa.email : autoEmail, isDark),
                                  const SizedBox(height: 6),
                                  _buildAutoDetailRow('Portal Password:', isEditing ? madrasa.password : autoPassword, isDark),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty || regNoController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter Madrasa Name and RegNo'), backgroundColor: AppColors.error),
                            );
                            return;
                          }

                          final newMadrasa = MadrasaModel(
                            madrasaId: isEditing ? madrasa.madrasaId : autoMadrasaId,
                            madrasaName: nameController.text.trim(),
                            madrasaRegNo: regNoController.text.trim(),
                            address: addressController.text.trim(),
                            coordinatorName: coordNameController.text.trim(),
                            coordinatorPhone: coordPhoneController.text.trim(),
                            email: isEditing ? madrasa.email : autoEmail,
                            password: isEditing ? madrasa.password : autoPassword,
                            createdAt: isEditing ? madrasa.createdAt : DateTime.now().toString().substring(0, 16),
                          );

                          if (isEditing) {
                            appState.updateMadrasa(newMadrasa);
                          } else {
                            appState.addMadrasa(newMadrasa);
                            if (newMadrasa.coordinatorPhone.isNotEmpty) {
                              WhatsAppHelper.sendMadrasaRegistrationWelcomeMsg(
                                context: context,
                                madrasa: newMadrasa,
                              );
                            }
                          }

                          Navigator.of(bottomSheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Madrasa updated successfully!' : 'New Madrasa registered & WhatsApp welcome message sent!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Register Madrasa to Firestore'),
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

  // 3. Details Viewing Modal Bottom Sheet (Scrollable & Overflow-Protected)
  void _showMadrasaDetailsBottomSheet(BuildContext context, MadrasaModel m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final isDark = Theme.of(bottomSheetContext).brightness == Brightness.dark;
        bool isPasswordVisible = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.madrasaName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? AppColors.textLight : AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Reg No: ${m.madrasaRegNo}',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
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
                          _buildDetailCard(context, 'Active Status (Last Login)', m.isOnline ? 'Online now' : m.lastActive, m.isOnline ? Icons.circle : Icons.circle_outlined, isDark),
                          const SizedBox(height: 10),
                          _buildDetailCard(context, 'Madrasa ID', m.madrasaId, Icons.badge_outlined, isDark),
                          const SizedBox(height: 10),
                          _buildDetailCard(context, 'Address / Location', m.address, Icons.location_on_outlined, isDark),
                          const SizedBox(height: 10),
                          _buildDetailCard(context, 'Coordinator Name', m.coordinatorName, Icons.person_outline_rounded, isDark),
                          const SizedBox(height: 10),
                          _buildDetailCard(context, 'Coordinator Phone', m.coordinatorPhone, Icons.phone_outlined, isDark, isPhone: true),
                          const SizedBox(height: 10),
                          _buildDetailCard(context, 'Portal Email', m.email, Icons.email_outlined, isDark),
                          const SizedBox(height: 10),

                          // Password Detail Card with View Toggle
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.accent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Portal Password', style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                                      Text(
                                        isPasswordVisible ? m.password : '••••••••••••',
                                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.accent),
                                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                  tooltip: isPasswordVisible ? 'Hide Password' : 'Show Password',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: m.password));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Password copied to clipboard!'), backgroundColor: AppColors.primary),
                                    );
                                  },
                                  tooltip: 'Copy Password',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDetailCard(context, 'Registration Timestamp', m.createdAt, Icons.event_rounded, isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAutoDetailRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text('$label ', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context, String label, String value, IconData icon, bool isDark, {bool isPhone = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.subtextLight : AppColors.subtextDark)),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isPhone && value.isNotEmpty && value != 'N/A')
            IconButton(
              icon: const Icon(Icons.chat_bubble_rounded, size: 18, color: Color(0xFF25D366)),
              onPressed: () => WhatsAppHelper.openWhatsAppChat(context: context, phone: value),
              tooltip: 'Send WhatsApp Message',
            ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard!'), backgroundColor: AppColors.primary),
              );
            },
            tooltip: 'Copy',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      'Super Admin Control Panel',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textLight : AppColors.textDark,
                      ),
                    ),
                    Text(
                      'Manage Madrasa registrations, coordinator permissions, and festival clusters.',
                      style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.subtextLight : AppColors.subtextDark),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showMadrasaFormBottomSheet(context, appState),
                  icon: const Icon(Icons.domain_add_rounded),
                  label: const Text('Add New Madrasa'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Madrasas Directory Cards Grid
            Text(
              'Registered Madrasa Institutes (${appState.madrasas.length})',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
            ),
            const SizedBox(height: 14),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 420,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                mainAxisExtent: 210,
              ),
              itemCount: appState.madrasas.length,
              itemBuilder: (context, idx) {
                final m = appState.madrasas[idx];
                return InkWell(
                  onTap: () => _showMadrasaDetailsBottomSheet(context, m),
                  borderRadius: BorderRadius.circular(20),
                  child: GlassCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: m.isOnline ? AppColors.success : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isDark ? AppColors.cardDark : Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.madrasaName,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.textLight : AppColors.textDark),
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
                                      const SizedBox(width: 4),
                                      Text(
                                        m.isOnline ? 'Online now' : m.lastActive,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: m.isOnline ? FontWeight.bold : FontWeight.normal,
                                          color: m.isOnline ? AppColors.success : (isDark ? AppColors.subtextLight : AppColors.subtextDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Edit & Delete Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  tooltip: 'Edit Madrasa',
                                  onPressed: () => _showMadrasaFormBottomSheet(context, appState, madrasa: m),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  tooltip: 'Delete Madrasa',
                                  onPressed: () => _showDeleteMadrasaConfirmationDialog(context, appState, m),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Coordinator: ${m.coordinatorName}',
                                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? AppColors.textLight : AppColors.textDark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      m.email,
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
