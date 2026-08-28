/// MODULO 13 — Entrada externa: URLs, JSON y linea de comandos
///
/// Todo lo que entra desde afuera es texto sospechoso hasta que lo validas.
library;

/// Construye una URL de consulta sin concatenar texto a mano.
///
/// TODO(m13-1): usa `Uri.parse` y `replace`. Exige que [base] use https y
/// lanza `ArgumentError` si no. Sin parametros no debe quedar la interrogacion.
/// Concatenar a mano rompe con espacios, acentos y ampersands; `Uri` los
/// codifica solo.
Uri construirConsulta({
  required String base,
  required String ruta,
  Map<String, String> parametros = const <String, String>{},
}) {
  // TODO(m13-1): implementame.
  throw UnimplementedError('construirConsulta');
}

/// Una entrada de bitacora ya validada.
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

/// Convierte texto JSON en un modelo tipado.
///
/// TODO(m13-2): distingue TRES fallos distintos y no los mezcles:
///   - sintaxis rota            -> `FormatException`
///   - forma inesperada         -> `FormatException`
///   - regla de dominio         -> `ArgumentError`
/// `etiquetas` ausente vale como lista vacia; `titulo` vacio no vale.
EntradaBitacora decodificarEntrada(String textoJson) {
  // TODO(m13-2): implementame.
  throw UnimplementedError('decodificarEntrada');
}

/// Argumentos de la linea de comandos ya interpretados.
typedef Argumentos = ({
  String comando,
  Map<String, String> opciones,
  List<String> libres,
});

/// Interpreta argumentos con el formato: `comando --clave=valor libre`.
///
/// TODO(m13-4): el primer argumento es el comando; sin argumentos, lanza.
/// Una opcion sin `=` es un error. Ojo con `--q=a=b`: solo el PRIMER `=`
/// separa la clave del valor.
Argumentos interpretarArgumentos(List<String> argumentos) {
  // TODO(m13-4): implementame.
  throw UnimplementedError('interpretarArgumentos');
}
