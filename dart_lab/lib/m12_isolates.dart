/// MODULO 12 — Isolates y concurrencia
///
/// Un isolate tiene su propia memoria. No comparte objetos con nadie: lo que
/// cruza la frontera se copia.
library;

/// Trabajo intensivo de CPU: suma los cuadrados de 1 a [n].
///
/// TODO(m12-1): implementame con un `for`. Rechaza un n negativo con
/// `RangeError`. Es SINCRONO a proposito: marcarlo `async` no lo volveria
/// concurrente, solo cambiaria su firma.
int sumaDeCuadrados(int n) {
  // TODO(m12-1): implementame.
  throw UnimplementedError('sumaDeCuadrados');
}

/// Mueve el calculo a otro isolate.
///
/// TODO(m12-2): usa `Isolate.run`. El resultado se COPIA de vuelta, y un
/// fallo del otro isolate se propaga a este `Future`.
Future<int> sumaDeCuadradosEnIsolate(int n) {
  // TODO(m12-2): implementame.
  throw UnimplementedError('sumaDeCuadradosEnIsolate');
}

/// Decide por tamano.
///
/// TODO(m12-3): por debajo de [umbral] el traslado cuesta mas que el calculo,
/// asi que conviene resolverlo aqui mismo. El umbral es una decision que se
/// MIDE, no se adivina.
Future<int> sumaDeCuadradosAdaptativa(int n, {int umbral = 100000}) {
  // TODO(m12-3): implementame.
  throw UnimplementedError('sumaDeCuadradosAdaptativa');
}

/// Demuestra que dos isolates no comparten memoria.
///
/// TODO(m12-4): dentro de `Isolate.run`, devuelve una copia de [original] con
/// un 999 al final. Comprueba que [original] NO cambio de este lado.
Future<({List<int> aqui, List<int> alla})> noCompartenMemoria(
  List<int> original,
) {
  // TODO(m12-4): implementame.
  throw UnimplementedError('noCompartenMemoria');
}

/// Registra el orden en que un ciclo de CPU y un temporizador se intercalan
/// dentro del MISMO isolate.
///
/// TODO(m12-5): programa un `Timer.run` que anote 'temporizador', corre
/// `sumaDeCuadrados(vueltas)`, anota 'ciclo' y despues cede el turno con un
/// `await`. El ciclo sincrono no cede: el temporizador espera aunque su
/// duracion sea cero.
Future<List<String>> bloqueaElIsolate(int vueltas) {
  // TODO(m12-5): implementame.
  throw UnimplementedError('bloqueaElIsolate');
}
