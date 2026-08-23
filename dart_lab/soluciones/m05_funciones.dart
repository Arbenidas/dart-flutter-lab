// SOLUCION MODULO 5

int aplicar(int valor, int Function(int) transformacion) =>
    transformacion(valor);

String etiqueta(String texto, {bool mayusculas = false, String prefijo = ''}) =>
    '$prefijo${mayusculas ? texto.toUpperCase() : texto}';

int Function() crearContador() {
  var cuenta = 0; // vive en el scope de crearContador...
  return () {
    cuenta++; // ...pero la closure se la lleva consigo y la mantiene viva.
    return cuenta;
  };
}

int Function(int) multiplicadorPor(int factor) =>
    (int n) => n * factor;

List<int> transformarTodos(
  List<int> numeros,
  int Function(int) transformacion,
) => numeros.map(transformacion).toList();
// `map` devuelve un Iterable perezoso: no calcula nada hasta que alguien lo
// recorre. `.toList()` fuerza el calculo y crea una lista independiente.

int medirMilisegundos(void Function() accion) {
  final reloj = Stopwatch()..start();
  try {
    accion();
  } finally {
    reloj.stop();
  }
  return reloj.elapsedMilliseconds;
}
