/// MODULO 16 — Proyecto final: bitacora con persistencia verificable
///
/// Aqui se junta todo: modelado, null safety, errores, contratos y pruebas.
/// La regla que gobierna el proyecto: un archivo roto NUNCA se interpreta
/// como "no hay nada".
library;

/// Version del formato en disco. Cambiarla obliga a migrar.
const int schemaVersion = 1;

/// El archivo existe pero no se puede interpretar. Distinto de "no hay nada".
class BitacoraCorrupta implements Exception {
  const BitacoraCorrupta(this.motivo);

  final String motivo;

  @override
  String toString() => 'BitacoraCorrupta: $motivo';
}

/// Una nota de la bitacora.
class Nota {
  const Nota({
    required this.id,
    required this.texto,
    required this.etiquetas,
    required this.completada,
  });

  final String id;
  final String texto;
  final List<String> etiquetas;
  final bool completada;

  Nota copyWith({bool? completada}) => Nota(
    id: id,
    texto: texto,
    etiquetas: etiquetas,
    completada: completada ?? this.completada,
  );

  /// TODO(m16-1): serializa los cuatro campos.
  Map<String, Object?> aJson() => throw UnimplementedError('Nota.aJson');

  /// TODO(m16-1): valida la forma antes de construir. Cualquier desviacion es
  /// `BitacoraCorrupta`, no un valor por defecto.
  static Nota desdeJson(Object? valor) =>
      throw UnimplementedError('Nota.desdeJson');

  @override
  bool operator ==(Object other) =>
      other is Nota &&
      other.id == id &&
      other.texto == texto &&
      other.completada == completada &&
      other.etiquetas.join(',') == etiquetas.join(',');

  @override
  int get hashCode => Object.hash(id, texto, completada, etiquetas.join(','));
}

/// Donde vive el texto. Sustituible: en memoria en las pruebas, en disco en
/// produccion. El repositorio no sabe cual le toco.
abstract interface class AlmacenTexto {
  /// Contenido actual, o `null` si nunca se escribio nada.
  String? leer();

  void escribir(String contenido);
}

/// TODO(m16-2): implementame. Es el doble que vuelve baratas las pruebas.
class AlmacenEnMemoria implements AlmacenTexto {
  AlmacenEnMemoria([this._contenido]);

  // ignore: unused_field, prefer_final_fields
  String? _contenido;

  @override
  String? leer() => throw UnimplementedError('AlmacenEnMemoria.leer');

  @override
  void escribir(String contenido) =>
      throw UnimplementedError('AlmacenEnMemoria.escribir');
}

/// Serializa y valida.
class RepositorioBitacora {
  RepositorioBitacora(this._almacen);

  // ignore: unused_field
  final AlmacenTexto _almacen;

  /// TODO(m16-2): distingue VACIO de CORRUPTO.
  ///   - almacen sin escribir, o solo espacios -> lista vacia
  ///   - JSON invalido, raiz que no es objeto, `schemaVersion` ausente o mas
  ///     nueva que la soportada, `notas` que no es lista -> `BitacoraCorrupta`
  /// Devolver una lista vacia ante un archivo roto es el bug que este
  /// contrato existe para impedir.
  List<Nota> cargar() => throw UnimplementedError('cargar');

  /// TODO(m16-3): escribe un objeto con `schemaVersion` y `notas`.
  void guardar(List<Nota> notas) {
    // TODO(m16-3): implementame.
    throw UnimplementedError('guardar');
  }
}

/// Reglas de la bitacora. No sabe de JSON ni de archivos.
class ServicioBitacora {
  ServicioBitacora(this._repositorio);

  // ignore: unused_field
  final RepositorioBitacora _repositorio;

  /// Crea una nota validada. Devuelve el motivo del rechazo, o `null`.
  ///
  /// TODO(m16-4): texto no vacio (recortado), id no repetido. Normaliza las
  /// etiquetas igual que en m06: recorta, pasa a minusculas, descarta vacias
  /// y deduplica.
  String? crear({
    required String id,
    required String texto,
    List<String> etiquetas = const <String>[],
  }) {
    // TODO(m16-4): implementame.
    throw UnimplementedError('crear');
  }

  /// Marca una nota como completada. Devuelve si cambio algo.
  ///
  /// TODO(m16-5): no reescribas el archivo si no cambio nada.
  bool completar(String id) {
    // TODO(m16-5): implementame.
    throw UnimplementedError('completar');
  }

  /// Notas que llevan la etiqueta indicada, normalizada igual que al crear.
  List<Nota> filtrarPorEtiqueta(String etiqueta) =>
      throw UnimplementedError('filtrarPorEtiqueta');

  /// TODO(m16-6): cuenta pendientes y completadas. Si la bitacora esta
  /// corrupta debe FALLAR, no devolver ceros: un cero mentiroso es peor que
  /// una excepcion.
  ({int pendientes, int completadas}) resumen() =>
      throw UnimplementedError('resumen');
}
