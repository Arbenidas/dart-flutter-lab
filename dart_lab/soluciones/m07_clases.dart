// SOLUCION MODULO 7

/// Un porcentaje entero entre 0 y 100 inclusive.
class Porcentaje {
  Porcentaje(this.valor) {
    if (valor < 0 || valor > 100) {
      throw RangeError.range(valor, 0, 100, 'valor');
    }
  }

  /// Construye desde una fraccion 0.0..1.0, redondeando al entero mas cercano.
  factory Porcentaje.desdeFraccion(double fraccion) {
    if (fraccion.isNaN || fraccion < 0 || fraccion > 1) {
      throw RangeError.value(fraccion, 'fraccion', 'Debe estar entre 0 y 1');
    }
    return Porcentaje((fraccion * 100).round());
  }

  final int valor;

  /// Suma dos porcentajes conservando la invariante.
  Porcentaje sumar(Porcentaje otro) => Porcentaje(valor + otro.valor);

  @override
  bool operator ==(Object other) => other is Porcentaje && other.valor == valor;

  @override
  int get hashCode => valor.hashCode;

  @override
  String toString() => '$valor%';
}

/// Un rango de fechas donde el inicio nunca es posterior al fin.
class RangoFecha {
  RangoFecha({required this.inicio, required this.fin}) {
    if (inicio.isAfter(fin)) {
      throw ArgumentError('inicio no puede ser posterior a fin');
    }
  }

  final DateTime inicio;
  final DateTime fin;

  /// Dias completos entre inicio y fin.
  int get duracionEnDias => fin.difference(inicio).inDays;

  /// Verdadero si [momento] cae dentro del rango, extremos incluidos.
  bool contiene(DateTime momento) =>
      !momento.isBefore(inicio) && !momento.isAfter(fin);
}

/// Una bitacora que no deja mutar su lista desde afuera.
class Bitacora {
  final List<String> _entradas = <String>[];

  /// Vista de solo lectura de las entradas.
  List<String> get entradas => List<String>.unmodifiable(_entradas);

  /// Agrega una entrada no vacia.
  void agregar(String entrada) {
    final normalizada = entrada.trim();
    if (normalizada.isEmpty) {
      throw ArgumentError.value(entrada, 'entrada', 'No puede estar vacia');
    }
    _entradas.add(normalizada);
  }
}
