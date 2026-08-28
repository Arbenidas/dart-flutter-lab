// SOLUCION MODULO 14

/// Una version semantica: mayor.menor.parche.
class Version implements Comparable<Version> {
  const Version(this.mayor, this.menor, this.parche);

  /// Interpreta un texto con el formato 1.2.3.
  factory Version.parsear(String texto) {
    final partes = texto.trim().split('.');
    if (partes.length != 3) {
      throw FormatException('Se esperaba mayor.menor.parche', texto);
    }
    final numeros = <int>[];
    for (final parte in partes) {
      final numero = int.tryParse(parte);
      if (numero == null || numero < 0) {
        throw FormatException(
          'Cada parte debe ser un entero no negativo',
          texto,
        );
      }
      numeros.add(numero);
    }
    return Version(numeros[0], numeros[1], numeros[2]);
  }

  final int mayor;
  final int menor;
  final int parche;

  @override
  int compareTo(Version other) {
    if (mayor != other.mayor) return mayor.compareTo(other.mayor);
    if (menor != other.menor) return menor.compareTo(other.menor);
    return parche.compareTo(other.parche);
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator >(Version other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) => other is Version && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(mayor, menor, parche);

  @override
  String toString() => '$mayor.$menor.$parche';
}

/// Decide si [candidata] satisface una restriccion caret sobre [base].
///
/// Para una base estable (mayor >= 1) el limite superior es la siguiente
/// version mayor. Para una base 0.x el limite es la siguiente menor: en
/// Dart, antes de 1.0.0 una menor puede romper compatibilidad.
bool satisfaceCaret(Version base, Version candidata) {
  if (candidata < base) {
    return false;
  }
  if (base.mayor > 0) {
    return candidata.mayor == base.mayor;
  }
  return candidata.mayor == 0 && candidata.menor == base.menor;
}

/// Elige la version mas alta que satisface la restriccion, o null.
Version? resolverMasAlta(Version base, Iterable<Version> disponibles) {
  final compatibles = disponibles.where((v) => satisfaceCaret(base, v)).toList()
    ..sort();
  return compatibles.isEmpty ? null : compatibles.last;
}

/// Decide si una ruta de archivo forma parte de la API publica de un paquete.
/// Todo lo que vive bajo lib/src es privado aunque el analizador lo permita.
bool esApiPublica(String rutaRelativa) {
  final ruta = rutaRelativa.replaceAll(r'\', '/');
  if (!ruta.startsWith('lib/')) return false;
  if (ruta.startsWith('lib/src/')) return false;
  return ruta.endsWith('.dart');
}
