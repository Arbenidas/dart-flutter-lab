/// MODULO 11 — Futures, async/await y streams
///
/// `async` no significa "en paralelo". Significa "esta funcion puede ceder el
/// turno en cada `await`".
library;

/// Registra el orden real en que corre una funcion async.
///
/// TODO(m11-1): agrega 'antes del await' a [bitacora], espera un
/// `Future<void>.delayed(Duration.zero)`, agrega 'despues del await' y
/// devuelve la bitacora. Todo lo anterior al primer `await` corre de forma
/// SINCRONA, antes de devolver el control a quien te llamo.
Future<List<String>> ordenDeEjecucion(List<String> bitacora) async {
  // TODO(m11-1): implementame.
  throw UnimplementedError('ordenDeEjecucion');
}

/// Ejecuta dos esperas una despues de la otra.
///
/// TODO(m11-2): la segunda no debe EMPEZAR hasta que la primera termine.
Future<List<String>> enSecuencia(
  Future<String> Function() primera,
  Future<String> Function() segunda,
) async {
  // TODO(m11-2): implementame.
  throw UnimplementedError('enSecuencia');
}

/// Lanza las dos y espera a que ambas terminen.
///
/// TODO(m11-3): usa `Future.wait`. El orden del resultado es el de los
/// ARGUMENTOS, no el de finalizacion. Ojo: `Future.wait` solo sirve cuando
/// las dos operaciones son independientes.
Future<List<String>> enParalelo(
  Future<String> Function() primera,
  Future<String> Function() segunda,
) {
  // TODO(m11-3): implementame.
  throw UnimplementedError('enParalelo');
}

/// Emite los numeros de 1 a [n]. Rechaza un n negativo con `RangeError`.
///
/// TODO(m11-4): implementame como `async*` con `yield`.
Stream<int> contarHasta(int n) {
  // TODO(m11-4): implementame.
  throw UnimplementedError('contarHasta');
}

/// Deja pasar solo los pares y los duplica, conservando el orden.
///
/// TODO(m11-5): un `Stream` tiene `where` y `map` igual que un `Iterable`.
Stream<int> paresDuplicados(Stream<int> origen) {
  // TODO(m11-5): implementame.
  throw UnimplementedError('paresDuplicados');
}

/// Convierte un stream en un resultado unico, tolerando el fallo.
///
/// TODO(m11-5): recorre con `await for` dentro de un `try`. Si el stream
/// falla, devuelve lo que alcanzaste a recibir y el texto del error. Perder
/// los valores previos seria peor que el fallo mismo.
Future<({List<int> valores, String? error})> recolectar(Stream<int> origen) {
  // TODO(m11-5): implementame.
  throw UnimplementedError('recolectar');
}
