import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gasto.dart';

class GastosChart extends StatelessWidget {
  final List<Gasto> gastos;

  const GastosChart({Key? key, required this.gastos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Agrupar gastos por categoría
    final Map<String, double> data = {};
    for (var gasto in gastos) {
      data[gasto.categoria] = (data[gasto.categoria] ?? 0) + gasto.monto;
    }

    final categorias = data.keys.toList();
    final montos = data.values.toList();

    return BarChart(
      BarChartData(
        maxY: (montos.isEmpty) ? 0 : montos.reduce((a, b) => a > b ? a : b) * 1.2,
        barGroups: List.generate(categorias.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: montos[index],
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < categorias.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(categorias[index], style: TextStyle(fontSize: 12)),
                  );
                }
                return SizedBox.shrink();
              },
              reservedSize: 42,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
      ),
    );
  }
}
