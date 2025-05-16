import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../helpers/db_helper.dart';  // Importamos el helper

class AddEditGastoScreen extends StatefulWidget {
  final Gasto? gasto;

  AddEditGastoScreen({this.gasto});

  @override
  _AddEditGastoScreenState createState() => _AddEditGastoScreenState();
}

class _AddEditGastoScreenState extends State<AddEditGastoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.gasto != null) {
      _descripcionController.text = widget.gasto!.descripcion;
      _categoriaController.text = widget.gasto!.categoria;
      _montoController.text = widget.gasto!.monto.toString();
      _fecha = widget.gasto!.fecha;
    }
  }

  void _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      final nuevoGasto = Gasto(
        id: widget.gasto?.id,  // Si es edición, conserva el id
        descripcion: _descripcionController.text,
        categoria: _categoriaController.text,
        monto: double.parse(_montoController.text),
        fecha: _fecha,
      );

      if (widget.gasto == null) {
        // Insertar nuevo gasto
        await DBHelper.insertGasto(nuevoGasto);
      } else {
        // Actualizar gasto existente
        await DBHelper.updateGasto(nuevoGasto);
      }

      Navigator.of(context).pop(true); // Retorna true para indicar que hubo cambios
    }
  }

  Future<void> _seleccionarFecha() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fechaSeleccionada != null) {
      setState(() {
        _fecha = fechaSeleccionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gasto == null ? 'Agregar Gasto' : 'Editar Gasto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(labelText: 'Categoría'),
                validator: (value) =>
                    value!.isEmpty ? 'Ingrese una categoría' : null,
              ),
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Ingrese un monto';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Fecha: ${_fecha.toLocal().toString().split(' ')[0]}',
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _seleccionarFecha,
                    child: Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _guardarGasto,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
