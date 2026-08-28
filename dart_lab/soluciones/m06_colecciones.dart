// SOLUCION MODULO 6

typedef Pedido = ({bool pagado, int total});

/// Totales de los pedidos pagados, en el mismo orden de entrada.
List<int> totalesPagados(List<Pedido> pedidos) {
  return pedidos
      .where((pedido) => pedido.pagado)
      .map((pedido) => pedido.total)
      .toList(growable: false);
}

/// Etiquetas normalizadas y sin repetir.
Set<String> etiquetasUnicas(Iterable<String> etiquetas) {
  return etiquetas
      .map((etiqueta) => etiqueta.trim().toLowerCase())
      .where((etiqueta) => etiqueta.isNotEmpty)
      .toSet();
}

/// Indexa [elementos] por la clave que produce [clave].
Map<K, T> indexarPor<T, K>(Iterable<T> elementos, K Function(T) clave) {
  final indice = <K, T>{};
  for (final elemento in elementos) {
    final k = clave(elemento);
    if (indice.containsKey(k)) {
      throw ArgumentError.value(k, 'clave', 'La clave se repite');
    }
    indice[k] = elemento;
  }
  return indice;
}

/// Cuenta cuantos elementos caen en cada clave.
Map<K, int> contarPorClave<T, K>(Iterable<T> elementos, K Function(T) clave) {
  final conteo = <K, int>{};
  for (final elemento in elementos) {
    final k = clave(elemento);
    conteo[k] = (conteo[k] ?? 0) + 1;
  }
  return conteo;
}

/// Primer elemento que cumple [condicion], o null. Deja de evaluar al encontrarlo.
T? primeroQueCumple<T>(Iterable<T> elementos, bool Function(T) condicion) {
  for (final elemento in elementos) {
    if (condicion(elemento)) {
      return elemento;
    }
  }
  return null;
}
