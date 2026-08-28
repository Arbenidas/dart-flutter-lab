/// MODULO 8 — Contratos, composicion e inyeccion
///
/// Una dependencia sustituible no es ceremonia: es lo que vuelve barata una
/// prueba. Si tu clase construye por dentro lo que necesita, nadie puede
/// ponerle otra cosa.
library;

/// Fuente de tiempo sustituible.
///
/// TODO(m08-1): declara el metodo `ahora()` que devuelve un `DateTime`.
abstract interface class Reloj {
  DateTime ahora();
}

/// Reloj que siempre devuelve el mismo instante. Existe para las pruebas.
///
/// TODO(m08-1): implementame. `DateTime.now` es una dependencia oculta que
/// vuelve intermitentes las pruebas; esta clase la convierte en un dato.
class RelojFijo implements Reloj {
  RelojFijo(this._instante);

  // ignore: unused_field
  final DateTime _instante;

  @override
  DateTime ahora() => throw UnimplementedError('RelojFijo.ahora');
}

/// Decide si una fecha limite ya vencio, segun el reloj que RECIBE.
///
/// TODO(m08-2): implementame. Fijate que la clase no crea el reloj: lo pide.
class ServicioVencimiento {
  ServicioVencimiento(this._reloj);

  // ignore: unused_field
  final Reloj _reloj;

  /// Verdadero si [limite] es anterior al instante actual del reloj.
  /// El instante exacto todavia NO vencio.
  bool vencio(DateTime limite) => throw UnimplementedError('vencio');

  /// Dias que faltan para [limite]. Negativo si ya vencio.
  int diasRestantes(DateTime limite) =>
      throw UnimplementedError('diasRestantes');
}

/// Contrato de envio, sin decir por que medio.
abstract interface class EnviadorMensaje {
  void enviar({required String destino, required String cuerpo});
}

/// Enviador que solo acumula en memoria. Existe para las pruebas.
///
/// TODO(m08-3): implementame. Rechaza un destino vacio con `ArgumentError`.
class EnviadorEnMemoria implements EnviadorMensaje {
  final List<({String destino, String cuerpo})> enviados =
      <({String destino, String cuerpo})>[];

  @override
  void enviar({required String destino, required String cuerpo}) {
    // TODO(m08-3): implementame.
    throw UnimplementedError('EnviadorEnMemoria.enviar');
  }
}

/// Notifica vencimientos usando dos CONTRATOS, no dos implementaciones.
///
/// TODO(m08-4): implementame. Esta clase es la prueba de que la composicion
/// funciona: no sabe que reloj ni que enviador le tocaron.
class NotificadorVencimiento {
  NotificadorVencimiento({
    required ServicioVencimiento servicio,
    required EnviadorMensaje enviador,
  }) : _servicio = servicio,
       _enviador = enviador;

  // ignore: unused_field
  final ServicioVencimiento _servicio;
  // ignore: unused_field
  final EnviadorMensaje _enviador;

  /// Envia un aviso solo si la fecha ya vencio. Devuelve si envio.
  bool avisarSiVencio({required String destino, required DateTime limite}) {
    // TODO(m08-4): implementame.
    throw UnimplementedError('avisarSiVencio');
  }
}

/// Registra lo que ocurre, para componerlo con cualquier clase.
///
/// TODO(m08-5): implementame. Un mixin agrega comportamiento sin herencia y
/// sin poder declarar constructores: esa es su limitacion y su ventaja.
mixin Registrable {
  // ignore: unused_field
  final List<String> _registro = <String>[];

  /// Vista de solo lectura del registro.
  List<String> get registro => throw UnimplementedError('registro');

  /// Anota un evento.
  void registrar(String evento) {
    // TODO(m08-5): implementame.
    throw UnimplementedError('registrar');
  }
}

/// Un contador que ademas deja rastro de cada operacion.
class ContadorRegistrado with Registrable {
  int _valor = 0;

  int get valor => _valor;

  void incrementar() {
    _valor++;
    registrar('incrementar -> $_valor');
  }

  void reiniciar() {
    _valor = 0;
    registrar('reiniciar -> 0');
  }
}
