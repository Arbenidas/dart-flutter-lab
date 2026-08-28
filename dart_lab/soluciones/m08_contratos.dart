// SOLUCION MODULO 8

/// Fuente de tiempo sustituible.
abstract interface class Reloj {
  DateTime ahora();
}

/// Reloj que siempre devuelve el mismo instante. Existe para las pruebas.
class RelojFijo implements Reloj {
  RelojFijo(this._instante);

  final DateTime _instante;

  @override
  DateTime ahora() => _instante;
}

/// Decide si una fecha limite ya vencio, segun el reloj que reciba.
class ServicioVencimiento {
  ServicioVencimiento(this._reloj);

  final Reloj _reloj;

  /// Verdadero si [limite] es anterior al instante actual del reloj.
  bool vencio(DateTime limite) => limite.isBefore(_reloj.ahora());

  /// Dias que faltan para [limite]. Negativo si ya vencio.
  int diasRestantes(DateTime limite) =>
      limite.difference(_reloj.ahora()).inDays;
}

/// Contrato de envio, sin decir por que medio.
abstract interface class EnviadorMensaje {
  void enviar({required String destino, required String cuerpo});
}

/// Enviador que solo acumula en memoria. Existe para las pruebas.
class EnviadorEnMemoria implements EnviadorMensaje {
  final List<({String destino, String cuerpo})> enviados =
      <({String destino, String cuerpo})>[];

  @override
  void enviar({required String destino, required String cuerpo}) {
    if (destino.trim().isEmpty) {
      throw ArgumentError.value(destino, 'destino', 'No puede estar vacio');
    }
    enviados.add((destino: destino, cuerpo: cuerpo));
  }
}

/// Notifica vencimientos usando un contrato de envio, no una implementacion.
class NotificadorVencimiento {
  NotificadorVencimiento({
    required ServicioVencimiento servicio,
    required EnviadorMensaje enviador,
  }) : _servicio = servicio,
       _enviador = enviador;

  final ServicioVencimiento _servicio;
  final EnviadorMensaje _enviador;

  /// Envia un aviso solo si la fecha ya vencio. Devuelve si envio.
  bool avisarSiVencio({required String destino, required DateTime limite}) {
    if (!_servicio.vencio(limite)) {
      return false;
    }
    _enviador.enviar(destino: destino, cuerpo: 'La fecha limite ya paso.');
    return true;
  }
}

/// Registra lo que ocurre, para componerlo con cualquier clase.
mixin Registrable {
  final List<String> _registro = <String>[];

  /// Vista de solo lectura del registro.
  List<String> get registro => List<String>.unmodifiable(_registro);

  /// Anota un evento.
  void registrar(String evento) => _registro.add(evento);
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
