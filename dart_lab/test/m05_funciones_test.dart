import 'package:dart_lab/m05_funciones.dart';
import 'package:test/test.dart';

void main() {
  group('m05-1 aplicar', () {
    test('con una funcion anonima', () {
      expect(aplicar(5, (n) => n * n), 25);
    });
    test('con una funcion nombrada', () {
      int negar(int n) => -n;
      expect(aplicar(7, negar), -7);
    });
  });

  group('m05-2 etiqueta', () {
    test('por defecto', () => expect(etiqueta('hola'), 'hola'));
    test(
      'mayusculas',
      () => expect(etiqueta('hola', mayusculas: true), 'HOLA'),
    );
    test('prefijo', () => expect(etiqueta('hola', prefijo: '>> '), '>> hola'));
    test('el prefijo no se pone en mayusculas', () {
      expect(etiqueta('hola', prefijo: '>> ', mayusculas: true), '>> HOLA');
    });
    test('el orden de los argumentos con nombre da igual', () {
      expect(etiqueta('hola', mayusculas: true, prefijo: '# '), '# HOLA');
    });
  });

  group('m05-3 crearContador', () {
    test('cuenta hacia arriba', () {
      final contar = crearContador();
      expect(contar(), 1);
      expect(contar(), 2);
      expect(contar(), 3);
    });

    test('cada contador tiene su propio estado', () {
      final a = crearContador();
      final b = crearContador();
      a();
      a();
      expect(a(), 3);
      expect(b(), 1, reason: 'los contadores no deben compartir la variable');
    });
  });

  group('m05-4 multiplicadorPor', () {
    test('doble', () => expect(multiplicadorPor(2)(21), 42));
    test('por cero', () => expect(multiplicadorPor(0)(99), 0));
    test('dos multiplicadores no se pisan', () {
      final doble = multiplicadorPor(2);
      final triple = multiplicadorPor(3);
      expect(doble(10), 20);
      expect(triple(10), 30);
    });
  });

  group('m05-5 transformarTodos', () {
    test('transforma', () {
      expect(transformarTodos([1, 2, 3], (n) => n * 10), [10, 20, 30]);
    });
    test('no muta el original', () {
      final original = [1, 2, 3];
      transformarTodos(original, (n) => n * 10);
      expect(original, [1, 2, 3]);
    });
    test('lista vacia', () {
      expect(transformarTodos(<int>[], (n) => n), isEmpty);
    });
  });

  group('m05-6 medirMilisegundos', () {
    test('ejecuta la accion exactamente una vez', () {
      var ejecuciones = 0;
      medirMilisegundos(() => ejecuciones++);
      expect(ejecuciones, 1);
    });

    test('devuelve un numero no negativo', () {
      final ms = medirMilisegundos(() {
        var suma = 0;
        for (var i = 0; i < 100000; i++) {
          suma += i;
        }
        expect(suma, greaterThan(0));
      });
      expect(ms, greaterThanOrEqualTo(0));
    });
  });
}
