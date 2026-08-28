/// MODULO 9 — Genericos, records, enums y tipos sellados
///
/// Modelar bien es hacer que los estados imposibles no se puedan escribir.
library;

/// Estados posibles de una descarga. Un enum con datos y comportamiento.
///
/// TODO(m09-1): dale a cada valor una `etiqueta` legible y un `esFinal`.
/// `completada` y `fallida` son finales; `pendiente` y `activa` no.
enum EstadoDescarga {
  pendiente('', false),
  activa('', false),
  completada('', false),
  fallida('', false);

  const EstadoDescarga(this.etiqueta, this.esFinal);

  final String etiqueta;
  final bool esFinal;
}

/// Resultado de una validacion: o es valido con un valor, o invalido con
/// una lista NO VACIA de mensajes. No hay un tercer caso, y `sealed` es lo
/// que se lo dice al compilador.
sealed class Resultado<T> {
  const Resultado();
}

final class Valido<T> extends Resultado<T> {
  const Valido(this.valor);

  final T valor;
}

final class Invalido<T> extends Resultado<T> {
  /// TODO(m09-4): rechaza una lista de mensajes vacia con `ArgumentError`.
  /// Un "invalido sin motivos" es justo el estado imposible que queremos
  /// impedir.
  Invalido(this.mensajes) {
    // TODO(m09-4): valida aqui.
    throw UnimplementedError('Invalido');
  }

  final List<String> mensajes;
}

/// Describe un resultado SIN rama comodin.
///
/// TODO(m09-4): implementame con una switch expression sobre el tipo sellado.
/// Si agregas una variante nueva a `Resultado`, esta funcion debe dejar de
/// compilar: ese error es la red de seguridad, no una molestia.
String describir<T>(Resultado<T> resultado) {
  // TODO(m09-4): implementame.
  throw UnimplementedError('describir');
}

/// Valida un nombre de usuario y ACUMULA todos los problemas encontrados.
///
/// Reglas: no vacio, 20 caracteres o menos, sin espacios.
///
/// TODO(m09-5): implementame. Devolver el primer error que encuentres es mas
/// facil y obliga al usuario a corregir de a uno.
Resultado<String> validarUsuario(String entrada) {
  // TODO(m09-5): implementame.
  throw UnimplementedError('validarUsuario');
}

/// Primer elemento o null, conservando el tipo del elemento.
///
/// TODO(m09-2): implementame sin materializar la coleccion.
T? primeroONull<T>(Iterable<T> elementos) {
  // TODO(m09-2): implementame.
  throw UnimplementedError('primeroONull');
}

/// Separa una coleccion en los que cumplen y los que no.
///
/// TODO(m09-3): devuelve un record con campos NOMBRADOS: `(cumplen:, resto:)`.
/// Conserva el orden original dentro de cada grupo.
({List<T> cumplen, List<T> resto}) separar<T>(
  Iterable<T> elementos,
  bool Function(T) condicion,
) {
  // TODO(m09-3): implementame.
  throw UnimplementedError('separar');
}
