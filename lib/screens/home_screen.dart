import 'package:flutter/material.dart';
import 'package:gestion_gastos/screens/add_edit_gasto_screen.dart';
import 'package:gestion_gastos/screens/pantalla_grafico.dart';
import 'package:gestion_gastos/helpers/db_helper.dart';
import 'package:gestion_gastos/models/gasto.dart';
import 'package:gestion_gastos/helpers/export_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Gasto> _gastos = [];
  List<Gasto> _gastosFiltrados = [];
  String? _categoriaSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  List<String> categorias = ['Comida', 'Automovil', 'Salud', 'Recreacion','Hogar', 'Otros'];

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    final gastos = await DBHelper.getGastos();
    setState(() {
      _gastos = gastos;
      _gastosFiltrados = gastos;
    });
  }

  void _filtrarGastos() {
    List<Gasto> gastosFiltrados = _gastos;

    if (_categoriaSeleccionada != null && _categoriaSeleccionada!.isNotEmpty) {
      gastosFiltrados = gastosFiltrados
          .where((g) => g.categoria == _categoriaSeleccionada)
          .toList();
    }

    if (_fechaInicio != null) {
      gastosFiltrados = gastosFiltrados
          .where((g) => g.fecha.isAfter(_fechaInicio!) || g.fecha.isAtSameMomentAs(_fechaInicio!))
          .toList();
    }

    if (_fechaFin != null) {
      gastosFiltrados = gastosFiltrados
          .where((g) => g.fecha.isBefore(_fechaFin!) || g.fecha.isAtSameMomentAs(_fechaFin!))
          .toList();
    }

    setState(() {
      _gastosFiltrados = gastosFiltrados;
    });
  }

  void _irAGraficos() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaGrafico()),
    );
  }

  void _irAAgregarGasto() async {
    final resultado = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditGastoScreen()),
    );
    if (resultado == true) {
      _cargarGastos();
      _filtrarGastos();
    }
  }

  Future<void> _exportarDatos() async {
    if (_gastosFiltrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay gastos para exportar.')),
      );
      return;
    }
    await ExportHelper.exportarYCompartir(_gastosFiltrados);
  }

  Future<void> _seleccionarFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
      });
      _filtrarGastos();
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
      });
      _filtrarGastos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _irAGraficos,
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _exportarDatos,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Dropdown para categoría
                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text('Filtrar por categoría'),
                    value: _categoriaSeleccionada,
                    isExpanded: true,
                    items: [null, ...categorias].map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria ?? 'Todas'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSeleccionada = value;
                      });
                      _filtrarGastos();
                    },
                  ),
                ),

                // Botones para fecha inicio y fin
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _seleccionarFechaInicio,
                  tooltip: _fechaInicio == null
                      ? 'Fecha Inicio'
                      : 'Inicio: ${_fechaInicio!.toLocal().toString().split(' ')[0]}',
                ),
                IconButton(
                  icon: const Icon(Icons.date_range_outlined),
                  onPressed: _seleccionarFechaFin,
                  tooltip: _fechaFin == null
                      ? 'Fecha Fin'
                      : 'Fin: ${_fechaFin!.toLocal().toString().split(' ')[0]}',
                ),

                // Botón para limpiar filtros
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _categoriaSeleccionada = null;
                      _fechaInicio = null;
                      _fechaFin = null;
                      _gastosFiltrados = _gastos;
                    });
                  },
                  tooltip: 'Limpiar filtros',
                ),
              ],
            ),
          ),

          Expanded(
            child: _gastosFiltrados.isEmpty
                ? const Center(child: Text('No hay gastos para mostrar.'))
                : ListView.builder(
                    itemCount: _gastosFiltrados.length,
                    itemBuilder: (ctx, index) {
                      final gasto = _gastosFiltrados[index];
                      return ListTile(
                        title: Text(gasto.descripcion),
                        subtitle: Text(gasto.categoria),
                        trailing: Text('\$${gasto.monto.toStringAsFixed(2)}'),
                        // Editar al tocar el item:
                        onTap: () async {
                          final resultado = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddEditGastoScreen(gasto: gasto),
                            ),
                          );
                          if (resultado == true) {
                            _cargarGastos();
                            _filtrarGastos();
                          }
                        },
                        // Eliminar con pulsación larga
                        onLongPress: () async {
                          final confirmacion = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar gasto'),
                              content: const Text('¿Está seguro que desea eliminar este gasto?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );

                          if (confirmacion == true) {
                            await DBHelper.deleteGasto(gasto.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gasto eliminado')),
                            );
                            _cargarGastos();
                            _filtrarGastos();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _irAAgregarGasto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
