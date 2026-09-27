import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ExportService {
  Future<File> generarPdfReporte({
    required String fecha,
    required String repartidor,
    required String observador,
    required bool fueEditado,
    String? ultimoEditor,
    String? fechaEdicion,
    required List<Map<String, dynamic>> productos,
    required String totalTraia,
    required String totalCargo,
    required String totalGeneral,
    required String valorTotal,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reporte', style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Text('Fecha: $fecha'),
              pw.Text('Repartidor: $repartidor'),
              pw.Text('Observador: $observador'),
              if (fueEditado) ...[
                pw.SizedBox(height: 5),
                pw.Text('Editado'),
                pw.Text('Ultimo editor: ${ultimoEditor ?? ''}'),
                pw.Text('Fecha edición: ${fechaEdicion ?? ''}'),
              ],
              pw.SizedBox(height: 20),
              pw.Text('Productos', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Producto'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Traía'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Cargó'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Total'),
                      ),
                    ],
                  ),
                  ...productos.map(
                    (producto) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(producto['nombre']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(producto['traia']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(producto['cargo']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(producto['total']),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Resumen', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text('Total traia: $totalTraia unidades'),
              pw.Text('Total cargo: $totalCargo unidades'),
              pw.Text('Total general: $totalGeneral unidades'),
              pw.Text('Valor total en buseta: $valorTotal'),
              pw.SizedBox(height: 15),
              pw.Text(
                'Nota: El valor total en buseta incluye todos los productos, tanto contables como no contables.',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/reporte_$fecha.pdf');

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> compartirPdf(File file) async {
    final params = ShareParams(
      files: [XFile(file.path)],
      text: 'Reporte en PDF',
    );
    await SharePlus.instance.share(params);
  }
}
