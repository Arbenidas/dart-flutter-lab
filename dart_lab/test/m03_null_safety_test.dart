import 'package:dart_lab/m03_null_safety.dart';
import 'package:test/test.dart';

void main() {
  group('m03-1 saludar', () {
    test('con nombre', () => expect(saludar('Diego'), 'Hola, Diego'));
    test('con null', () => expect(saludar(null), 'Hola, desconocido'));
    test('con vacio', () => expect(saludar(''), 'Hola, desconocido'));
  });

  group('m03-2 longitudSegura', () {
    test('con texto', () => expect(longitudSegura('hola'), 4));
    test('con null', () => expect(longitudSegura(null), 0));
    test('con vacio', () => expect(longitudSegura(''), 0));
  });

  group('m03-3 primerNoVacio', () {
    test('encuentra el primero util', () {
      expect(primerNoVacio(['', '  ', 'aqui', 'alla']), 'aqui');
    });
    test('devuelve null si no hay ninguno', () {
      expect(primerNoVacio(['', '   ', '']), isNull);
    });
    test('lista vacia devuelve null', () {
      expect(primerNoVacio(<String>[]), isNull);
    });
  });

  group('m03-4 parsearEdad', () {
    test('numero valido', () => expect(parsearEdad('30'), 30));
    test('con espacios', () => expect(parsearEdad(' 30 '), 30));
    test('cero es valido', () => expect(parsearEdad('0'), 0));
    test('limite superior valido', () => expect(parsearEdad('130'), 130));
    test('texto no numerico', () => expect(parsearEdad('abc'), isNull));
    test('negativo', () => expect(parsearEdad('-1'), isNull));
    test('fuera de rango', () => expect(parsearEdad('500'), isNull));
    test('vacio', () => expect(parsearEdad(''), isNull));
    test('decimal no es edad', () => expect(parsearEdad('30.5'), isNull));
  });

  group('m03-5 SesionDeEstudio', () {
    test('cuenta los minutos', () {
      final sesion = SesionDeEstudio()..comenzar(DateTime(2026, 8, 23, 10, 0));
      expect(sesion.minutosHasta(DateTime(2026, 8, 23, 11, 30)), 90);
    });

    test('explota si se lee antes de comenzar', () {
      final sesion = SesionDeEstudio();
      expect(
        () => sesion.minutosHasta(DateTime(2026, 8, 23, 11, 30)),
        throwsA(
          predicate<Object>(
            _isLateInitializationError,
            'un LateInitializationError',
          ),
        ),
        reason: 'debe fallar por LateInitializationError, no por un throw tuyo',
      );
    });

    test('late final impide comenzar dos veces', () {
      final sesion = SesionDeEstudio()..comenzar(DateTime(2026, 8, 23));
      expect(
        () => sesion.comenzar(DateTime(2026, 8, 24)),
        throwsA(
          predicate<Object>(
            _isLateInitializationError,
            'un LateInitializationError',
          ),
        ),
      );
    });
  });
}

bool _isLateInitializationError(Object error) {
  final type = error.runtimeType.toString();
  return (type == 'LateError' || type == 'LateInitializationError') &&
      error.toString().contains('LateInitializationError');
}
