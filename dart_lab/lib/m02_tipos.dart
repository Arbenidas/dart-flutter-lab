/// MODULO 2 — Tipos, var / final / const
///
/// Reglas de la casa:
///  1. No borres los comentarios `TODO`. Escribi tu codigo debajo.
///  2. No mires `soluciones/` hasta haber intentado 20 minutos reales.
///  3. Corre `./lab next` hasta que el ejercicio pase.
///  4. Despues corre `fvm dart analyze` y dejalo en cero avisos.
library;

/// Devuelve una etiqueta en castellano segun el tipo dinamico de [valor].
///
/// Debe devolver exactamente: 'entero', 'decimal', 'texto', 'booleano',
/// 'lista' o 'otro'.
///
/// Lo que estas practicando: el operador `is`, y la diferencia entre el
/// tipo ESTATICO (lo que el compilador sabe: aca `Object`) y el tipo
/// EN TIEMPO DE EJECUCION (lo que el objeto realmente es).
String describirTipo(Object valor) {
  // TODO(m02-1): implementame.
  throw UnimplementedError('describirTipo');
}

/// Convierte grados Fahrenheit a Celsius.
///
/// Formula: (f - 32) * 5 / 9
///
/// Lo que estas practicando: division real (`/`) contra division entera
/// (`~/`), y por que el tipo de retorno es `double` y no `num`.
double aCelsius(double fahrenheit) {
  // TODO(m02-2): implementame.
  throw UnimplementedError('aCelsius');
}

/// Formatea un precio guardado en centavos como texto legible.
///
/// Ejemplos:
///   formatearPrecio(1205) == r'$12.05'
///   formatearPrecio(7)    == r'$0.07'
///   formatearPrecio(0)    == r'$0.00'
///   formatearPrecio(-1)   lanza RangeError
///
/// Lo que estas practicando: division entera `~/`, modulo `%`,
/// `padLeft`, e interpolacion de strings.
///
/// Nota: para este ejercicio los importes son no negativos y se guardan en
/// unidades minimas (`int`) para evitar errores de coma flotante. En un sistema
/// real tambien hay que modelar la moneda y su cantidad de decimales.
String formatearPrecio(int centavos) {
  // TODO(m02-3): implementame.
  throw UnimplementedError('formatearPrecio');
}

/// Los dias habiles de la semana, en orden, en minusculas.
///
/// TODO(m02-4): declarala como `const` (no `final`).
/// Los tests comprueban tanto la declaracion `const` como la canonicalizacion
/// del valor. `identical()` por si solo no distingue `const` de una variable
/// `final` cuyo valor tambien haya sido construido con `const`.
const List<String> diasHabiles = <String>[
  // TODO(m02-4): completame con los cinco dias.
];

/// Devuelve una copia de [diasHabiles] a la que se le puede agregar.
///
/// Lo que estas practicando: una lista `const` es inmutable de verdad.
/// Si intentas `diasHabiles.add('sabado')` compila, pero explota en
/// ejecucion con `Unsupported operation`. Para modificar hay que copiar.
List<String> semanaCompleta() {
  // TODO(m02-5): devolve una lista nueva con los dias habiles
  // mas 'sabado' y 'domingo' al final.
  throw UnimplementedError('semanaCompleta');
}
