/// MODULO 15 — Costuras para probar: Repository, Service y dobles
///
/// Una "costura" es un punto donde puedes sustituir una pieza sin tocar el
/// resto. Sin costuras, probar exige levantar media aplicacion.
library;

/// Una tarea con su estado.
class Tarea {
  const Tarea({required this.id, required this.titulo, required this.hecha});

  final String id;
  final String titulo;
  final bool hecha;

  /// TODO(m15-1): devuelve una copia con los campos indicados cambiados.
  /// El `id` nunca cambia: es la identidad de la tarea.
  Tarea copyWith({String? titulo, bool? hecha}) =>
      throw UnimplementedError('Tarea.copyWith');

  @override
  bool operator ==(Object other) =>
      other is Tarea &&
      other.id == id &&
      other.titulo == titulo &&
      other.hecha == hecha;

  @override
  int get hashCode => Object.hash(id, titulo, hecha);
}

/// Contrato de almacenamiento. La costura que permite probar sin disco.
abstract interface class RepositorioTareas {
  List<Tarea> listar();
  void guardar(Tarea tarea);
  void eliminar(String id);
}

/// Implementacion en memoria.
///
/// TODO(m15-1): `listar` devuelve las tareas ORDENADAS por id y en una lista
/// no modificable. `guardar` con un id existente reemplaza. `eliminar` un id
/// inexistente lanza `StateError`.
class RepositorioEnMemoria implements RepositorioTareas {
  // ignore: unused_field
  final Map<String, Tarea> _tareas = <String, Tarea>{};

  @override
  List<Tarea> listar() => throw UnimplementedError('listar');

  @override
  void guardar(Tarea tarea) {
    // TODO(m15-1): implementame.
    throw UnimplementedError('guardar');
  }

  @override
  void eliminar(String id) {
    // TODO(m15-1): implementame.
    throw UnimplementedError('eliminar');
  }
}

/// Repositorio que falla siempre. Existe para probar el camino de ERROR sin
/// tener que romper nada real.
///
/// TODO(m15-5): haz que las tres operaciones lancen `StateError`.
class RepositorioQueFalla implements RepositorioTareas {
  @override
  List<Tarea> listar() => throw UnimplementedError('listar');

  @override
  void guardar(Tarea tarea) => throw UnimplementedError('guardar');

  @override
  void eliminar(String id) => throw UnimplementedError('eliminar');
}

/// Reglas de negocio. No sabe como se guardan las tareas ni como se muestran.
class ServicioTareas {
  ServicioTareas(this._repositorio);

  // ignore: unused_field
  final RepositorioTareas _repositorio;

  /// Crea una tarea validada.
  ///
  /// TODO(m15-2): devuelve el motivo del rechazo, o `null` si fue bien.
  /// Reglas: titulo no vacio (recortado), 60 caracteres o menos, id no
  /// repetido. Si rechaza, NO debe guardar nada.
  String? crear({required String id, required String titulo}) {
    // TODO(m15-2): implementame.
    throw UnimplementedError('crear');
  }

  /// Marca una tarea como hecha. Devuelve si cambio algo.
  ///
  /// TODO(m15-3): completar dos veces la misma tarea devuelve `false` la
  /// segunda; un id inexistente tambien.
  bool completar(String id) {
    // TODO(m15-3): implementame.
    throw UnimplementedError('completar');
  }

  /// Cuenta pendientes y hechas en una sola pasada.
  ///
  /// TODO(m15-4): implementame devolviendo un record con nombres.
  ({int pendientes, int hechas}) resumen() {
    // TODO(m15-4): implementame.
    throw UnimplementedError('resumen');
  }
}
