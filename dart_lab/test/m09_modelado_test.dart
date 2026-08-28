import 'package:dart_lab/m09_modelado.dart';
import 'package:test/test.dart';

void main() {
  group('m09-1 EstadoDescarga', () {
    test('cada estado trae etiqueta y si es final', () {
      expect(EstadoDescarga.pendiente.etiqueta, 'Pendiente');
      expect(EstadoDescarga.pendiente.esFinal, isFalse);
      expect(EstadoDescarga.completada.esFinal, isTrue);
      expect(EstadoDescarga.fallida.esFinal, isTrue);
    });

    test('declara exactamente cuatro estados', () {
      expect(EstadoDescarga.values, hasLength(4));
    });

    test('solo dos estados son finales', () {
      expect(EstadoDescarga.values.where((estado) => estado.esFinal).length, 2);
    });
  });

  group('m09-2 primeroONull', () {
    test('devuelve el primero cuando hay elementos', () {
      expect(primeroONull<int>(<int>[7, 8]), 7);
    });

    test('devuelve null con una coleccion vacia', () {
      expect(primeroONull<int>(<int>[]), isNull);
    });

    test('conserva el tipo del elemento', () {
      final String? primero = primeroONull<String>(<String>['dart']);
      expect(primero, 'dart');
    });
  });

  group('m09-3 separar devuelve un record con nombres', () {
    test('reparte segun la condicion', () {
      final resultado = separar<int>(<int>[1, 2, 3, 4], (n) => n.isEven);
      expect(resultado.cumplen, <int>[2, 4]);
      expect(resultado.resto, <int>[1, 3]);
    });

    test('coleccion vacia produce dos listas vacias', () {
      final resultado = separar<int>(<int>[], (n) => n.isEven);
      expect(resultado.cumplen, isEmpty);
      expect(resultado.resto, isEmpty);
    });

    test('conserva el orden dentro de cada grupo', () {
      final resultado = separar<String>(<String>[
        'ana',
        'leon',
        'ada',
        'juan',
      ], (n) => n.length == 3);
      expect(resultado.cumplen, <String>['ana', 'ada']);
      expect(resultado.resto, <String>['leon', 'juan']);
    });
  });

  group('m09-4 Resultado sellado', () {
    test('un valido lleva el valor', () {
      const resultado = Valido<int>(42);
      expect(resultado.valor, 42);
    });

    test('un invalido no admite lista vacia', () {
      expect(() => Invalido<int>(<String>[]), throwsArgumentError);
    });

    test('describir cubre los dos casos sin comodin', () {
      expect(describir<int>(const Valido<int>(42)), 'ok: 42');
      expect(describir<int>(Invalido<int>(<String>['a', 'b'])), 'error: a, b');
    });
  });

  group('m09-5 validarUsuario acumula problemas', () {
    test('acepta un usuario correcto y lo normaliza', () {
      final resultado = validarUsuario('  ana  ');
      expect(resultado, isA<Valido<String>>());
      expect((resultado as Valido<String>).valor, 'ana');
    });

    test('rechaza un usuario vacio', () {
      final resultado = validarUsuario('   ');
      expect(resultado, isA<Invalido<String>>());
      expect((resultado as Invalido<String>).mensajes, hasLength(1));
    });

    test('acumula varios problemas a la vez', () {
      final resultado = validarUsuario('${'a' * 21} b');
      expect(resultado, isA<Invalido<String>>());
      expect((resultado as Invalido<String>).mensajes, hasLength(2));
    });
  });
}
