/// MODULO 14 — Versiones, restricciones y superficie publica
///
/// Publicar codigo es firmar una promesa de compatibilidad. Las versiones son
/// como se escribe esa promesa.
library;

/// Una version semantica: mayor.menor.parche.
class Version implements Comparable<Version> {
  const Version(this.mayor, this.menor, this.parche);

  /// Interpreta un texto con el formato `1.2.3`.
  ///
  /// TODO(m14-1): implementame. Rechaza con `FormatException` si no hay tres
  /// partes o si alguna no es un entero no negativo.
  factory Version.parsear(String texto) {
    // TODO(m14-1): implementame.
    throw UnimplementedError('Version.parsear');
  }

  final int mayor;
  final int menor;
  final int parche;

  /// TODO(m14-2): compara por precedencia: primero mayor, luego menor, luego
  /// parche. Ojo con el orden textual: '1.10.0' es MAYOR que '1.2.0'.
  @override
  int compareTo(Version other) => throw UnimplementedError('compareTo');

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
/// TODO(m14-3): para una base estable (mayor >= 1) el limite superior es la
/// siguiente MAYOR. Para una base 0.x el limite es la siguiente MENOR: antes
/// de 1.0.0, en Dart una menor puede romper compatibilidad. Una candidata
/// anterior a la base nunca satisface.
bool satisfaceCaret(Version base, Version candidata) {
  // TODO(m14-3): implementame.
  throw UnimplementedError('satisfaceCaret');
}

/// Elige la version mas alta que satisface la restriccion, o null.
///
/// TODO(m14-4): implementame reutilizando `satisfaceCaret`.
Version? resolverMasAlta(Version base, Iterable<Version> disponibles) {
  // TODO(m14-4): implementame.
  throw UnimplementedError('resolverMasAlta');
}

/// Decide si una ruta forma parte de la API PUBLICA de un paquete.
///
/// TODO(m14-5): todo lo que vive bajo `lib/src` es privado aunque el
/// analizador te deje importarlo. Lo que esta fuera de `lib/` no se publica.
bool esApiPublica(String rutaRelativa) {
  // TODO(m14-5): implementame.
  throw UnimplementedError('esApiPublica');
}
