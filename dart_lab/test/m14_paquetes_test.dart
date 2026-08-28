import 'package:dart_lab/m14_paquetes.dart';
import 'package:test/test.dart';

void main() {
  group('m14-1 Version.parsear', () {
    test('interpreta un texto valido', () {
      final version = Version.parsear('1.2.3');
      expect(version.mayor, 1);
      expect(version.menor, 2);
      expect(version.parche, 3);
    });

    test('rechaza un texto con menos partes', () {
      expect(() => Version.parsear('1.2'), throwsFormatException);
    });

    test('rechaza partes que no son enteros', () {
      expect(() => Version.parsear('1.x.3'), throwsFormatException);
      expect(() => Version.parsear('1.-2.3'), throwsFormatException);
    });

    test('su texto reconstruye la entrada', () {
      expect(Version.parsear('0.14.7').toString(), '0.14.7');
    });
  });

  group('m14-2 Version compara por precedencia', () {
    test('mayor manda sobre menor y parche', () {
      expect(Version(2, 0, 0) > Version(1, 99, 99), isTrue);
    });

    test('menor manda sobre parche', () {
      expect(Version(1, 2, 0) > Version(1, 1, 99), isTrue);
    });

    test('dos versiones iguales son iguales', () {
      expect(Version(1, 2, 3), Version(1, 2, 3));
      expect(Version(1, 2, 3).hashCode, Version(1, 2, 3).hashCode);
    });

    test('se pueden ordenar', () {
      final versiones = <Version>[
        Version(1, 2, 0),
        Version(0, 9, 9),
        Version(1, 10, 0),
      ]..sort();
      expect(versiones.map((v) => v.toString()).toList(), <String>[
        '0.9.9',
        '1.2.0',
        '1.10.0',
      ]);
    });
  });

  group('m14-3 satisfaceCaret con base estable', () {
    final base = Version(1, 2, 0);

    test('acepta parches y menores superiores', () {
      expect(satisfaceCaret(base, Version(1, 2, 5)), isTrue);
      expect(satisfaceCaret(base, Version(1, 9, 0)), isTrue);
    });

    test('rechaza una version anterior', () {
      expect(satisfaceCaret(base, Version(1, 1, 9)), isFalse);
    });

    test('rechaza la siguiente mayor', () {
      expect(satisfaceCaret(base, Version(2, 0, 0)), isFalse);
    });

    test('acepta la propia base', () {
      expect(satisfaceCaret(base, base), isTrue);
    });
  });

  group('m14-4 satisfaceCaret con base 0.x', () {
    final base = Version(0, 14, 0);

    test('acepta parches dentro de la misma menor', () {
      expect(satisfaceCaret(base, Version(0, 14, 7)), isTrue);
    });

    test('rechaza la siguiente menor', () {
      expect(satisfaceCaret(base, Version(0, 15, 0)), isFalse);
    });

    test('rechaza la 1.0.0', () {
      expect(satisfaceCaret(base, Version(1, 0, 0)), isFalse);
    });

    test('resolverMasAlta elige la mayor compatible', () {
      expect(
        resolverMasAlta(base, <Version>[
          Version(0, 14, 1),
          Version(0, 14, 9),
          Version(0, 15, 0),
        ]),
        Version(0, 14, 9),
      );
    });

    test('resolverMasAlta devuelve null si ninguna sirve', () {
      expect(resolverMasAlta(base, <Version>[Version(0, 15, 0)]), isNull);
    });
  });

  group('m14-5 esApiPublica', () {
    test('lib/algo.dart es publico', () {
      expect(esApiPublica('lib/bitacora.dart'), isTrue);
    });

    test('lib/src/algo.dart no lo es', () {
      expect(esApiPublica('lib/src/interno.dart'), isFalse);
    });

    test('fuera de lib no lo es', () {
      expect(esApiPublica('bin/cli.dart'), isFalse);
      expect(esApiPublica('test/algo_test.dart'), isFalse);
    });

    test('un archivo que no es dart no lo es', () {
      expect(esApiPublica('lib/README.md'), isFalse);
    });
  });
}
