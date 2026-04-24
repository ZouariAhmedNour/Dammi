// import 'dart:io';

// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:userapp/models/donor_card_model.dart';

// Future<File> generateDonorCardPdf({
//   required String fullName,
//   required DonorCard card,
// }) async {
//   final pdf = pw.Document();

//   final date = card.dateEditionCarte != null
//       ? '${card.dateEditionCarte!.day.toString().padLeft(2, '0')}/'
//           '${card.dateEditionCarte!.month.toString().padLeft(2, '0')}/'
//           '${card.dateEditionCarte!.year}'
//       : '--';

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a6,
//       margin: pw.EdgeInsets.zero,
//       build: (context) {
//         return pw.Container(
//           padding: const pw.EdgeInsets.all(18),
//           decoration: const pw.BoxDecoration(
//             gradient: pw.LinearGradient(
//               colors: [
//                 PdfColor.fromInt(0xFFB30A12),
//                 PdfColor.fromInt(0xFF8F0710)
//               ],
//               begin: pw.Alignment.topLeft,
//               end: pw.Alignment.bottomRight,
//             ),
//           ),
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               /// HEADER
//               pw.Row(
//                 children: [
//                   pw.Text(
//                     'DAMMI',
//                     style: pw.TextStyle(
//                       color: PdfColors.white,
//                       fontSize: 14,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.Spacer(),
//                   pw.Container(
//                     padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 4),
//                     decoration: pw.BoxDecoration(
//                       color: PdfColors.white,
//                       borderRadius: pw.BorderRadius.circular(999),
//                     ),
//                     child: pw.Text(
//                       'CARTE DONNEUR',
//                       style: pw.TextStyle(
//                         color: PdfColor.fromInt(0xFF8F0710),
//                         fontSize: 10,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               pw.SizedBox(height: 18),

//               /// NOM
//               pw.Text(
//                 fullName.toUpperCase(), // 🔥 amélioration
//                 style: pw.TextStyle(
//                   color: PdfColors.white,
//                   fontSize: 22,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),

//               pw.SizedBox(height: 6),

//               pw.Text(
//                 'Merci pour votre engagement solidaire',
//                 style: const pw.TextStyle(
//                   color: PdfColors.white,
//                   fontSize: 11,
//                 ),
//               ),

//               pw.SizedBox(height: 18),

//               /// 🔥 CARD INFO (plus propre)
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(16),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.white,
//                   borderRadius: pw.BorderRadius.circular(18),
//                 ),
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'Groupe sanguin',
//                       style: pw.TextStyle(
//                         fontSize: 10,
//                         color: PdfColors.grey700,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       card.groupeSanguin,
//                       style: pw.TextStyle(
//                         fontSize: 18,
//                         fontWeight: pw.FontWeight.bold,
//                         color: PdfColor.fromInt(0xFF8F0710),
//                       ),
//                     ),

//                     pw.SizedBox(height: 10),

//                     pw.Text(
//                       'Nombre de dons',
//                       style: pw.TextStyle(
//                         fontSize: 10,
//                         color: PdfColors.grey700,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       '${card.nbDon}',
//                       style: pw.TextStyle(
//                         fontSize: 16,
//                         fontWeight: pw.FontWeight.bold,
//                       ),
//                     ),

//                     pw.SizedBox(height: 10),

//                     pw.Text(
//                       'Date d\'édition',
//                       style: pw.TextStyle(
//                         fontSize: 10,
//                         color: PdfColors.grey700,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       date,
//                       style: const pw.TextStyle(fontSize: 14),
//                     ),

//                     if ((card.lieuCollecte ?? '').isNotEmpty) ...[
//                       pw.SizedBox(height: 10),
//                       pw.Text(
//                         'Lieu',
//                         style: pw.TextStyle(
//                           fontSize: 10,
//                           color: PdfColors.grey700,
//                         ),
//                       ),
//                       pw.SizedBox(height: 4),
//                       pw.Text(
//                         card.lieuCollecte!,
//                         style: const pw.TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 10),

//               /// FOOTER
//               pw.Text(
//                 'Carte donneur officielle',
//                 style: const pw.TextStyle(
//                   color: PdfColors.white,
//                   fontSize: 10,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     ),
//   );

//   final bytes = await pdf.save();
//   final dir = await getApplicationDocumentsDirectory();
//   final file = File('${dir.path}/carte_donneur_${card.id}.pdf');

//   await file.writeAsBytes(bytes, flush: true);
//   return file;
// }

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:userapp/models/donor_card_model.dart';

// ─── Palette ───────────────────────────────────────────────────────────────
const _crimsonLight = PdfColor.fromInt(0xFFB30A12);
const _crimsonDark  = PdfColor.fromInt(0xFF6B0509);
const _gold         = PdfColor.fromInt(0xFFD4AF37);
const _goldDark     = PdfColor.fromInt(0xFFB8932A);

// ─── Dimensions ────────────────────────────────────────────────────────────
// ID-1 standard (credit-card size): 85.6 × 54 mm
final _cardW = 85.6 * PdfPageFormat.mm;
final _cardH = 54.0 * PdfPageFormat.mm;

Future<File> generateDonorCardPdf({
  required String fullName,
  required DonorCard card,
}) async {
  final pdf = pw.Document();

  final date = card.dateEditionCarte != null
      ? '${card.dateEditionCarte!.day.toString().padLeft(2, '0')}/'
          '${card.dateEditionCarte!.month.toString().padLeft(2, '0')}/'
          '${card.dateEditionCarte!.year}'
      : '--';

  final cardFormat = PdfPageFormat(_cardW, _cardH);
  final leftW      = _cardW * 0.38;   // left crimson panel
  final dividerW   = 2.5;             // gold divider
  final rightW     = _cardW - leftW - dividerW;

  pdf.addPage(
    pw.Page(
      pageFormat: cardFormat,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Stack(
        children: [
          // ── RIGHT PANEL background (white) ──────────────────────────────
          pw.Positioned(
            left: leftW + dividerW,
            top: 0,
            child: pw.Container(
              width: rightW,
              height: _cardH,
              color: PdfColors.white,
            ),
          ),

          // ── LEFT PANEL background (crimson gradient) ─────────────────────
          pw.Positioned(
            left: 0,
            top: 0,
            child: pw.Container(
              width: leftW,
              height: _cardH,
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [_crimsonLight, _crimsonDark],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── DECORATION: dot grid on left panel ──────────────────────────
          pw.Positioned(
            left: 0,
            top: 0,
            child: pw.SizedBox(
              width: leftW,
              height: _cardH,
              child: pw.CustomPaint(
                painter: (canvas, size) {
                  canvas.setFillColor(
                    const PdfColor(1, 1, 1, 0.12),
                  );
                  const spacing = 8.0;
                  const r = 1.0;
                  for (double x = 4; x < size.x; x += spacing) {
                    for (double y = 4; y < size.y; y += spacing) {
                      canvas
                        ..drawEllipse(x, y, r, r)
                        ..fillPath();
                    }
                  }
                },
              ),
            ),
          ),

          // ── DECORATION: large semi-transparent circle (bottom-left) ─────
          pw.Positioned(
            left: -leftW * 0.22,
            bottom: -_cardH * 0.35,
            child: pw.Container(
              width: leftW * 1.05,
              height: leftW * 1.05,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: const PdfColor(1, 1, 1, 0.08),
              ),
            ),
          ),

          // ── DECORATION: small circle (top-right of left panel) ──────────
          pw.Positioned(
            left: leftW * 0.55,
            top: -_cardH * 0.18,
            child: pw.Container(
              width: _cardH * 0.6,
              height: _cardH * 0.6,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: const PdfColor(1, 1, 1, 0.06),
              ),
            ),
          ),

          // ── DECORATION: medical cross (static, top-left of left panel) ──
          pw.Positioned(
            left: 7,
            top: 7,
            child: pw.Opacity(
              opacity: 0.18,
              child: pw.SizedBox(
                width: 14,
                height: 14,
                child: pw.CustomPaint(
                  painter: (canvas, size) {
                    canvas.setFillColor(PdfColors.white);
                    // Vertical bar
                    canvas
                      ..drawRect(size.x * 0.38, 0, size.x * 0.24, size.y)
                      ..fillPath();
                    // Horizontal bar
                    canvas
                      ..drawRect(0, size.y * 0.38, size.x, size.y * 0.24)
                      ..fillPath();
                  },
                ),
              ),
            ),
          ),

          // ── DECORATION: large ghost circle on right panel (bottom-right) ─
          pw.Positioned(
            left: _cardW - _cardH * 0.75,
            top: _cardH * 0.35,
            child: pw.Container(
              width: _cardH * 0.9,
              height: _cardH * 0.9,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                color: const PdfColor(0.561, 0.027, 0.063, 0.04),
              ),
            ),
          ),

          // ── GOLD DIVIDER ─────────────────────────────────────────────────
          pw.Positioned(
            left: leftW,
            top: 0,
            child: pw.Container(
              width: dividerW,
              height: _cardH,
              decoration: const pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [_gold, _goldDark],
                  begin: pw.Alignment.topCenter,
                  end: pw.Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── LEFT PANEL CONTENT: blood type + label ───────────────────────
          pw.Positioned(
            left: 0,
            top: 0,
            child: pw.SizedBox(
              width: leftW,
              height: _cardH,
              child: pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      card.groupeSanguin,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 34,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(width: 28, height: 1.5, color: _gold),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'GROUPE\nSANGUIN',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: const PdfColor(1, 1, 1, 0.65),
                        fontSize: 6.5,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── RIGHT PANEL CONTENT ──────────────────────────────────────────
          pw.Positioned(
            left: leftW + dividerW,
            top: 0,
            child: pw.SizedBox(
              width: rightW,
              height: _cardH,
              child: pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(12, 9, 10, 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // ── Header: brand + badge ──────────────────────────────
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'DAMMI',
                        style: pw.TextStyle(
                          color: _crimsonLight,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: _crimsonLight, width: 0.6),
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'DONNEUR',
                          style: pw.TextStyle(
                            color: _crimsonLight,
                            fontSize: 5.5,
                            letterSpacing: 1.2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Separator ─────────────────────────────────────────
                  pw.Container(height: 0.5, color: PdfColors.grey300),

                  // ── Full name ─────────────────────────────────────────
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _label('NOM & PRÉNOM'),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        fullName.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.black,
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  // ── Dons + Date ───────────────────────────────────────
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _label('DONS EFFECTUÉS'),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              '${card.nbDon}',
                              style: pw.TextStyle(
                                color: _crimsonLight,
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _label("DATE D'ÉDITION"),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              date,
                              style: pw.TextStyle(
                                color: PdfColors.black,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Lieu (optional) ───────────────────────────────────
                  if ((card.lieuCollecte ?? '').isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _label('LIEU DE COLLECTE'),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          card.lieuCollecte!,
                          style: const pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),

                  // ── Separator ─────────────────────────────────────────
                  pw.Container(height: 0.5, color: PdfColors.grey300),

                  // ── Footer ────────────────────────────────────────────
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'CARTE OFFICIELLE DU DONNEUR',
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 5,
                          letterSpacing: 0.8,
                        ),
                      ),
                      pw.Text(
                        'ID: ${card.id}',
                        style: pw.TextStyle(
                          color: PdfColors.grey,
                          fontSize: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    ),
  );

  final bytes = await pdf.save();
  final dir   = await getApplicationDocumentsDirectory();
  final file  = File('${dir.path}/carte_donneur_${card.id}.pdf');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

// ── Helper: small uppercase label ───────────────────────────────────────────
pw.Widget _label(String text) => pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.grey600,
        fontSize: 5.5,
        letterSpacing: 1.2,
      ),
    );
