/// MODULO 5 — Funciones, parametros y closures
///
/// En Dart las funciones son objetos. Se guardan en variables, se pasan
/// como argumentos y se devuelven desde otras funciones. Flutter esta
/// construido sobre esto: `onPressed`, `builder`, `itemBuilder`,
/// `setState` — todos reciben funciones.
library;

/// Aplica [transformacion] a [valor] y devuelve el resultado.
///
/// TODO(m05-1): implementame (es una linea).
/// Lo importante no es el cuerpo: es leer la firma. `int Function(int)`
/// se lee "una funcion que recibe un int y devuelve un int".
int aplicar(int valor, int Function(int) transformacion) {
  throw UnimplementedError('aplicar');
}

/// Devuelve una etiqueta formateada.
///
///   etiqueta('hola')                              == 'hola'
///   etiqueta('hola', mayusculas: true)            == 'HOLA'
///   etiqueta('hola', prefijo: '>> ')              == '>> hola'
///   etiqueta('hola', prefijo: '>> ', mayusculas: true) == '>> HOLA'
///
/// El prefijo NO se pone en mayusculas.
///
/// TODO(m05-2): usa parametros con nombre y valores por defecto.
/// Regla practica: si una funcion tiene mas de dos parametros, o si
/// alguno es un `bool`, van con nombre. `etiqueta('hola', true)` no le
/// dice nada a quien lee; `etiqueta('hola', mayusculas: true)` si.
String etiqueta(String texto, {bool mayusculas = false, String prefijo = ''}) {
  throw UnimplementedError('etiqueta');
}

/// Crea un contador independiente.
///
///   final contar = crearContador();
///   contar(); // 1
///   contar(); // 2
///   final otro = crearContador();
///   otro();   // 1  <- estado propio, no compartido
///
/// TODO(m05-3): implementame.
/// Esto es una CLOSURE: la funcion interna se lleva consigo la variable
/// local de la funcion externa, y esa variable sobrevive despues de que
/// `crearContador` termino. En Flutter, una idea relacionada permite que el
/// objeto `State` conserve datos entre reconstrucciones; el `StatefulWidget`
/// en si sigue siendo inmutable y puede reemplazarse.
int Function() crearContador() {
  throw UnimplementedError('crearContador');
}

/// Devuelve una funcion que multiplica lo que reciba por [factor].
///
///   final doble = multiplicadorPor(2);
///   doble(21); // 42
///
/// TODO(m05-4): implementame. Esto se llama aplicacion parcial.
int Function(int) multiplicadorPor(int factor) {
  throw UnimplementedError('multiplicadorPor');
}

/// Aplica [transformacion] a cada elemento de [numeros] y devuelve una
/// lista nueva. NO modifiques la lista original.
///
/// TODO(m05-5): escribilo primero a mano con un `for` y una lista nueva.
/// Cuando pase el test, reescribilo con `numeros.map(...).toList()`.
/// Quiero que sepas que hace `map` por dentro antes de usarlo.
List<int> transformarTodos(
  List<int> numeros,
  int Function(int) transformacion,
) {
  throw UnimplementedError('transformarTodos');
}

/// Ejecuta [accion] y devuelve cuantos milisegundos tardo.
///
/// TODO(m05-6): usa un `Stopwatch`. Fijate que [accion] es
/// `void Function()`: una funcion que no devuelve nada.
int medirMilisegundos(void Function() accion) {
  throw UnimplementedError('medirMilisegundos');
}
