import 'package:dart_lab/m10_errores.dart';
import 'package:test/test.dart';

void main() {
  group('m10-1 DatoInvalido', () {
    test('conserva campo y motivo', () {
      const error = DatoInvalido('edad', 'vacia');
      expect(error.campo, 'edad');
      expect(error.motivo, 'vacia');
    });

    test('su texto nombra el campo', () {
      expect(const DatoInvalido('edad', 'vacia').toString(), contains('edad'));
    });

    test('es una Exception, no un Error', () {
      expect(const DatoInvalido('edad', 'vacia'), isA<Exception>());
    });
  });

  group('m10-2 parsearEdad traduce el fallo', () {
    test('acepta una edad valida', () {
      expect(parsearEdad(' 30 '), 30);
    });

    test('traduce el formato invalido a DatoInvalido', () {
      expect(() => parsearEdad('abc'), throwsA(isA<DatoInvalido>()));
    });

    test('no deja escapar la FormatException original', () {
      expect(() => parsearEdad('abc'), isNot(throwsFormatException));
    });

    test('rechaza una edad fuera de rango', () {
      expect(() => parsearEdad('500'), throwsA(isA<DatoInvalido>()));
      expect(() => parsearEdad('-1'), throwsA(isA<DatoInvalido>()));
    });

    test('el motivo incluye el dato recibido', () {
      try {
        parsearEdad('abc');
        fail('deberia haber lanzado');
      } on DatoInvalido catch (error) {
        expect(error.motivo, contains('abc'));
      }
    });
  });

  group('m10-3 conRegistro y el orden de finally', () {
    test('en el camino feliz registra inicio, exito y cierre', () {
      final bitacora = <String>[];
      final resultado = conRegistro<int>(bitacora, () => 42);
      expect(resultado, 42);
      expect(bitacora, <String>['inicio', 'exito', 'cierre']);
    });

    test('ante un fallo registra inicio, fallo y cierre', () {
      final bitacora = <String>[];
      expect(
        () => conRegistro<int>(bitacora, () => throw StateError('x')),
        throwsStateError,
      );
      expect(bitacora, <String>['inicio', 'fallo', 'cierre']);
    });

    test('relanza el error original sin envolverlo', () {
      expect(
        () => conRegistro<int>(
          <String>[],
          () => throw const DatoInvalido('a', 'b'),
        ),
        throwsA(isA<DatoInvalido>()),
      );
    });
  });

  group('m10-4 sumarEdades no se detiene ante un dato malo', () {
    test('suma las validas y junta los rechazos', () {
      final resultado = sumarEdades(<String>['30', 'abc', '20', '500']);
      expect(resultado.total, 50);
      expect(resultado.rechazos, hasLength(2));
    });

    test('sin entradas devuelve cero y ningun rechazo', () {
      final resultado = sumarEdades(<String>[]);
      expect(resultado.total, 0);
      expect(resultado.rechazos, isEmpty);
    });

    test('todas invalidas no lanza', () {
      final resultado = sumarEdades(<String>['a', 'b']);
      expect(resultado.total, 0);
      expect(resultado.rechazos, hasLength(2));
    });
  });

  group('m10-5 mensajeParaUsuario', () {
    test('nombra el campo ante un DatoInvalido', () {
      expect(
        mensajeParaUsuario(const DatoInvalido('edad', 'vacia')),
        contains('edad'),
      );
    });

    test('no filtra el motivo tecnico', () {
      expect(
        mensajeParaUsuario(const DatoInvalido('edad', 'ruta/interna/secreta')),
        isNot(contains('ruta/interna/secreta')),
      );
    });

    test('tiene un mensaje generico para lo desconocido', () {
      expect(
        mensajeParaUsuario(StateError('interno')),
        isNot(contains('interno')),
      );
    });
  });
}
