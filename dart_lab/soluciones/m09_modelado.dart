// SOLUCION MODULO 9

/// Estados posibles de una descarga. Un enum con datos y comportamiento.
enum EstadoDescarga {
  pendiente('Pendiente', false),
  activa('En curso', false),
  completada('Lista', true),
  fallida('Fallo', true);

  const EstadoDescarga(this.etiqueta, this.esFinal);

  final String etiqueta;
  final bool esFinal;
}

/// Resultado de una validacion: o es valido con un valor, o invalido con
/// una lista no vacia de mensajes. No hay un tercer caso.
sealed class Resultado<T> {
  const Resultado();
}

final class Valido<T> extends Resultado<T> {
  const Valido(this.valor);

  final T valor;
}

final class Invalido<T> extends Resultado<T> {
  Invalido(this.mensajes) {
    if (mensajes.isEmpty) {
      throw ArgumentError.value(mensajes, 'mensajes', 'No puede estar vacia');
    }
  }

  final List<String> mensajes;
}

/// Describe un resultado sin usar rama comodin: el compilador comprueba
/// que estan todos los casos.
String describir<T>(Resultado<T> resultado) => switch (resultado) {
  Valido<T>(valor: final valor) => 'ok: $valor',
  Invalido<T>(mensajes: final mensajes) => 'error: ${mensajes.join(', ')}',
};

/// Valida un nombre de usuario y acumula todos los problemas encontrados.
Resultado<String> validarUsuario(String entrada) {
  final normalizado = entrada.trim();
  final problemas = <String>[];
  if (normalizado.isEmpty) {
    problemas.add('El usuario no puede estar vacio.');
  }
  if (normalizado.length > 20) {
    problemas.add('El usuario debe tener 20 caracteres o menos.');
  }
  if (normalizado.contains(' ')) {
    problemas.add('El usuario no puede contener espacios.');
  }
  return problemas.isEmpty
      ? Valido<String>(normalizado)
      : Invalido<String>(problemas);
}

/// Primer elemento o null, conservando el tipo del elemento.
T? primeroONull<T>(Iterable<T> elementos) {
  final iterador = elementos.iterator;
  return iterador.moveNext() ? iterador.current : null;
}

/// Separa una coleccion en los que cumplen y los que no, usando un record
/// con campos nombrados.
({List<T> cumplen, List<T> resto}) separar<T>(
  Iterable<T> elementos,
  bool Function(T) condicion,
) {
  final cumplen = <T>[];
  final resto = <T>[];
  for (final elemento in elementos) {
    (condicion(elemento) ? cumplen : resto).add(elemento);
  }
  return (cumplen: cumplen, resto: resto);
}
