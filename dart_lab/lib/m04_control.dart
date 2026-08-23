/// MODULO 4 — Control de flujo, switch expressions y patterns
///
/// Dart 3 convirtio al `switch` en una herramienta de primera clase.
/// Ya no es el `switch` con `break` de C: es una EXPRESION que devuelve
/// un valor, y sabe desarmar objetos (destructuring). Vas a usar esto
/// todo el tiempo en Flutter para mapear estado a interfaz.
library;

/// Clasifica una edad.
///
///   < 0            -> 'invalida'
///   0 a 12         -> 'infancia'
///   13 a 17        -> 'adolescencia'
///   18 a 64        -> 'adultez'
///   65 en adelante -> 'vejez'
///
/// TODO(m04-1): escribilo primero con `if / else if`. Cuando pase el test,
/// BORRALO y reescribilo con una switch expression usando patterns
/// relacionales (`< 0 => ...`, `<= 12 => ...`). Compara las dos versiones.
String clasificarEdad(int edad) {
  throw UnimplementedError('clasificarEdad');
}

/// Devuelve 'habil' o 'fin de semana' segun el nombre del dia.
/// Cualquier otra cosa: 'dia invalido'.
///
/// TODO(m04-2): usa una switch expression con casos agrupados
/// (`'sabado' || 'domingo' => ...`). Nada de if encadenados. Las switch
/// expressions no escriben la palabra `case`; los switch statements si.
///
/// Ojo: una switch expression sobre String necesita un caso por defecto
/// (`_`), porque el compilador no puede probar que cubriste todo.
String tipoDeDia(String dia) {
  throw UnimplementedError('tipoDeDia');
}

/// Describe la posicion de un punto en el plano.
///
///   (0, 0)   -> 'origen'
///   (3, 0)   -> 'sobre el eje X'
///   (0, -2)  -> 'sobre el eje Y'
///   (2, 5)   -> 'cuadrante libre'
///
/// TODO(m04-3): recibi un record `(int, int)` y desarmalo con patterns:
///   (0, 0) => ...
///   (_, 0) => ...
/// El orden de los casos importa: el primero que coincide gana.
String describirPunto((int, int) punto) {
  throw UnimplementedError('describirPunto');
}

/// Cuenta las vocales (a, e, i, o, u, con o sin tilde) de [texto],
/// sin distinguir mayusculas.
///
/// TODO(m04-4): usa un `for (final caracter in texto.split(''))`.
/// Despues reescribilo con `texto.runes` o con
/// `texto.split('').where(...).length` y quedate con la version que
/// mejor se lea. Saber elegir es parte del ejercicio.
int contarVocales(String texto) {
  throw UnimplementedError('contarVocales');
}

/// La secuencia de Fibonacci hasta [n] terminos.
///
///   fibonacci(0) == []
///   fibonacci(1) == [0]
///   fibonacci(5) == [0, 1, 1, 2, 3]
///   fibonacci(-1) lanza RangeError
///
/// TODO(m04-5): valida `n >= 0` e implementalo con un `for`. Nada de
/// recursion todavia: la comparacion de rendimiento viene despues de aprender
/// a medir y de entender por que un benchmark necesita un entorno controlado.
List<int> fibonacci(int n) {
  throw UnimplementedError('fibonacci');
}
