/// MODULO 6 — Colecciones, iterables y evaluacion perezosa
///
/// Reglas de la casa:
///  1. No borres los comentarios `TODO`. Escribi tu codigo debajo.
///  2. No mires `soluciones/` hasta haber intentado 20 minutos reales.
///  3. Corre `./lab next` hasta que el ejercicio pase.
///  4. Despues corre `fvm dart analyze` y dejalo en cero avisos.
library;

/// Un pedido minimo: si esta pagado y cuanto suma, en centavos.
typedef Pedido = ({bool pagado, int total});

/// Totales de los pedidos pagados, en el mismo orden de entrada.
///
/// Lo que estas practicando: encadenar `where`, `map` y `toList`, y por que
/// el contrato pide una lista NO ampliable (`growable: false`). Devolver una
/// lista que quien te llama puede agrandar es una promesa que no hiciste.
List<int> totalesPagados(List<Pedido> pedidos) {
  // TODO(m06-1): implementame.
  throw UnimplementedError('totalesPagados');
}

/// Etiquetas normalizadas —sin espacios sobrantes, en minusculas— y sin repetir.
///
/// Descarta las que queden vacias despues de normalizar.
///
/// Lo que estas practicando: por que un `Set` expresa la regla "no se repite"
/// mejor que una `List` que revisas a mano.
Set<String> etiquetasUnicas(Iterable<String> etiquetas) {
  // TODO(m06-2): implementame.
  throw UnimplementedError('etiquetasUnicas');
}

/// Indexa [elementos] por la clave que produce [clave].
///
/// Si dos elementos producen la misma clave, LANZA `ArgumentError`. Esa es
/// una decision de contrato: el silencio seria peor, porque perderias un
/// elemento sin enterarte. En la leccion vas a defender esta eleccion frente
/// a "conservar el ultimo".
Map<K, T> indexarPor<T, K>(Iterable<T> elementos, K Function(T) clave) {
  // TODO(m06-3): implementame.
  throw UnimplementedError('indexarPor');
}

/// Cuenta cuantos elementos caen en cada clave.
///
/// Lo que estas practicando: el patron `mapa[k] = (mapa[k] ?? 0) + 1`, que
/// combina null safety con acumulacion.
Map<K, int> contarPorClave<T, K>(Iterable<T> elementos, K Function(T) clave) {
  // TODO(m06-4): implementame.
  throw UnimplementedError('contarPorClave');
}

/// Primer elemento que cumple [condicion], o `null` si ninguno lo hace.
///
/// Debe DEJAR DE EVALUAR apenas encuentra uno: hay un test que cuenta cuantas
/// veces se llamo a [condicion]. Si materializas la coleccion antes de buscar,
/// ese test te lo va a decir.
T? primeroQueCumple<T>(Iterable<T> elementos, bool Function(T) condicion) {
  // TODO(m06-5): implementame.
  throw UnimplementedError('primeroQueCumple');
}
