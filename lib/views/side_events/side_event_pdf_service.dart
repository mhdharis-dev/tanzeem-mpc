import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/models/side_event_model.dart';

class SideEventPdfService {
  static Future<Uint8List> generatePdfBytes(SideEventModel event, String madrasaName) async {
    final pdf = pw.Document();

    final sortedCandidates = List<SideEventParticipantModel>.from(event.participants);
    SideEventModel.calculateParticipantRanks(sortedCandidates);

    final topWinners = sortedCandidates.where((p) => p.point > 0).take(3).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- PREMIUM HEADER BANNER ---
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
                      madrasaName.isNotEmpty ? madrasaName.toUpperCase() : 'TANZEEM MEELAD COMPETITION 2026',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      event.sideEventName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'OFFICIAL SIDE EVENT COMPETITION RESULT CERTIFICATE',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.teal100,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // --- EVENT METADATA SUMMARY CARD ---
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.teal200, width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Event ID', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text(event.sideEventId, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Category', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text(event.participantsCategory, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Scheduled Date & Time', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${event.scheduledDate} (${event.scheduledTime})', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Max Mark', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${event.sideEventMaxPoint} Pts', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ]),
                    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                      pw.Text('Total Rounds', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${event.rounds.length} Round(s)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ]),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // --- TOP WINNERS PODIUM SHOWCASE SECTION ---
              if (topWinners.isNotEmpty) ...[
                pw.Text(
                  'EVENT POSITION WINNERS',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900, letterSpacing: 0.5),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: topWinners.map((w) {
                    PdfColor bgColor = PdfColors.amber50;
                    PdfColor borderColor = PdfColors.amber600;
                    PdfColor badgeBg = PdfColors.amber600;
                    String rankTitle = '1st Place (Gold)';

                    if (w.rank == 2) {
                      bgColor = PdfColors.blueGrey50;
                      borderColor = PdfColors.blueGrey400;
                      badgeBg = PdfColors.blueGrey600;
                      rankTitle = '2nd Place (Silver)';
                    } else if (w.rank == 3) {
                      bgColor = PdfColors.orange50;
                      borderColor = PdfColors.orange600;
                      badgeBg = PdfColors.orange600;
                      rankTitle = '3rd Place (Bronze)';
                    }

                    final cleanClass = w.participantClass.toLowerCase().startsWith('class')
                        ? w.participantClass
                        : 'Class ${w.participantClass}';

                    return pw.Expanded(
                      child: pw.Container(
                        margin: const pw.EdgeInsets.only(right: 6),
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: bgColor,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: borderColor, width: 1),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: pw.BoxDecoration(color: badgeBg, borderRadius: pw.BorderRadius.circular(4)),
                              child: pw.Text(
                                rankTitle,
                                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              w.participantName,
                              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '$cleanClass (${w.participantDiv})',
                              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  w.teamName.isNotEmpty ? w.teamName : 'No Team',
                                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: badgeBg),
                                ),
                                pw.Text(
                                  '${w.point} Pts',
                                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                pw.SizedBox(height: 14),
              ],

              // --- PARTICIPANT RANKINGS TABLE ---
              pw.Text(
                'FULL CANDIDATE RANKINGS LIST',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900, letterSpacing: 0.5),
              ),
              pw.SizedBox(height: 6),

              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.teal800),
                headerHeight: 24,
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Rank Position', 'Participant ID', 'Student Name', 'Class & Div', 'House / Team', 'Final Score'],
                data: sortedCandidates.map((p) {
                  final rankLabel = p.rank == 1
                      ? '1st Rank (Gold)'
                      : (p.rank == 2 ? '2nd Rank (Silver)' : (p.rank == 3 ? '3rd Rank (Bronze)' : 'Rank #${p.rank}'));

                  final cleanClass = p.participantClass.toLowerCase().startsWith('class')
                      ? p.participantClass
                      : 'Class ${p.participantClass}';

                  return [
                    rankLabel,
                    p.participantId,
                    p.participantName,
                    '$cleanClass (${p.participantDiv})',
                    p.teamName.isNotEmpty ? p.teamName : 'Independent',
                    '${p.point} / ${event.sideEventMaxPoint}',
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // --- FOOTER SIGNATURE & VERIFICATION STAMP ---
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 10),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1, style: pw.BorderStyle.dashed)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Verified By: Meelad Coordinator Desk', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                        pw.Text('Generated On: ${DateTime.now().toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.teal700, width: 1.5, style: pw.BorderStyle.dashed),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text('OFFICIAL RESULT VERIFIED', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                          pw.Text('TANZEEM MEELAD CLUSTER', style: pw.TextStyle(fontSize: 7, color: PdfColors.teal700)),
                        ],
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Container(width: 130, height: 1, color: PdfColors.grey600),
                        pw.SizedBox(height: 4),
                        pw.Text('Chief Coordinator Signature', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> downloadResultPdf(SideEventModel event, String madrasaName) async {
    final pdfBytes = await generatePdfBytes(event, madrasaName);
    final filename = '${event.sideEventName.replaceAll(RegExp(r'\s+'), '_')}_Result.pdf';

    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
