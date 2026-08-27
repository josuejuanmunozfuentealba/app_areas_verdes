// Script para crear un PDF de prueba simple
// Ejecutar con: dart run bin/crear_pdf_prueba.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  print('Creando PDF de prueba...');

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'CATASTRO DE PRUEBA',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Plaza: Plaza de Prueba'),
            pw.Text('Inspector: Test'),
            pw.Text('Fecha: 2026-08-26'),
            pw.SizedBox(height: 20),
            pw.Container(
              width: 200,
              height: 200,
              color: PdfColors.green200,
              child: pw.Center(
                child: pw.Text(
                  'Imagen de prueba',
                  style: const pw.TextStyle(color: PdfColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  final bytes = await pdf.save();
  final file = File('test_simple.pdf');
  await file.writeAsBytes(bytes);

  print('✅ PDF creado: ${file.absolute.path}');
  print('   Tamaño: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
}
