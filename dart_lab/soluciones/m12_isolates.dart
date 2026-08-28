// SOLUCION MODULO 12

import 'dart:async';
import 'dart:isolate';

/// Trabajo intensivo de CPU: suma los cuadrados de 1 a [n].
/// Es sincrono a proposito. Marcarlo async no lo volveria concurrente.
int sumaDeCuadrados(int n) {
  if (n < 0) {
    throw RangeError.value(n, 'n', 'Debe ser cero o mayor');
  }
  var total = 0;
  for (var i = 1; i <= n; i++) {
    total += i * i;
  }
  return total;
}

/// Mueve el calculo a otro isolate. El resultado se copia de vuelta.
Future<int> sumaDeCuadradosEnIsolate(int n) =>
    Isolate.run(() => sumaDeCuadrados(n));

/// Decide por tamano: por debajo del umbral el traslado cuesta mas que el
/// calculo, asi que conviene resolverlo en el isolate actual.
Future<int> sumaDeCuadradosAdaptativa(int n, {int umbral = 100000}) {
  return n < umbral
      ? Future<int>.value(sumaDeCuadrados(n))
      : sumaDeCuadradosEnIsolate(n);
}

/// Demuestra que dos isolates no comparten memoria: el de al lado recibe
/// una copia y su mutacion no llega de vuelta.
Future<({List<int> aqui, List<int> alla})> noCompartenMemoria(
  List<int> original,
) async {
  final alla = await Isolate.run(() => <int>[...original, 999]);
  return (aqui: original, alla: alla);
}

/// Registra el orden en que un ciclo de CPU y un temporizador se intercalan
/// dentro del MISMO isolate. El ciclo no cede el turno.
Future<List<String>> bloqueaElIsolate(int vueltas) async {
  final bitacora = <String>[];
  Timer.run(() => bitacora.add('temporizador'));
  sumaDeCuadrados(vueltas);
  bitacora.add('ciclo');
  await Future<void>.delayed(Duration.zero);
  return bitacora;
}
