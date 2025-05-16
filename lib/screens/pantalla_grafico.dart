import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../helpers/db_helper.dart';
import '../widgets/gastos_chart.dart';

class PantallaGrafico extends StatefulWidget {
  @override
  _PantallaGraficoState createState() => _PantallaGraficoState();
}

class _PantallaGraficoState extends State<PantallaGrafico> {
  List<Gasto> _gastos = [];

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  void _cargarGastos() async {
    // Método estático
    final gastos = await DBHelper.getGastos();
    setState(() {
      _gastos = gastos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gráfico de Gastos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _gastos.isEmpty
            ? const Center(child: Text('No hay datos para mostrar'))
            : GastosChart(gastos: _gastos),
      ),
    );
  }
}
