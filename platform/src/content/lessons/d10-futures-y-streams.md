---
id: 'D10-L01'
trackId: 'dart'
moduleId: 'D10'
order: 0
slug: 'futures-async-await-y-streams'
title: 'Un Future entrega una vez; un Stream cuenta una secuencia'
summary: 'Razona sobre orden, finalización y errores para elegir Future o Stream sin bloquear ni perder eventos.'
estimatedMinutes: 120
objectives:
  - 'Predecir el orden de ejecución alrededor del primer await.'
  - 'Componer Futures secuenciales o concurrentes según sus dependencias.'
  - 'Elegir Stream únicamente para una secuencia de eventos en el tiempo.'
prerequisites: ['D09-L01']
activities:
  - id: 'predecir-orden'
    kind: 'predict'
    prompt: 'Predice la salida de una función async que imprime antes y después de un await, mientras main imprime inmediatamente después de llamarla. Numera cada línea antes de ejecutar.'
    required: true
    hints:
      - 'Una función async corre sincrónicamente hasta su primer await.'
      - 'Llamarla devuelve un Future todavía incompleto.'
  - id: 'escribir-composicion'
    kind: 'code'
    prompt: 'En un scratch local, crea dos Futures con demoras distintas; mide ejecución secuencial y Future.wait, luego consume un Stream<int> con await for. Ejecuta todo con FVM.'
    required: true
    hints:
      - 'Solo usa Future.wait cuando ninguna operación necesita el resultado de la otra.'
      - 'Una función async* emite con yield.'
  - id: 'diagnosticar-await'
    kind: 'debug'
    prompt: 'Corrige una función que llama una operación fallable sin await dentro de try/catch y explica por qué el error completa el Future después de salir del bloque.'
    required: true
    hints:
      - 'Para capturar la finalización fallida en ese bloque, espera el Future.'
      - 'Declara Future<void> cuando la operación asíncrona no entrega un valor útil.'
  - id: 'rastrear-asincronia'
    kind: 'docs'
    prompt: 'En la guía oficial, identifica los dos estados de Future, las dos formas principales de consumir Stream y la diferencia entre single-subscription y broadcast.'
    required: true
    hints:
      - 'Un Future incompleto termina una vez con valor o error.'
      - 'Compara await for con listen antes de elegir.'
  - id: 'defender-tipo'
    kind: 'explain'
    prompt: 'Elige Future o Stream para cargar un perfil, observar cambios de conectividad, guardar una preferencia y recibir pulsaciones. Defiende cada decisión por cardinalidad y tiempo.'
    required: true
    hints:
      - 'Pregunta si esperas un resultado o cero a muchos eventos.'
      - 'No elijas Stream solo porque la operación sea lenta.'
  - id: 'transferir-repositorio'
    kind: 'transfer'
    prompt: 'Diseña la firma de un repositorio que obtenga una configuración una vez y observe cambios posteriores. Separa ambas operaciones y documenta finalización, errores y cancelación.'
    required: true
    hints:
      - 'Una lectura puntual y una observación continua tienen contratos distintos.'
      - 'Quien usa listen debe conservar y cancelar la suscripción cuando ya no la necesita.'
docRefs:
  - label: 'Asynchronous programming: futures, async, await'
    url: 'https://dart.dev/libraries/async/async-await'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Asynchronous programming: Streams'
    url: 'https://dart.dev/libraries/async/using-streams'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Future class'
    url: 'https://api.dart.dev/dart-async/Future-class.html'
    kind: 'api'
    version: 'Dart 3.13 API'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué parte de una función async se ejecuta antes de devolver el control al llamador?'
  - '¿Cuándo Future.wait reduce tiempo y cuándo cambia incorrectamente la dependencia?'
  - '¿Qué separa el contrato de Future<T> del de Stream<T>?'
  - '¿Por qué un try/catch sin await puede no capturar el error de un Future?'
---

Asincronía no significa “otra CPU hace todo en paralelo”. Significa que una operación puede devolver el control mientras espera y completar su contrato después. Para razonar bien necesitas seguir dos cosas: cuántos resultados llegarán y en qué punto continúa cada función.

## Future: una finalización

Un `Future<T>` empieza incompleto y termina una sola vez con un valor `T` o con un error. Una función marcada `async` devuelve un Future, incluso si su cuerpo parece secuencial:

```dart
Future<String> cargarNombre() async {
  await Future<void>.delayed(const Duration(milliseconds: 10));
  return 'Ada';
}
```

La función corre sincrónicamente hasta encontrar el primer `await`. En ese punto entrega un Future incompleto al llamador y continúa cuando la operación esperada termina.

```dart
Future<void> tarea() async {
  print('A');
  await Future<void>.delayed(Duration.zero);
  print('C');
}

Future<void> main() async {
  final pendiente = tarea();
  print('B');
  await pendiente;
  print('D');
}
```

La predicción correcta es `A, B, C, D`. Las letras no dependen de adivinar milisegundos: siguen los puntos donde se cede y recupera el control.

## Secuencia o concurrencia intencional

Si la segunda operación necesita la primera, espera en orden:

```dart
final usuario = await cargarUsuario();
final permisos = await cargarPermisos(usuario.id);
```

Si son independientes, puedes iniciarlas juntas y esperar ambas con `Future.wait`. No conviertas todo a concurrencia por velocidad: cambia el orden de efectos y la forma en que llegan los errores. Primero demuestra independencia.

Para capturar un error dentro de `try`, espera la finalización allí:

```dart
try {
  await guardar();
} on FormatException catch (error) {
  print('Entrada inválida: ${error.message}');
}
```

Llamar `guardar()` sin `await` inicia la operación y sale del bloque; el Future puede completar con error más tarde.

## Stream: eventos a través del tiempo

Un `Stream<T>` entrega una secuencia de cero a muchos datos y también puede emitir errores antes de cerrarse. Consúmelo con `await for` cuando una secuencia legible encaja con el flujo:

```dart
Stream<int> contarHasta(int limite) async* {
  for (var numero = 1; numero <= limite; numero += 1) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    yield numero;
  }
}

Future<void> mostrar() async {
  await for (final numero in contarHasta(3)) {
    print(numero);
  }
}
```

Usa `listen` cuando necesitas una suscripción que puedas pausar o cancelar explícitamente. Antes de suscribirte, revisa si el stream acepta una sola escucha o difunde a varias. Esa diferencia forma parte del contrato, no es un detalle de implementación.

## P — Predice

Numera la salida de `tarea` antes de ejecutarla. Luego elimina el `await pendiente` y predice qué garantía pierde `main`. No basta decir “puede cambiar”: indica qué línea ya no espera la finalización.

Para streams, predice cuántos valores emite `contarHasta(0)`, cuándo cierra y qué ocurre si el cuerpo lanza en el segundo elemento. Separa evento de datos, evento de error y cierre.

## E — Escribe

Crea un scratch local con dos Futures de demoras distintas. Mide primero dos `await` consecutivos y luego inicia ambos mediante `Future.wait`. Conserva la versión concurrente solo si las operaciones son independientes.

Agrega un generador `async*` y consúmelo con `await for`. Ejecuta con el SDK administrado por FVM y verifica la base:

```bash
cd dart_lab
fvm dart --version
fvm dart analyze
fvm dart test
```

Las demoras son un instrumento para observar orden, no una simulación fiel de red o base de datos.

## N — Nombra el fallo

Clasifica antes de parchear:

- **Future ignorado:** se inicia una operación cuyo resultado o error nadie observa;
- **await faltante:** el código siguiente asume una finalización que todavía no ocurrió;
- **secuencialización accidental:** operaciones independientes esperan una tras otra;
- **concurrencia inválida:** una operación sí dependía de la otra;
- **stream excesivo:** se modela como secuencia algo que entrega un único resultado;
- **suscripción huérfana:** `listen` sigue activo después de que el consumidor dejó de necesitarlo.

Nombra el contrato temporal roto: valor, error, orden, cierre o cancelación.

## S — Sustenta

En **futures, async, await**, localiza los estados incompleto y completado, y la regla de ejecución hasta el primer `await`. En **Streams**, compara `await for` con `listen` y encuentra single-subscription frente a broadcast.

Abre la referencia de **Future** cuando necesites una firma exacta como `wait`, `timeout` o `then`. Empieza por la guía para el modelo mental y pasa a la API con una operación concreta en mente.

## A — Argumenta

Cargar un perfil y guardar una preferencia producen un resultado por operación: `Future`. Conectividad y pulsaciones cambian varias veces: `Stream`. Que algo sea lento no lo convierte en secuencia.

Compara `await for` y `listen`. El primero hace visible un consumo secuencial y su finalización. El segundo da control de suscripción y encaja con eventos continuos, pero exige gestionar su ciclo de vida. Defiende según el consumidor, no según la moda de la API.

## R — Reaplica

Diseña dos firmas para configuración: `Future<Configuracion> obtener()` y `Stream<Configuracion> observar()`. Documenta si el stream emite el valor actual al suscribirse, cómo informa errores, cuándo cierra y quién cancela.

Repite la decisión con base local, red y eventos de interfaz. Si una API mezcla lectura puntual y observación continua en un único método, separa los contratos. La asincronía se vuelve manejable cuando el tipo cuenta cuántos resultados esperar y el código deja claros los puntos de espera.
