import 'dart:convert';

import 'package:dart_lab/m16_bitacora.dart';
import 'package:test/test.dart';

ServicioBitacora _servicio([String? contenido]) =>
    ServicioBitacora(RepositorioBitacora(AlmacenEnMemoria(contenido)));

void main() {
  group('m16-1 Nota va y vuelve de JSON', () {
    const nota = Nota(
      id: 'n1',
      texto: 'Primera',
      etiquetas: <String>['dart'],
      completada: false,
    );

    test('conserva todos los campos', () {
      expect(Nota.desdeJson(jsonDecode(jsonEncode(nota.aJson()))), nota);
    });

    test('rechaza una nota que no es objeto', () {
      expect(
        () => Nota.desdeJson(<Object?>[]),
        throwsA(isA<BitacoraCorrupta>()),
      );
    });

    test('rechaza una forma incorrecta', () {
      expect(
        () => Nota.desdeJson(<String, Object?>{
          'id': 1,
          'texto': 'x',
          'etiquetas': <Object?>[],
          'completada': false,
        }),
        throwsA(isA<BitacoraCorrupta>()),
      );
    });

    test('rechaza etiquetas que no son textos', () {
      expect(
        () => Nota.desdeJson(<String, Object?>{
          'id': 'a',
          'texto': 'x',
          'etiquetas': <Object?>[1],
          'completada': false,
        }),
        throwsA(isA<BitacoraCorrupta>()),
      );
    });
  });

  group('m16-2 RepositorioBitacora distingue vacio de corrupto', () {
    test('un almacen sin escribir es una bitacora vacia', () {
      expect(RepositorioBitacora(AlmacenEnMemoria()).cargar(), isEmpty);
    });

    test('texto en blanco tambien es vacio', () {
      expect(RepositorioBitacora(AlmacenEnMemoria('   ')).cargar(), isEmpty);
    });

    test('JSON invalido es corrupto, no vacio', () {
      expect(
        () => RepositorioBitacora(AlmacenEnMemoria('{roto')).cargar(),
        throwsA(isA<BitacoraCorrupta>()),
      );
    });

    test('sin schemaVersion es corrupto', () {
      expect(
        () => RepositorioBitacora(AlmacenEnMemoria('{"notas":[]}')).cargar(),
        throwsA(isA<BitacoraCorrupta>()),
      );
    });

    test('una version mas nueva es corrupto, no se ignora', () {
      expect(
        () => RepositorioBitacora(
          AlmacenEnMemoria('{"schemaVersion":99,"notas":[]}'),
        ).cargar(),
        throwsA(isA<BitacoraCorrupta>()),
      );
    });
  });

  group('m16-3 guardar y volver a cargar', () {
    test('el ciclo completo conserva las notas', () {
      final almacen = AlmacenEnMemoria();
      final repositorio = RepositorioBitacora(almacen)
        ..guardar(const <Nota>[
          Nota(
            id: 'n1',
            texto: 'Primera',
            etiquetas: <String>['dart'],
            completada: false,
          ),
        ]);
      expect(repositorio.cargar(), hasLength(1));
      expect(repositorio.cargar().single.texto, 'Primera');
    });

    test('lo escrito declara la version del esquema', () {
      final almacen = AlmacenEnMemoria();
      RepositorioBitacora(almacen).guardar(const <Nota>[]);
      final escrito = jsonDecode(almacen.leer()!) as Map<String, Object?>;
      expect(escrito['schemaVersion'], schemaVersion);
    });
  });

  group('m16-4 ServicioBitacora crea con reglas', () {
    test('acepta una nota valida y la normaliza', () {
      final servicio = _servicio();
      expect(servicio.crear(id: 'n1', texto: '  Primera  '), isNull);
      expect(servicio.resumen().pendientes, 1);
    });

    test('rechaza una nota vacia sin guardar nada', () {
      final servicio = _servicio();
      expect(servicio.crear(id: 'n1', texto: '   '), isNotNull);
      expect(servicio.resumen().pendientes, 0);
    });

    test('rechaza un identificador repetido', () {
      final servicio = _servicio();
      servicio.crear(id: 'n1', texto: 'Primera');
      expect(servicio.crear(id: 'n1', texto: 'Otra'), isNotNull);
      expect(servicio.resumen().pendientes, 1);
    });

    test('normaliza y deduplica etiquetas', () {
      final servicio = _servicio();
      servicio.crear(
        id: 'n1',
        texto: 'Primera',
        etiquetas: <String>[' Dart ', 'dart', ''],
      );
      expect(servicio.filtrarPorEtiqueta('DART'), hasLength(1));
    });
  });

  group('m16-5 completar y filtrar', () {
    test('completar una nota pendiente cambia el resumen', () {
      final servicio = _servicio();
      servicio.crear(id: 'n1', texto: 'Primera');
      expect(servicio.completar('n1'), isTrue);
      expect(servicio.resumen(), (pendientes: 0, completadas: 1));
    });

    test('completar dos veces no cambia nada la segunda', () {
      final servicio = _servicio();
      servicio.crear(id: 'n1', texto: 'Primera');
      servicio.completar('n1');
      expect(servicio.completar('n1'), isFalse);
    });

    test('completar un id inexistente devuelve falso', () {
      expect(_servicio().completar('nope'), isFalse);
    });

    test('filtrar por una etiqueta que nadie tiene devuelve vacio', () {
      final servicio = _servicio();
      servicio.crear(id: 'n1', texto: 'Primera', etiquetas: <String>['dart']);
      expect(servicio.filtrarPorEtiqueta('flutter'), isEmpty);
    });
  });

  group('m16-6 un archivo corrupto no se sobrescribe en silencio', () {
    test('crear sobre una bitacora corrupta falla en vez de vaciarla', () {
      final almacen = AlmacenEnMemoria('{roto');
      final servicio = ServicioBitacora(RepositorioBitacora(almacen));
      expect(
        () => servicio.crear(id: 'n1', texto: 'Primera'),
        throwsA(isA<BitacoraCorrupta>()),
      );
      expect(
        almacen.leer(),
        '{roto',
        reason: 'El contenido original debe seguir intacto.',
      );
    });

    test('el resumen tambien falla en vez de mentir con ceros', () {
      final servicio = _servicio('{roto');
      expect(() => servicio.resumen(), throwsA(isA<BitacoraCorrupta>()));
    });
  });
}
