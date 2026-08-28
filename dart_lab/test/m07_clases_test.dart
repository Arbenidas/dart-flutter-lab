import 'package:dart_lab/m07_clases.dart';
import 'package:test/test.dart';

void main() {
  group('m07-1 Porcentaje valida al construir', () {
    test('acepta los extremos', () {
      expect(Porcentaje(0).valor, 0);
      expect(Porcentaje(100).valor, 100);
    });

    test('rechaza por debajo de cero', () {
      expect(() => Porcentaje(-1), throwsRangeError);
    });

    test('rechaza por encima de cien', () {
      expect(() => Porcentaje(101), throwsRangeError);
    });

    test('dos porcentajes iguales son iguales', () {
      expect(Porcentaje(30), Porcentaje(30));
      expect(Porcentaje(30).hashCode, Porcentaje(30).hashCode);
    });
  });

  group('m07-2 Porcentaje.sumar preserva la invariante', () {
    test('suma dentro del rango', () {
      expect(Porcentaje(30).sumar(Porcentaje(20)), Porcentaje(50));
    });

    test('rechaza una suma que se pasa de cien', () {
      expect(() => Porcentaje(80).sumar(Porcentaje(30)), throwsRangeError);
    });

    test('no modifica los operandos', () {
      final a = Porcentaje(30);
      final b = Porcentaje(20);
      a.sumar(b);
      expect(a.valor, 30);
      expect(b.valor, 20);
    });
  });

  group('m07-3 Porcentaje.desdeFraccion', () {
    test('convierte y redondea', () {
      expect(Porcentaje.desdeFraccion(0.5), Porcentaje(50));
      expect(Porcentaje.desdeFraccion(0.333), Porcentaje(33));
      expect(Porcentaje.desdeFraccion(0.335), Porcentaje(34));
    });

    test('acepta los extremos', () {
      expect(Porcentaje.desdeFraccion(0), Porcentaje(0));
      expect(Porcentaje.desdeFraccion(1), Porcentaje(100));
    });

    test('rechaza fracciones fuera de rango', () {
      expect(() => Porcentaje.desdeFraccion(-0.1), throwsRangeError);
      expect(() => Porcentaje.desdeFraccion(1.1), throwsRangeError);
    });
  });

  group('m07-4 RangoFecha', () {
    final inicio = DateTime.utc(2026, 1, 1);
    final fin = DateTime.utc(2026, 1, 11);

    test('rechaza un inicio posterior al fin', () {
      expect(() => RangoFecha(inicio: fin, fin: inicio), throwsArgumentError);
    });

    test('acepta inicio igual a fin', () {
      expect(RangoFecha(inicio: inicio, fin: inicio).duracionEnDias, 0);
    });

    test('calcula la duracion en dias', () {
      expect(RangoFecha(inicio: inicio, fin: fin).duracionEnDias, 10);
    });

    test('contiene incluye los extremos', () {
      final rango = RangoFecha(inicio: inicio, fin: fin);
      expect(rango.contiene(inicio), isTrue);
      expect(rango.contiene(fin), isTrue);
      expect(rango.contiene(DateTime.utc(2026, 1, 5)), isTrue);
      expect(rango.contiene(DateTime.utc(2025, 12, 31)), isFalse);
      expect(rango.contiene(DateTime.utc(2026, 1, 12)), isFalse);
    });
  });

  group('m07-5 Bitacora protege su lista', () {
    test('agrega y expone entradas', () {
      final bitacora = Bitacora()..agregar('Primera');
      expect(bitacora.entradas, <String>['Primera']);
    });

    test('recorta espacios', () {
      final bitacora = Bitacora()..agregar('  Primera  ');
      expect(bitacora.entradas, <String>['Primera']);
    });

    test('rechaza entradas vacias', () {
      expect(() => Bitacora().agregar('   '), throwsArgumentError);
    });

    test('la lista expuesta no se puede modificar', () {
      final bitacora = Bitacora()..agregar('Primera');
      expect(() => bitacora.entradas.add('Colada'), throwsUnsupportedError);
      expect(bitacora.entradas, hasLength(1));
    });
  });
}
