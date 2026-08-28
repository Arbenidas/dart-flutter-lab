/// MODULO 7 — Clases, invariantes y encapsulacion
///
/// Una invariante es algo que SIEMPRE es verdad sobre un objeto, desde que
/// se construye hasta que se destruye. Validarla una vez al construir vale
/// mas que comprobarla en cada consumidor.
library;

/// Un porcentaje entero entre 0 y 100 inclusive.
///
/// TODO(m07-1): valida la invariante en el constructor y lanza `RangeError`
/// si [valor] queda fuera. Implementa tambien `==` y `hashCode` para que dos
/// porcentajes iguales sean iguales.
class Porcentaje {
  Porcentaje(this.valor) {
    // TODO(m07-1): valida aqui.
    throw UnimplementedError('Porcentaje');
  }

  /// Construye desde una fraccion 0.0..1.0, redondeando al entero mas cercano.
  ///
  /// TODO(m07-3): implementame como `factory`. Rechaza NaN y valores fuera
  /// de 0..1. Un `factory` puede validar y elegir antes de construir; un
  /// constructor generativo no.
  factory Porcentaje.desdeFraccion(double fraccion) {
    // TODO(m07-3): implementame.
    throw UnimplementedError('Porcentaje.desdeFraccion');
  }

  final int valor;

  /// Suma dos porcentajes conservando la invariante.
  ///
  /// TODO(m07-2): devuelve un `Porcentaje` nuevo. No mutes ninguno de los dos
  /// operandos. Si la suma se pasa de 100, deja que la invariante lance.
  Porcentaje sumar(Porcentaje otro) {
    // TODO(m07-2): implementame.
    throw UnimplementedError('Porcentaje.sumar');
  }

  @override
  bool operator ==(Object other) => throw UnimplementedError('Porcentaje.==');

  @override
  int get hashCode => throw UnimplementedError('Porcentaje.hashCode');

  @override
  String toString() => '$valor%';
}

/// Un rango de fechas donde el inicio nunca es posterior al fin.
///
/// TODO(m07-4): valida la invariante al construir y lanza `ArgumentError`.
class RangoFecha {
  RangoFecha({required this.inicio, required this.fin}) {
    // TODO(m07-4): valida aqui.
    throw UnimplementedError('RangoFecha');
  }

  final DateTime inicio;
  final DateTime fin;

  /// Dias completos entre inicio y fin.
  int get duracionEnDias => throw UnimplementedError('duracionEnDias');

  /// Verdadero si [momento] cae dentro del rango, extremos incluidos.
  bool contiene(DateTime momento) => throw UnimplementedError('contiene');
}

/// Una bitacora que no deja mutar su lista desde afuera.
///
/// TODO(m07-5): guarda las entradas en una lista privada y expone una vista
/// de solo lectura. Recuerda D01: `final` protege la referencia, no el objeto.
class Bitacora {
  // ignore: unused_field
  final List<String> _entradas = <String>[];

  /// Vista de solo lectura de las entradas.
  List<String> get entradas => throw UnimplementedError('Bitacora.entradas');

  /// Agrega una entrada no vacia, recortando espacios.
  void agregar(String entrada) {
    // TODO(m07-5): implementame.
    throw UnimplementedError('Bitacora.agregar');
  }
}
