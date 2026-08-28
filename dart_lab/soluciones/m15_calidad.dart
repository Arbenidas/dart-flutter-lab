// SOLUCION MODULO 15

/// Una tarea con su estado.
class Tarea {
  const Tarea({required this.id, required this.titulo, required this.hecha});

  final String id;
  final String titulo;
  final bool hecha;

  Tarea copyWith({String? titulo, bool? hecha}) =>
      Tarea(id: id, titulo: titulo ?? this.titulo, hecha: hecha ?? this.hecha);

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

/// Implementacion en memoria, util en produccion pequena y en pruebas.
class RepositorioEnMemoria implements RepositorioTareas {
  final Map<String, Tarea> _tareas = <String, Tarea>{};

  @override
  List<Tarea> listar() => List<Tarea>.unmodifiable(
    _tareas.values.toList()..sort((a, b) => a.id.compareTo(b.id)),
  );

  @override
  void guardar(Tarea tarea) => _tareas[tarea.id] = tarea;

  @override
  void eliminar(String id) {
    if (_tareas.remove(id) == null) {
      throw StateError('No existe la tarea $id');
    }
  }
}

/// Repositorio que falla siempre. Existe para probar el camino de error
/// sin tener que romper nada real.
class RepositorioQueFalla implements RepositorioTareas {
  @override
  List<Tarea> listar() => throw StateError('almacenamiento no disponible');

  @override
  void guardar(Tarea tarea) => throw StateError('almacenamiento no disponible');

  @override
  void eliminar(String id) => throw StateError('almacenamiento no disponible');
}

/// Reglas de negocio. No sabe como se guardan las tareas ni como se muestran.
class ServicioTareas {
  ServicioTareas(this._repositorio);

  final RepositorioTareas _repositorio;

  /// Crea una tarea validada. Devuelve el motivo del rechazo, o null si fue bien.
  String? crear({required String id, required String titulo}) {
    final normalizado = titulo.trim();
    if (normalizado.isEmpty) {
      return 'El titulo no puede estar vacio.';
    }
    if (normalizado.length > 60) {
      return 'El titulo debe tener 60 caracteres o menos.';
    }
    if (_repositorio.listar().any((tarea) => tarea.id == id)) {
      return 'Ya existe una tarea con ese identificador.';
    }
    _repositorio.guardar(Tarea(id: id, titulo: normalizado, hecha: false));
    return null;
  }

  /// Marca una tarea como hecha. Devuelve si cambio algo.
  bool completar(String id) {
    final actual = _repositorio
        .listar()
        .where((tarea) => tarea.id == id)
        .firstOrNull;
    if (actual == null || actual.hecha) {
      return false;
    }
    _repositorio.guardar(actual.copyWith(hecha: true));
    return true;
  }

  /// Cuenta pendientes y hechas en una sola pasada.
  ({int pendientes, int hechas}) resumen() {
    var pendientes = 0;
    var hechas = 0;
    for (final tarea in _repositorio.listar()) {
      tarea.hecha ? hechas++ : pendientes++;
    }
    return (pendientes: pendientes, hechas: hechas);
  }
}
