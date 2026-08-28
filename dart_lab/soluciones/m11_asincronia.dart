// SOLUCION MODULO 11

import 'dart:async';

/// Registra el orden real en que corre una funcion async.
/// Todo lo anterior al primer await es sincrono.
Future<List<String>> ordenDeEjecucion(List<String> bitacora) async {
  bitacora.add('antes del await');
  await Future<void>.delayed(Duration.zero);
  bitacora.add('despues del await');
  return bitacora;
}

/// Ejecuta dos esperas una despues de la otra.
Future<List<String>> enSecuencia(
  Future<String> Function() primera,
  Future<String> Function() segunda,
) async {
  return <String>[await primera(), await segunda()];
}

/// Lanza las dos y espera a que ambas terminen. El orden del resultado
/// es el de los argumentos, no el de finalizacion.
Future<List<String>> enParalelo(
  Future<String> Function() primera,
  Future<String> Function() segunda,
) {
  return Future.wait(<Future<String>>[primera(), segunda()]);
}

/// Emite los numeros de 1 a [n]. Rechaza un n negativo.
Stream<int> contarHasta(int n) async* {
  if (n < 0) {
    throw RangeError.value(n, 'n', 'Debe ser cero o mayor');
  }
  for (var i = 1; i <= n; i++) {
    yield i;
  }
}

/// Deja pasar solo los pares y los duplica, conservando el orden.
Stream<int> paresDuplicados(Stream<int> origen) =>
    origen.where((n) => n.isEven).map((n) => n * 2);

/// Convierte un stream en un resultado unico, tolerando el fallo.
Future<({List<int> valores, String? error})> recolectar(
  Stream<int> origen,
) async {
  final valores = <int>[];
  try {
    await for (final valor in origen) {
      valores.add(valor);
    }
    return (valores: valores, error: null);
  } catch (error) {
    return (valores: valores, error: error.toString());
  }
}
