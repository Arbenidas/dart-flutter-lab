import 'package:dart_lab/m12_isolates.dart';
import 'package:test/test.dart';

void main() {
  group('m12-1 sumaDeCuadrados', () {
    test('calcula el caso conocido', () {
      expect(sumaDeCuadrados(3), 14);
      expect(sumaDeCuadrados(1), 1);
    });

    test('cero suma cero', () {
      expect(sumaDeCuadrados(0), 0);
    });

    test('rechaza un n negativo', () {
      expect(() => sumaDeCuadrados(-1), throwsRangeError);
    });
  });

  group('m12-2 sumaDeCuadradosEnIsolate', () {
    test('devuelve el mismo resultado que la version sincrona', () async {
      expect(await sumaDeCuadradosEnIsolate(1000), sumaDeCuadrados(1000));
    });

    test('propaga el fallo del otro isolate', () {
      expect(sumaDeCuadradosEnIsolate(-1), throwsA(isA<Error>()));
    });
  });

  group('m12-3 sumaDeCuadradosAdaptativa', () {
    test('resuelve igual por debajo del umbral', () async {
      expect(await sumaDeCuadradosAdaptativa(10, umbral: 1000), 385);
    });

    test('resuelve igual por encima del umbral', () async {
      expect(
        await sumaDeCuadradosAdaptativa(2000, umbral: 1000),
        sumaDeCuadrados(2000),
      );
    });
  });

  group('m12-4 noCompartenMemoria', () {
    test('la mutacion del otro isolate no llega de vuelta', () async {
      final resultado = await noCompartenMemoria(<int>[1, 2]);
      expect(resultado.aqui, <int>[1, 2]);
      expect(resultado.alla, <int>[1, 2, 999]);
    });

    test('son dos objetos distintos', () async {
      final original = <int>[1, 2];
      final resultado = await noCompartenMemoria(original);
      expect(identical(resultado.aqui, resultado.alla), isFalse);
    });
  });

  group('m12-5 bloqueaElIsolate', () {
    test('el ciclo sincrono corre antes que el temporizador', () async {
      final bitacora = await bloqueaElIsolate(1000);
      expect(bitacora.first, 'ciclo');
      expect(bitacora, contains('temporizador'));
    });
  });
}
