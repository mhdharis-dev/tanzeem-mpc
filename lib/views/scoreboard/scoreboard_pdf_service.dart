import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/models/team_model.dart';

class ScoreboardPdfService {
  static Future<Uint8List> generateScoreboardPdfBytes({
    required List<TeamModel> teams,
    required List<Map<String, dynamic>> topPerformers,
    required String scopeCategory,
    required String madrasaName,
  }) async {
    final pdf = pw.Document();

    int totalPoints = teams.fold(0, (sum, t) => sum + t.overallPoint);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER BANNER ---
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal900,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      madrasaName.isNotEmpty ? madrasaName.toUpperCase() : 'TANZEEM MEELAD FESTIVAL 2026',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'OFFICIAL CHAMPIONSHIP SCOREBOARD',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'SCOPE: ${scopeCategory.toUpperCase()} • TOTAL POINTS DISTRIBUTED: $totalPoints PTS',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.teal100,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // --- TOP 3 PODIUM SUMMARY ---
              if (teams.isNotEmpty) ...[
                pw.Text(
                  'CHAMPIONSHIP PODIUM STANDINGS',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: List.generate(teams.length > 3 ? 3 : teams.length, (idx) {
                    final t = teams[idx];
                    final rankTitle = idx == 0 ? '🥇 CHAMPION' : (idx == 1 ? '🥈 2ND PLACE' : '🥉 3RD PLACE');
                    return pw.Expanded(
                      child: pw.Container(
                        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: idx == 0 ? PdfColors.amber50 : (idx == 1 ? PdfColors.grey100 : PdfColors.orange50),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(
                            color: idx == 0 ? PdfColors.amber400 : (idx == 1 ? PdfColors.grey400 : PdfColors.orange400),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(rankTitle, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                            pw.SizedBox(height: 4),
                            pw.Text(t.teamName, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                            pw.Text('House: ${t.teamHouse}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                            pw.SizedBox(height: 4),
                            pw.Text('${t.overallPoint} Pts', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                pw.SizedBox(height: 16),
              ],

              // --- HOUSE STANDINGS TABLE ---
              pw.Text(
                'HOUSE CHAMPIONSHIP STANDINGS',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
              ),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                headers: ['RANK', 'TEAM NAME', 'HOUSE', 'CAPTAIN', 'GOLD', 'SILVER', 'BRONZE', 'TOTAL MEDALS', 'POINTS'],
                data: teams.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final t = entry.value;
                  final m = t.overallMedals;
                  return [
                    '#$rank',
                    t.teamName,
                    t.teamHouse,
                    t.teamCaptain?.participantName ?? 'Unassigned',
                    '${m.firstCount}',
                    '${m.secondCount}',
                    '${m.thirdCount}',
                    '${m.firstCount + m.secondCount + m.thirdCount}',
                    '${t.overallPoint} Pts',
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 16),

              // --- TOP INDIVIDUAL PERFORMERS ---
              if (topPerformers.isNotEmpty) ...[
                pw.Text(
                  'TOP INDIVIDUAL STUDENT PERFORMERS',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                ),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  headers: ['RANK', 'STUDENT NAME', 'CHEST ID', 'CLASS', 'HOUSE TEAM', 'TOTAL POINTS'],
                  data: topPerformers.take(10).toList().asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final p = entry.value;
                    return [
                      '#$rank',
                      p['name'].toString(),
                      p['id'].toString(),
                      p['class'].toString(),
                      p['team'].toString(),
                      '${p['points']} Pts',
                    ];
                  }).toList(),
                ),
              ],

              pw.Spacer(),

              // --- FOOTER SIGNATURE & TIMESTAMP ---
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Report Generated via Tanzeem Meelad Coordinator Software', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Official Competition Records', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> downloadScoreboardPdf({
    required List<TeamModel> teams,
    required List<Map<String, dynamic>> topPerformers,
    required String scopeCategory,
    required String madrasaName,
  }) async {
    final pdfBytes = await generateScoreboardPdfBytes(
      teams: teams,
      topPerformers: topPerformers,
      scopeCategory: scopeCategory,
      madrasaName: madrasaName,
    );

    final filename = 'Scoreboard_${scopeCategory.replaceAll(' ', '_')}.pdf';
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }

  static Future<void> printScoreboardPdf({
    required List<TeamModel> teams,
    required List<Map<String, dynamic>> topPerformers,
    required String scopeCategory,
    required String madrasaName,
  }) async {
    final pdfBytes = await generateScoreboardPdfBytes(
      teams: teams,
      topPerformers: topPerformers,
      scopeCategory: scopeCategory,
      madrasaName: madrasaName,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Scoreboard_${scopeCategory.replaceAll(' ', '_')}',
    );
  }
}
