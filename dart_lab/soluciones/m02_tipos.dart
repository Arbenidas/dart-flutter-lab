// SOLUCION MODULO 2 — leela DESPUES de intentarlo.
// No la copies: leela, cerra el archivo, y escribi la tuya de memoria.

String describirTipo(Object valor) {
  // El orden importa: `int` y `double` son ambos `num`, pero ninguno
  // es subtipo del otro. Preguntar por `num` primero seria un bug.
  if (valor is int) return 'entero';
  if (valor is double) return 'decimal';
  if (valor is String) return 'texto';
  if (valor is bool) return 'booleano';
  if (valor is List<Object?>) return 'lista';
  return 'otro';
}

double aCelsius(double fahrenheit) => (fahrenheit - 32) * 5 / 9;
// `/` siempre devuelve double en Dart, incluso 4 / 2. Si quisieras un
// int usarias `~/`. Esa es la unica division "entera" del lenguaje.

String formatearPrecio(int centavos) {
  if (centavos < 0) {
    throw RangeError.range(centavos, 0, null, 'centavos');
  }
  final pesos = centavos ~/ 100;
  final resto = centavos % 100;
  return '\$$pesos.${resto.toString().padLeft(2, '0')}';
  // El `\$` escapa el signo peso para que no lo confunda con una
  // interpolacion. `${...}` con llaves hace falta cuando la expresion
  // no es un identificador simple.
}

const List<String> diasHabiles = <String>[
  'lunes',
  'martes',
  'miercoles',
  'jueves',
  'viernes',
];

List<String> semanaCompleta() => <String>[...diasHabiles, 'sabado', 'domingo'];
// `...` es el spread operator: vuelca los elementos de una coleccion
// dentro de otra. La lista resultante es nueva y mutable.
