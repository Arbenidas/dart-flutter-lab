// SOLUCION MODULO 4

String clasificarEdad(int edad) => switch (edad) {
  < 0 => 'invalida',
  <= 12 => 'infancia',
  <= 17 => 'adolescencia',
  <= 64 => 'adultez',
  _ => 'vejez',
};
// `< 0` y `<= 12` son patterns relacionales (Dart 3). Se evaluan en
// orden, de arriba hacia abajo. El `_` es el caso por defecto y hace
// que el switch sea exhaustivo: sin el, no compila como expresion.

String tipoDeDia(String dia) => switch (dia) {
  'lunes' || 'martes' || 'miercoles' || 'jueves' || 'viernes' => 'habil',
  'sabado' || 'domingo' => 'fin de semana',
  _ => 'dia invalido',
};

String describirPunto((int, int) punto) => switch (punto) {
  (0, 0) => 'origen',
  (_, 0) => 'sobre el eje X',
  (0, _) => 'sobre el eje Y',
  _ => 'cuadrante libre',
};
// Esto es destructuring: el pattern `(_, 0)` no compara el record
// completo, desarma sus dos campos y compara cada uno.

int contarVocales(String texto) {
  const vocales = 'aeiou';
  const conTilde = 'áéíóúü';
  var total = 0;
  for (final caracter in texto.toLowerCase().split('')) {
    if (vocales.contains(caracter) || conTilde.contains(caracter)) {
      total++;
    }
  }
  return total;
}

List<int> fibonacci(int n) {
  if (n < 0) {
    throw RangeError.range(n, 0, null, 'n');
  }
  final serie = <int>[];
  var anterior = 0;
  var actual = 1;
  for (var i = 0; i < n; i++) {
    serie.add(anterior);
    final siguiente = anterior + actual;
    anterior = actual;
    actual = siguiente;
  }
  return serie;
}
