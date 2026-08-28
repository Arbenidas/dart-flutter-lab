/// MODULO 10 — Errores, excepciones y depuracion
///
/// Un fallo ESPERADO se modela; un bug se deja explotar. Confundirlos produce
/// o bien excepciones no atrapadas en produccion, o bien errores tragados que
/// aparecen tres capas mas arriba sin contexto.
library;

/// Un fallo de dominio: esperado, con contexto y sin ruido tecnico.
///
/// TODO(m10-1): implementa `toString` para que nombre el campo. Fijate que
/// implementa `Exception`, no `Error`: `Error` es para bugs del programador.
class DatoInvalido implements Exception {
  const DatoInvalido(this.campo, this.motivo);

  final String campo;
  final String motivo;

  @override
  String toString() => throw UnimplementedError('DatoInvalido.toString');
}

/// Convierte texto externo en una edad, TRADUCIENDO el fallo de formato a un
/// fallo de dominio con contexto.
///
/// TODO(m10-2): usa `int.parse` dentro de un `try` y atrapa `FormatException`
/// con `on`. No dejes escapar la excepcion original: quien te llama no deberia
/// tener que saber que por dentro usaste `int.parse`. Valida ademas el rango
/// 0..130. El motivo debe incluir el dato recibido.
int parsearEdad(String entrada) {
  // TODO(m10-2): implementame.
  throw UnimplementedError('parsearEdad');
}

/// Ejecuta [accion] anotando en [bitacora] el orden REAL de los pasos.
///
/// En el camino feliz: 'inicio', 'exito', 'cierre'.
/// Ante un fallo:      'inicio', 'fallo', 'cierre'.
///
/// TODO(m10-3): usa `try` / `catch` / `finally` y `rethrow`. `rethrow`
/// conserva el error y su stack trace original; `throw error` los pierde.
T conRegistro<T>(List<String> bitacora, T Function() accion) {
  // TODO(m10-3): implementame.
  throw UnimplementedError('conRegistro');
}

/// Suma las edades validas y devuelve tambien los motivos de las invalidas.
///
/// TODO(m10-4): un dato malo NO puede interrumpir el proceso completo. Atrapa
/// solo `DatoInvalido`: cualquier otra cosa es un bug y debe seguir subiendo.
({int total, List<String> rechazos}) sumarEdades(Iterable<String> entradas) {
  // TODO(m10-4): implementame.
  throw UnimplementedError('sumarEdades');
}

/// Mensaje seguro para mostrarle a una persona.
///
/// TODO(m10-5): implementame con una switch expression sobre el tipo del
/// error. Nunca filtres el motivo tecnico ni rutas internas: eso va al log,
/// no a la pantalla.
String mensajeParaUsuario(Object error) {
  // TODO(m10-5): implementame.
  throw UnimplementedError('mensajeParaUsuario');
}
