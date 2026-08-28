// SOLUCION MODULO 16

import 'dart:convert';

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

  Map<String, Object?> aJson() => <String, Object?>{
    'id': id,
    'texto': texto,
    'etiquetas': etiquetas,
    'completada': completada,
  };

  static Nota desdeJson(Object? valor) {
    if (valor is! Map<String, Object?>) {
      throw const BitacoraCorrupta('Cada nota debe ser un objeto');
    }
    final id = valor['id'];
    final texto = valor['texto'];
    final etiquetas = valor['etiquetas'];
    final completada = valor['completada'];
    if (id is! String ||
        texto is! String ||
        completada is! bool ||
        etiquetas is! List<Object?>) {
      throw const BitacoraCorrupta('Una nota no tiene la forma esperada');
    }
    if (etiquetas.any((etiqueta) => etiqueta is! String)) {
      throw const BitacoraCorrupta('Las etiquetas deben ser textos');
    }
    return Nota(
      id: id,
      texto: texto,
      etiquetas: etiquetas.cast<String>().toList(growable: false),
      completada: completada,
    );
  }

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

/// Donde vive el texto. Sustituible: en memoria en las pruebas, en disco
/// en produccion. El repositorio no sabe cual le toco.
abstract interface class AlmacenTexto {
  /// Contenido actual, o null si nunca se escribio nada.
  String? leer();

  void escribir(String contenido);
}

class AlmacenEnMemoria implements AlmacenTexto {
  AlmacenEnMemoria([this._contenido]);

  String? _contenido;

  @override
  String? leer() => _contenido;

  @override
  void escribir(String contenido) => _contenido = contenido;
}

/// Serializa y valida. Nunca interpreta un archivo roto como bitacora vacia.
class RepositorioBitacora {
  RepositorioBitacora(this._almacen);

  final AlmacenTexto _almacen;

  List<Nota> cargar() {
    final contenido = _almacen.leer();
    if (contenido == null || contenido.trim().isEmpty) {
      return const <Nota>[];
    }

    final Object? decodificado;
    try {
      decodificado = jsonDecode(contenido);
    } on FormatException {
      throw const BitacoraCorrupta('El archivo no es JSON valido');
    }

    if (decodificado is! Map<String, Object?>) {
      throw const BitacoraCorrupta('La raiz debe ser un objeto');
    }
    final version = decodificado['schemaVersion'];
    if (version is! int) {
      throw const BitacoraCorrupta('Falta schemaVersion');
    }
    if (version > schemaVersion) {
      throw BitacoraCorrupta(
        'Version $version mas nueva que la soportada ($schemaVersion)',
      );
    }
    final notas = decodificado['notas'];
    if (notas is! List<Object?>) {
      throw const BitacoraCorrupta('notas debe ser una lista');
    }
    return notas.map(Nota.desdeJson).toList(growable: false);
  }

  void guardar(List<Nota> notas) {
    _almacen.escribir(
      jsonEncode(<String, Object?>{
        'schemaVersion': schemaVersion,
        'notas': notas.map((nota) => nota.aJson()).toList(),
      }),
    );
  }
}

/// Reglas de la bitacora. No sabe de JSON ni de archivos.
class ServicioBitacora {
  ServicioBitacora(this._repositorio);

  final RepositorioBitacora _repositorio;

  /// Crea una nota validada. Devuelve el motivo del rechazo, o null.
  String? crear({
    required String id,
    required String texto,
    List<String> etiquetas = const <String>[],
  }) {
    final normalizado = texto.trim();
    if (normalizado.isEmpty) {
      return 'La nota no puede estar vacia.';
    }
    final notas = _repositorio.cargar();
    if (notas.any((nota) => nota.id == id)) {
      return 'Ya existe una nota con ese identificador.';
    }
    final limpias = etiquetas
        .map((etiqueta) => etiqueta.trim().toLowerCase())
        .where((etiqueta) => etiqueta.isNotEmpty)
        .toSet()
        .toList(growable: false);
    _repositorio.guardar(<Nota>[
      ...notas,
      Nota(id: id, texto: normalizado, etiquetas: limpias, completada: false),
    ]);
    return null;
  }

  /// Marca una nota como completada. Devuelve si cambio algo.
  bool completar(String id) {
    final notas = _repositorio.cargar();
    var cambio = false;
    final actualizadas = notas
        .map((nota) {
          if (nota.id == id && !nota.completada) {
            cambio = true;
            return nota.copyWith(completada: true);
          }
          return nota;
        })
        .toList(growable: false);
    if (cambio) {
      _repositorio.guardar(actualizadas);
    }
    return cambio;
  }

  /// Notas que llevan la etiqueta indicada, normalizada igual que al crear.
  List<Nota> filtrarPorEtiqueta(String etiqueta) {
    final buscada = etiqueta.trim().toLowerCase();
    return _repositorio
        .cargar()
        .where((nota) => nota.etiquetas.contains(buscada))
        .toList(growable: false);
  }

  ({int pendientes, int completadas}) resumen() {
    var pendientes = 0;
    var completadas = 0;
    for (final nota in _repositorio.cargar()) {
      nota.completada ? completadas++ : pendientes++;
    }
    return (pendientes: pendientes, completadas: completadas);
  }
}
