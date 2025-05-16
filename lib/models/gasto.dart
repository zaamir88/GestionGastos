class Gasto {
  int? id;
  String descripcion;
  String categoria;
  double monto;
  DateTime fecha;

  Gasto({
    this.id,
    required this.descripcion,
    required this.categoria,
    required this.monto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'categoria': categoria,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      descripcion: map['descripcion'],
      categoria: map['categoria'],
      monto: map['monto'] is int ? (map['monto'] as int).toDouble() : map['monto'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}

