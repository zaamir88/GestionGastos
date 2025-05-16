import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:gestion_gastos/models/gasto.dart';
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  static String generarCSV(List<Gasto> gastos) {
    final buffer = StringBuffer();
    buffer.writeln('Descripcion,Categoria,Monto,Fecha');

    for (var gasto in gastos) {
      final fechaStr = gasto.fecha.toIso8601String();
      buffer.writeln('${gasto.descripcion},${gasto.categoria},${gasto.monto},$fechaStr');
    }

    return buffer.toString();
  }

  static Future<String> guardarCSV(String csv) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/gastos_export.csv';
    final file = File(path);
    await file.writeAsString(csv);
    return path;
  }

  static Future<void> exportarYCompartir(List<Gasto> gastos) async {
    final csv = generarCSV(gastos);
    final path = await guardarCSV(csv);
    await Share.shareXFiles([XFile(path)], text: 'Mis gastos exportados');
  }
}
