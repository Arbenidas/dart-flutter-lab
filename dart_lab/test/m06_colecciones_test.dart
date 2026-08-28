import 'package:dart_lab/m06_colecciones.dart';
import 'package:test/test.dart';

void main() {
  group('m06-1 totalesPagados', () {
    test('conserva solo los pagados y su orden', () {
      expect(
        totalesPagados(<Pedido>[
          (pagado: true, total: 100),
          (pagado: false, total: 999),
          (pagado: true, total: 50),
        ]),
        <int>[100, 50],
      );
    });

    test('lista vacia produce lista vacia', () {
      expect(totalesPagados(<Pedido>[]), isEmpty);
    });

    test('devuelve una lista no ampliable', () {
      final totales = totalesPagados(<Pedido>[(pagado: true, total: 1)]);
      expect(() => totales.add(2), throwsUnsupportedError);
    });

    test('no modifica la entrada', () {
      final pedidos = <Pedido>[(pagado: true, total: 1)];
      totalesPagados(pedidos);
      expect(pedidos, hasLength(1));
    });
  });

  group('m06-2 etiquetasUnicas', () {
    test('normaliza espacios y mayusculas', () {
      expect(etiquetasUnicas(<String>[' Dart ', 'dart', 'DART']), <String>{
        'dart',
      });
    });

    test('descarta cadenas vacias', () {
      expect(etiquetasUnicas(<String>['', '   ', 'flutter']), <String>{
        'flutter',
      });
    });

    test('conserva etiquetas distintas', () {
      expect(etiquetasUnicas(<String>['dart', 'flutter']), <String>{
        'dart',
        'flutter',
      });
    });
  });

  group('m06-3 indexarPor', () {
    test('indexa por la clave elegida', () {
      final indice = indexarPor<String, int>(<String>[
        'ana',
        'leon',
        'martina',
      ], (n) => n.length);
      expect(indice, <int, String>{3: 'ana', 4: 'leon', 7: 'martina'});
    });

    test('rechaza claves repetidas', () {
      expect(
        () => indexarPor<String, int>(<String>['ana', 'ada'], (n) => n.length),
        throwsArgumentError,
      );
    });

    test('coleccion vacia produce mapa vacio', () {
      expect(indexarPor<String, String>(<String>[], (n) => n), isEmpty);
    });
  });

  group('m06-4 contarPorClave', () {
    test('cuenta cuantos caen en cada clave', () {
      expect(
        contarPorClave<String, int>(<String>[
          'ana',
          'leo',
          'ada',
          'juan',
        ], (n) => n.length),
        <int, int>{3: 3, 4: 1},
      );
    });

    test('coleccion vacia produce mapa vacio', () {
      expect(contarPorClave<String, int>(<String>[], (n) => n.length), isEmpty);
    });
  });

  group('m06-5 primeroQueCumple', () {
    test('devuelve el primero que cumple', () {
      expect(primeroQueCumple<int>(<int>[1, 2, 3, 4], (n) => n.isEven), 2);
    });

    test('devuelve null cuando ninguno cumple', () {
      expect(primeroQueCumple<int>(<int>[1, 3], (n) => n.isEven), isNull);
    });

    test('deja de evaluar apenas encuentra uno', () {
      var evaluaciones = 0;
      primeroQueCumple<int>(<int>[1, 2, 3, 4, 5], (n) {
        evaluaciones++;
        return n.isEven;
      });
      expect(evaluaciones, 2, reason: 'No debe recorrer toda la coleccion.');
    });
  });
}
