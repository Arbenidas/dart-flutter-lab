import 'package:dart_lab/m04_control.dart';
import 'package:test/test.dart';

void main() {
  group('m04-1 clasificarEdad', () {
    test('negativa', () => expect(clasificarEdad(-3), 'invalida'));
    test('recien nacido', () => expect(clasificarEdad(0), 'infancia'));
    test('borde 12', () => expect(clasificarEdad(12), 'infancia'));
    test('borde 13', () => expect(clasificarEdad(13), 'adolescencia'));
    test('borde 17', () => expect(clasificarEdad(17), 'adolescencia'));
    test('borde 18', () => expect(clasificarEdad(18), 'adultez'));
    test('borde 64', () => expect(clasificarEdad(64), 'adultez'));
    test('borde 65', () => expect(clasificarEdad(65), 'vejez'));
    test('muy mayor', () => expect(clasificarEdad(101), 'vejez'));
  });

  group('m04-2 tipoDeDia', () {
    test('lunes', () => expect(tipoDeDia('lunes'), 'habil'));
    test('dias intermedios', () {
      expect(tipoDeDia('martes'), 'habil');
      expect(tipoDeDia('miercoles'), 'habil');
      expect(tipoDeDia('jueves'), 'habil');
    });
    test('viernes', () => expect(tipoDeDia('viernes'), 'habil'));
    test('sabado', () => expect(tipoDeDia('sabado'), 'fin de semana'));
    test('domingo', () => expect(tipoDeDia('domingo'), 'fin de semana'));
    test('basura', () => expect(tipoDeDia('lunez'), 'dia invalido'));
  });

  group('m04-3 describirPunto', () {
    test('origen', () => expect(describirPunto((0, 0)), 'origen'));
    test('eje X', () => expect(describirPunto((3, 0)), 'sobre el eje X'));
    test('eje X negativo', () {
      expect(describirPunto((-4, 0)), 'sobre el eje X');
    });
    test('eje Y', () => expect(describirPunto((0, -2)), 'sobre el eje Y'));
    test('libre', () => expect(describirPunto((2, 5)), 'cuadrante libre'));
  });

  group('m04-4 contarVocales', () {
    test('palabra simple', () => expect(contarVocales('murcielago'), 5));
    test('mayusculas', () => expect(contarVocales('AEIOU'), 5));
    test('con tildes', () => expect(contarVocales('canción'), 3));
    test('sin vocales', () => expect(contarVocales('str'), 0));
    test('vacio', () => expect(contarVocales(''), 0));
  });

  group('m04-5 fibonacci', () {
    test('rechaza una cantidad negativa', () {
      expect(() => fibonacci(-1), throwsRangeError);
    });
    test('cero terminos', () => expect(fibonacci(0), isEmpty));
    test('un termino', () => expect(fibonacci(1), [0]));
    test('dos terminos', () => expect(fibonacci(2), [0, 1]));
    test('cinco terminos', () => expect(fibonacci(5), [0, 1, 1, 2, 3]));
    test('diez terminos', () {
      expect(fibonacci(10), [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]);
    });
  });
}
