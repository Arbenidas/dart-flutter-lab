/// MODULO 3 — Null safety en serio
///
/// El sistema de tipos de Dart divide el mundo en dos: los tipos que
/// pueden ser null (`String?`) y los que no pueden serlo jamas (`String`).
/// El compilador te obliga a demostrar cual es cual. Esto no es burocracia:
/// es la razon por la que una app Flutter bien tipada casi no tira
/// `NoSuchMethodError` en produccion.
library;

/// Saluda a [nombre]. Si es null o esta vacio, saluda a 'desconocido'.
///
///   saludar('Diego') == 'Hola, Diego'
///   saludar(null)    == 'Hola, desconocido'
///   saludar('')      == 'Hola, desconocido'
///
/// Practicas: `??` (si-null) y por que `??` NO se dispara con string vacio.
String saludar(String? nombre) {
  // TODO(m03-1): implementame.
  throw UnimplementedError('saludar');
}

/// Longitud de [texto], o 0 si es null.
///
/// Practicas: el acceso condicional `?.` combinado con `??`.
/// Escribilo en UNA sola expresion. Si te salen tres lineas con un `if`,
/// funciona igual, pero volve a intentarlo hasta que te salga la de una.
int longitudSegura(String? texto) {
  // TODO(m03-2): implementame.
  throw UnimplementedError('longitudSegura');
}

/// Devuelve el primer texto no vacio de [textos], o null si no hay ninguno.
///
/// Practicas: devolver `String?` a proposito, y que quien te llame
/// se haga cargo de ese null.
String? primerNoVacio(List<String> textos) {
  // TODO(m03-3): implementame.
  throw UnimplementedError('primerNoVacio');
}

/// Convierte [entrada] a una edad valida, o devuelve null.
///
/// Valida: debe ser un entero entre 0 y 130 inclusive.
///   parsearEdad('30')   == 30
///   parsearEdad('abc')  == null
///   parsearEdad('-1')   == null
///   parsearEdad('500')  == null
///   parsearEdad(' 30 ') == 30   (recortar espacios)
///
/// Practicas: `int.tryParse` (que devuelve `int?`) contra `int.parse`
/// (que LANZA). Regla: si el dato viene de afuera —del usuario, de una
/// API, de un archivo— usa `tryParse`. `parse` es para datos que vos
/// controlas y donde un fallo es un bug, no un caso esperado.
int? parsearEdad(String entrada) {
  // TODO(m03-4): implementame.
  throw UnimplementedError('parsearEdad');
}

/// Un contador que se inicializa tarde, a proposito.
class SesionDeEstudio {
  /// TODO(m03-5): declara aqui `late final DateTime _inicio;`
  ///
  /// `late` le dice al compilador: "confia en mi, voy a asignar esto
  /// antes de que alguien lo lea". Si mentis, no compila mal: explota
  /// en ejecucion con `LateInitializationError`. Es un contrato que
  /// vos firmas, no una red de seguridad.

  /// Marca el arranque de la sesion.
  void comenzar(DateTime cuando) {
    // TODO(m03-5): asigna _inicio.
    throw UnimplementedError('comenzar');
  }

  /// Minutos transcurridos entre el arranque y [ahora].
  ///
  /// Debe lanzar si se llama antes de [comenzar]. No escribas vos el
  /// `throw`: dejaselo a `late`. Ese es el punto del ejercicio.
  int minutosHasta(DateTime ahora) {
    // TODO(m03-5): implementame usando _inicio.
    throw UnimplementedError('minutosHasta');
  }
}
