import 'package:dart_lab/m15_calidad.dart';
import 'package:test/test.dart';

void main() {
  group('m15-1 RepositorioEnMemoria', () {
    test('guarda y lista en orden de id', () {
      final repositorio = RepositorioEnMemoria()
        ..guardar(const Tarea(id: 'b', titulo: 'Segunda', hecha: false))
        ..guardar(const Tarea(id: 'a', titulo: 'Primera', hecha: false));
      expect(repositorio.listar().map((t) => t.id).toList(), <String>[
        'a',
        'b',
      ]);
    });

    test('guardar con el mismo id reemplaza', () {
      final repositorio = RepositorioEnMemoria()
        ..guardar(const Tarea(id: 'a', titulo: 'Uno', hecha: false))
        ..guardar(const Tarea(id: 'a', titulo: 'Dos', hecha: false));
      expect(repositorio.listar(), hasLength(1));
      expect(repositorio.listar().single.titulo, 'Dos');
    });

    test('eliminar un id inexistente lanza', () {
      expect(() => RepositorioEnMemoria().eliminar('x'), throwsStateError);
    });

    test('la lista devuelta no se puede modificar', () {
      final repositorio = RepositorioEnMemoria()
        ..guardar(const Tarea(id: 'a', titulo: 'Uno', hecha: false));
      expect(
        () => repositorio.listar().add(
          const Tarea(id: 'z', titulo: 'x', hecha: false),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('m15-2 ServicioTareas valida antes de guardar', () {
    test('acepta un titulo valido y lo normaliza', () {
      final repositorio = RepositorioEnMemoria();
      final motivo = ServicioTareas(
        repositorio,
      ).crear(id: 'a', titulo: '  Leer  ');
      expect(motivo, isNull);
      expect(repositorio.listar().single.titulo, 'Leer');
    });

    test('rechaza un titulo vacio sin guardar nada', () {
      final repositorio = RepositorioEnMemoria();
      final motivo = ServicioTareas(repositorio).crear(id: 'a', titulo: '   ');
      expect(motivo, isNotNull);
      expect(repositorio.listar(), isEmpty);
    });

    test('rechaza un titulo demasiado largo', () {
      final repositorio = RepositorioEnMemoria();
      final motivo = ServicioTareas(
        repositorio,
      ).crear(id: 'a', titulo: 'x' * 61);
      expect(motivo, contains('60'));
      expect(repositorio.listar(), isEmpty);
    });

    test('rechaza un identificador repetido', () {
      final repositorio = RepositorioEnMemoria();
      final servicio = ServicioTareas(repositorio);
      servicio.crear(id: 'a', titulo: 'Uno');
      expect(servicio.crear(id: 'a', titulo: 'Dos'), isNotNull);
      expect(repositorio.listar(), hasLength(1));
    });
  });

  group('m15-3 completar', () {
    test('marca una tarea pendiente', () {
      final repositorio = RepositorioEnMemoria();
      final servicio = ServicioTareas(repositorio)
        ..crear(id: 'a', titulo: 'Uno');
      expect(servicio.completar('a'), isTrue);
      expect(repositorio.listar().single.hecha, isTrue);
    });

    test('completar dos veces no cambia nada la segunda', () {
      final servicio = ServicioTareas(RepositorioEnMemoria())
        ..crear(id: 'a', titulo: 'Uno');
      servicio.completar('a');
      expect(servicio.completar('a'), isFalse);
    });

    test('completar un id inexistente devuelve falso', () {
      expect(ServicioTareas(RepositorioEnMemoria()).completar('x'), isFalse);
    });
  });

  group('m15-4 resumen', () {
    test('cuenta pendientes y hechas', () {
      final servicio = ServicioTareas(RepositorioEnMemoria())
        ..crear(id: 'a', titulo: 'Uno')
        ..crear(id: 'b', titulo: 'Dos')
        ..crear(id: 'c', titulo: 'Tres');
      servicio.completar('b');
      final resumen = servicio.resumen();
      expect(resumen.pendientes, 2);
      expect(resumen.hechas, 1);
    });

    test('sin tareas devuelve ceros', () {
      final resumen = ServicioTareas(RepositorioEnMemoria()).resumen();
      expect(resumen.pendientes, 0);
      expect(resumen.hechas, 0);
    });
  });

  group('m15-5 el doble que falla prueba el camino de error', () {
    test('el servicio propaga el fallo del almacenamiento', () {
      final servicio = ServicioTareas(RepositorioQueFalla());
      expect(() => servicio.crear(id: 'a', titulo: 'Uno'), throwsStateError);
    });

    test('el resumen tambien falla si el almacenamiento no responde', () {
      expect(
        () => ServicioTareas(RepositorioQueFalla()).resumen(),
        throwsStateError,
      );
    });

    test('el doble es sustituible donde se espera el contrato', () {
      final RepositorioTareas repositorio = RepositorioQueFalla();
      expect(() => repositorio.listar(), throwsStateError);
    });
  });
}
