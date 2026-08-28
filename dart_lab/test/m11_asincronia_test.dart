import 'dart:async';

import 'package:dart_lab/m11_asincronia.dart';
import 'package:test/test.dart';

Future<String> _tarda(String etiqueta, int milisegundos) =>
    Future<String>.delayed(
      Duration(milliseconds: milisegundos),
      () => etiqueta,
    );

void main() {
  group('m11-1 ordenDeEjecucion', () {
    test('lo anterior al await corre antes de devolver el control', () {
      final bitacora = <String>[];
      unawaited(ordenDeEjecucion(bitacora));
      expect(bitacora, <String>['antes del await']);
    });

    test('al completarse tiene los dos pasos en orden', () async {
      final bitacora = await ordenDeEjecucion(<String>[]);
      expect(bitacora, <String>['antes del await', 'despues del await']);
    });
  });

  group('m11-2 enSecuencia', () {
    test('devuelve los dos resultados en orden', () async {
      expect(
        await enSecuencia(() => _tarda('a', 5), () => _tarda('b', 1)),
        <String>['a', 'b'],
      );
    });

    test('la segunda empieza despues de la primera', () async {
      final orden = <String>[];
      await enSecuencia(
        () async {
          orden.add('empieza a');
          await _tarda('a', 10);
          orden.add('termina a');
          return 'a';
        },
        () async {
          orden.add('empieza b');
          return 'b';
        },
      );
      expect(orden, <String>['empieza a', 'termina a', 'empieza b']);
    });
  });

  group('m11-3 enParalelo', () {
    test(
      'conserva el orden de los argumentos, no el de finalizacion',
      () async {
        expect(
          await enParalelo(
            () => _tarda('lenta', 20),
            () => _tarda('rapida', 1),
          ),
          <String>['lenta', 'rapida'],
        );
      },
    );

    test('las dos arrancan antes de que termine la primera', () async {
      final orden = <String>[];
      await enParalelo(
        () async {
          orden.add('empieza a');
          await _tarda('a', 20);
          return 'a';
        },
        () async {
          orden.add('empieza b');
          return 'b';
        },
      );
      expect(orden, <String>['empieza a', 'empieza b']);
    });
  });

  group('m11-4 contarHasta', () {
    test('emite de uno a n', () async {
      expect(await contarHasta(4).toList(), <int>[1, 2, 3, 4]);
    });

    test('cero no emite nada', () async {
      expect(await contarHasta(0).toList(), isEmpty);
    });

    test('rechaza un n negativo', () {
      expect(contarHasta(-1).toList(), throwsRangeError);
    });
  });

  group('m11-5 paresDuplicados y recolectar', () {
    test('filtra y transforma conservando el orden', () async {
      expect(await paresDuplicados(contarHasta(6)).toList(), <int>[4, 8, 12]);
    });

    test('recolectar devuelve los valores sin error', () async {
      final resultado = await recolectar(contarHasta(3));
      expect(resultado.valores, <int>[1, 2, 3]);
      expect(resultado.error, isNull);
    });

    test('recolectar conserva lo emitido antes del fallo', () async {
      Stream<int> falla() async* {
        yield 1;
        yield 2;
        throw StateError('se rompio');
      }

      final resultado = await recolectar(falla());
      expect(resultado.valores, <int>[1, 2]);
      expect(resultado.error, contains('se rompio'));
    });
  });
}
