// SOLUCION MODULO 3

String saludar(String? nombre) {
  // `nombre?.isEmpty` da `bool?`: null si nombre es null.
  // El `?? true` convierte ese null en "si, esta vacio".
  final vacio = nombre?.isEmpty ?? true;
  return vacio ? 'Hola, desconocido' : 'Hola, $nombre';
  // La interpolacion admite valores nullable. La variable `vacio` NO promueve
  // el tipo de `nombre`; para acceder a un miembro habria que comprobar
  // `nombre != null` directamente o guardar un valor no nullable.
}

int longitudSegura(String? texto) => texto?.length ?? 0;

String? primerNoVacio(List<String> textos) {
  for (final texto in textos) {
    if (texto.trim().isNotEmpty) return texto;
  }
  return null;
}

int? parsearEdad(String entrada) {
  final edad = int.tryParse(entrada.trim());
  if (edad == null) return null;
  if (edad < 0 || edad > 130) return null;
  return edad;
}

class SesionDeEstudio {
  late final DateTime _inicio;

  void comenzar(DateTime cuando) {
    _inicio = cuando;
  }

  int minutosHasta(DateTime ahora) => ahora.difference(_inicio).inMinutes;
}
