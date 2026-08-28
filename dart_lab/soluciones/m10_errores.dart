// SOLUCION MODULO 10

/// Un fallo de dominio: esperado, con contexto y sin stack trace ruidoso.
class DatoInvalido implements Exception {
  const DatoInvalido(this.campo, this.motivo);

  final String campo;
  final String motivo;

  @override
  String toString() => 'DatoInvalido($campo): $motivo';
}

/// Convierte texto externo en una edad, traduciendo el fallo de formato
/// a un fallo de dominio con contexto.
int parsearEdad(String entrada) {
  final normalizada = entrada.trim();
  final int numero;
  try {
    numero = int.parse(normalizada);
  } on FormatException {
    throw DatoInvalido('edad', 'No es un numero entero: "$normalizada"');
  }
  if (numero < 0 || numero > 130) {
    throw DatoInvalido('edad', 'Fuera del rango 0..130: $numero');
  }
  return numero;
}

/// Ejecuta [accion] anotando en [bitacora] el orden real de los pasos,
/// incluido el bloque finally. Relanza cualquier fallo conservandolo.
T conRegistro<T>(List<String> bitacora, T Function() accion) {
  bitacora.add('inicio');
  try {
    final resultado = accion();
    bitacora.add('exito');
    return resultado;
  } catch (_) {
    bitacora.add('fallo');
    rethrow;
  } finally {
    bitacora.add('cierre');
  }
}

/// Suma las edades validas y devuelve tambien los motivos de las invalidas.
/// Un dato malo no puede interrumpir el proceso completo.
({int total, List<String> rechazos}) sumarEdades(Iterable<String> entradas) {
  var total = 0;
  final rechazos = <String>[];
  for (final entrada in entradas) {
    try {
      total += parsearEdad(entrada);
    } on DatoInvalido catch (error) {
      rechazos.add(error.motivo);
    }
  }
  return (total: total, rechazos: rechazos);
}

/// Mensaje seguro para mostrarle a una persona: nunca filtra la excepcion
/// original ni rutas internas.
String mensajeParaUsuario(Object error) => switch (error) {
  DatoInvalido(campo: final campo) =>
    'Revisa el campo $campo e intentalo otra vez.',
  FormatException() => 'El formato del archivo no es el esperado.',
  _ => 'No pudimos completar la operacion. Intentalo mas tarde.',
};
