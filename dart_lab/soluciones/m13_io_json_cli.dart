// SOLUCION MODULO 13

import 'dart:convert';

/// Construye una URL de consulta sin concatenar texto a mano.
/// [base] debe ser https; los parametros se codifican solos.
Uri construirConsulta({
  required String base,
  required String ruta,
  Map<String, String> parametros = const <String, String>{},
}) {
  final origen = Uri.parse(base);
  if (origen.scheme != 'https') {
    throw ArgumentError.value(base, 'base', 'La base debe usar https');
  }
  return origen.replace(
    path: ruta,
    queryParameters: parametros.isEmpty ? null : parametros,
  );
}

/// Una entrada de bitacora validada.
class EntradaBitacora {
  const EntradaBitacora({
    required this.id,
    required this.titulo,
    required this.etiquetas,
  });

  final String id;
  final String titulo;
  final List<String> etiquetas;

  @override
  bool operator ==(Object other) =>
      other is EntradaBitacora &&
      other.id == id &&
      other.titulo == titulo &&
      other.etiquetas.join(',') == etiquetas.join(',');

  @override
  int get hashCode => Object.hash(id, titulo, etiquetas.join(','));
}

/// Convierte texto JSON en un modelo tipado. Distingue tres fallos:
/// sintaxis, forma y validacion de dominio.
EntradaBitacora decodificarEntrada(String textoJson) {
  final Object? decodificado;
  try {
    decodificado = jsonDecode(textoJson);
  } on FormatException {
    throw const FormatException('El texto no es JSON valido');
  }

  if (decodificado is! Map<String, Object?>) {
    throw const FormatException('Se esperaba un objeto JSON en la raiz');
  }

  final id = decodificado['id'];
  final titulo = decodificado['titulo'];
  final etiquetas = decodificado['etiquetas'] ?? <Object?>[];

  if (id is! String || titulo is! String || etiquetas is! List<Object?>) {
    throw const FormatException('El objeto no tiene la forma esperada');
  }
  if (id.trim().isEmpty) {
    throw ArgumentError.value(id, 'id', 'No puede estar vacio');
  }
  if (titulo.trim().isEmpty) {
    throw ArgumentError.value(titulo, 'titulo', 'No puede estar vacio');
  }
  if (etiquetas.any((etiqueta) => etiqueta is! String)) {
    throw const FormatException('etiquetas debe contener solo textos');
  }

  return EntradaBitacora(
    id: id,
    titulo: titulo.trim(),
    etiquetas: etiquetas.cast<String>().toList(growable: false),
  );
}

/// Argumentos de la linea de comandos ya interpretados.
typedef Argumentos = ({
  String comando,
  Map<String, String> opciones,
  List<String> libres,
});

/// Interpreta argumentos con el formato: comando --clave=valor libre.
Argumentos interpretarArgumentos(List<String> argumentos) {
  if (argumentos.isEmpty) {
    throw ArgumentError('Falta el comando');
  }
  final opciones = <String, String>{};
  final libres = <String>[];
  for (final argumento in argumentos.skip(1)) {
    if (!argumento.startsWith('--')) {
      libres.add(argumento);
      continue;
    }
    final separador = argumento.indexOf('=');
    if (separador < 0) {
      throw ArgumentError.value(
        argumento,
        'argumento',
        'Se esperaba --clave=valor',
      );
    }
    opciones[argumento.substring(2, separador)] = argumento.substring(
      separador + 1,
    );
  }
  return (comando: argumentos.first, opciones: opciones, libres: libres);
}
