import 'package:dart_lab/m02_tipos.dart';
import 'package:test/test.dart';

void main() {
  group('m02-1 describirTipo', () {
    test('reconoce enteros', () => expect(describirTipo(42), 'entero'));
    test('reconoce decimales', () => expect(describirTipo(3.5), 'decimal'));
    test('reconoce texto', () => expect(describirTipo('hola'), 'texto'));
    test('reconoce booleanos', () => expect(describirTipo(true), 'booleano'));
    test('reconoce listas', () => expect(describirTipo(<int>[1, 2]), 'lista'));
    test('reconoce listas de cualquier tipo', () {
      expect(describirTipo(<String>['Dart']), 'lista');
      expect(describirTipo(<Object?>[]), 'lista');
    });
    test('cae en otro', () => expect(describirTipo(<String, int>{}), 'otro'));

    // Trampa clasica: en Dart, `int` NO es subtipo de `double`.
    // Si tu implementacion pregunta por `num` antes que por `int`,
    // este test te lo va a decir.
    test('un int no se confunde con decimal', () {
      expect(describirTipo(7), isNot('decimal'));
    });
  });

  group('m02-2 aCelsius', () {
    test('punto de congelacion', () => expect(aCelsius(32), 0));
    test('punto de ebullicion', () => expect(aCelsius(212), 100));
    test('temperatura corporal', () {
      expect(aCelsius(98.6), closeTo(37, 0.01));
    });
    test('devuelve double, no int', () => expect(aCelsius(32), isA<double>()));
  });

  group('m02-3 formatearPrecio', () {
    test('caso normal', () => expect(formatearPrecio(1205), r'$12.05'));
    test('menos de un peso', () => expect(formatearPrecio(7), r'$0.07'));
    test('cero', () => expect(formatearPrecio(0), r'$0.00'));
    test('centenas exactas', () => expect(formatearPrecio(500), r'$5.00'));
    test('numero grande', () => expect(formatearPrecio(1234567), r'$12345.67'));
    test('rechaza centavos negativos', () {
      expect(() => formatearPrecio(-1), throwsRangeError);
    });
  });

  group('m02-4 const y canonicalizacion', () {
    test('diasHabiles tiene los cinco dias', () {
      expect(diasHabiles, [
        'lunes',
        'martes',
        'miercoles',
        'jueves',
        'viernes',
      ]);
    });

    test('diasHabiles es una constante canonicalizada', () {
      // Si la declaraste `const`, Dart reutiliza el MISMO objeto.
      // Si la declaraste `final`, esto falla: son dos listas distintas.
      expect(
        identical(diasHabiles, const <String>[
          'lunes',
          'martes',
          'miercoles',
          'jueves',
          'viernes',
        ]),
        isTrue,
        reason: 'diasHabiles debe declararse con const, no con final',
      );
    });
  });

  group('m02-5 semanaCompleta', () {
    test('devuelve los siete dias en orden', () {
      expect(semanaCompleta(), [
        'lunes',
        'martes',
        'miercoles',
        'jueves',
        'viernes',
        'sabado',
        'domingo',
      ]);
    });

    test('devuelve una copia mutable nueva', () {
      final primera = semanaCompleta()..add('otro');
      final segunda = semanaCompleta();

      expect(primera, hasLength(8));
      expect(segunda, hasLength(7));
      expect(identical(primera, segunda), isFalse);
      expect(diasHabiles, hasLength(5), reason: 'no debes mutar la constante');
    });
  });
}
