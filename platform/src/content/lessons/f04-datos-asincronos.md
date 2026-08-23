---
id: 'F04-L01'
trackId: 'flutter'
moduleId: 'F04'
order: 0
slug: 'datos-asincronos-y-persistencia'
title: 'Un Future no es un modelo de experiencia'
summary: 'Representa carga, datos, vacío y error; valida JSON y separa la UI de red, caché y persistencia.'
estimatedMinutes: 145
objectives:
  - 'Modelar estados asíncronos mutuamente coherentes en vez de combinar banderas contradictorias.'
  - 'Convertir JSON externo a modelos tipados y tratar datos inválidos como fallos explícitos.'
  - 'Separar presentación, repositorio y fuentes remotas o locales para poder sustituirlas.'
prerequisites: ['F03-L01']
activities:
  - id: 'predecir-carreras'
    kind: 'predict'
    prompt: 'Predice el estado final si load(A) tarda 800 ms, load(B) tarda 200 ms y A termina después; define cuál respuesta debería ganar y por qué.'
    required: true
    hints:
      - 'Completar último no significa representar la intención más reciente.'
      - 'Registra una identidad o generación de solicitud.'
  - id: 'escribir-estado-sellado'
    kind: 'code'
    prompt: 'Implementa un tipo sellado LoadState<T> con initial, loading, data, empty y error, y una función que lo convierta exhaustivamente en una descripción de UI.'
    required: true
    hints:
      - 'Evita combinaciones como isLoading=true junto con error no nulo.'
      - 'Decide si data vacío merece un estado distinto por su experiencia y acción siguiente.'
  - id: 'diagnosticar-fetch-en-build'
    kind: 'debug'
    prompt: 'Diagnostica una pantalla que crea fetchEntries() dentro de build y otra que fuerza json[title] as String; explica el fallo temporal y el fallo de frontera.'
    required: true
    hints:
      - 'Cada rebuild puede crear una solicitud nueva.'
      - 'Una respuesta externa no respeta automáticamente tus tipos Dart.'
  - id: 'leer-datos-oficiales'
    kind: 'docs'
    prompt: 'En Fetch data, JSON and serialization y FutureBuilder, localiza dónde se inicia el Future, cómo se representa error y qué estrategia se recomienda según el tamaño del modelo.'
    required: true
    hints:
      - 'Compara una receta, una guía de decisión y una API reference.'
      - 'Anota qué parte del ejemplo no copiarías directamente a producción.'
  - id: 'explicar-limites'
    kind: 'explain'
    prompt: 'Explica la diferencia entre un Service que habla HTTP o SQLite y un Repository que ofrece entradas a la aplicación y decide fuente, caché y política de error.'
    required: true
    hints:
      - 'Nombra las entradas y salidas de cada límite.'
      - 'La View no debería saber si el dato llegó de disco o red.'
  - id: 'transferir-offline-first'
    kind: 'transfer'
    prompt: 'Diseña una lectura offline-first: define qué se muestra con caché antigua, qué ocurre al sincronizar, cómo se resuelven errores y qué indicador evita confundir “guardado local” con “sincronizado”.'
    required: true
    hints:
      - 'Dato visible y sincronización en curso pueden coexistir.'
      - 'Distingue disponibilidad local de confirmación remota.'
docRefs:
  - label: 'Fetch data from the internet'
    url: 'https://docs.flutter.dev/cookbook/networking/fetch-data'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'JSON and serialization'
    url: 'https://docs.flutter.dev/data-and-backend/serialization/json'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'FutureBuilder class'
    url: 'https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Persist data with SQLite'
    url: 'https://docs.flutter.dev/cookbook/persistence/sqlite'
    kind: 'cookbook'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué estados necesita una carga y qué acción ofrece cada uno?'
  - '¿Por qué no debes crear el Future de una petición dentro de build?'
  - '¿Dónde se transforma JSON en un modelo tipado y cómo se prueba?'
  - '¿Qué responsabilidad distingue Repository de Service?'
---

`Future<List<Entry>>` describe que un cálculo terminará más adelante. No describe qué debe ver una persona mientras espera, cuando no hay resultados, cuando la red falla o cuando existen datos antiguos. Para construir una experiencia correcta necesitas un modelo de estado, no solo un tipo asíncrono.

## Estados que no se contradicen

Tres booleanos como `isLoading`, `hasError` e `isEmpty` permiten combinaciones absurdas. Un tipo sellado limita los casos posibles:

```dart
sealed class LoadState<T> {
  const LoadState();
}

class Initial<T> extends LoadState<T> {
  const Initial();
}

class Loading<T> extends LoadState<T> {
  const Loading();
}

class Data<T> extends LoadState<T> {
  const Data(this.value);
  final T value;
}

class Empty<T> extends LoadState<T> {
  const Empty();
}

class Failure<T> extends LoadState<T> {
  const Failure(this.message);
  final String message;
}
```

Cada estado exige una decisión de UI:

| Estado  | Pregunta de experiencia            | Acción habitual                   |
| ------- | ---------------------------------- | --------------------------------- |
| initial | ¿La carga empezó?                  | iniciar o esperar intención       |
| loading | ¿Hay datos anteriores?             | progreso o actualización discreta |
| data    | ¿Qué puede hacer con el contenido? | leer, editar, refrescar           |
| empty   | ¿Por qué no hay nada?              | crear, cambiar filtros            |
| error   | ¿Qué falló y puede recuperarse?    | reintentar, usar caché            |

En una estrategia stale-while-revalidate, datos y sincronización pueden coexistir. No fuerces toda actualización a una pantalla vacía con spinner. Modela la información que la UI realmente necesita: contenido previo, operación en curso y posible fallo de sincronización.

## El Future se obtiene antes de build

La API de `FutureBuilder` especifica que el `Future` debe obtenerse antes, por ejemplo en `initState`, `didChangeDependencies` o un gestor de estado. Crearlo dentro de `build` puede reiniciar la operación cada vez que el padre reconstruye:

```dart
late Future<List<Entry>> _entries;

@override
void initState() {
  super.initState();
  _entries = repository.fetchEntries();
}
```

`FutureBuilder` es útil para un cálculo ligado a una vista. Cuando existen recarga, mutaciones, caché, paginación o varias vistas consumidoras, un ViewModel con estado explícito suele expresar mejor la coordinación. La herramienta cambia; el contrato de estados permanece.

También existen carreras. Si una búsqueda A empieza, luego la persona solicita B y A termina última, aceptar ciegamente el último resultado completado muestra una intención vieja. Puedes cancelar, comparar el término solicitado o incrementar una generación y descartar respuestas obsoletas.

## JSON es entrada no confiable

`jsonDecode` produce estructuras dinámicas. El cast no valida mágicamente un servidor:

```dart
factory Entry.fromJson(Map<String, Object?> json) {
  final id = json['id'];
  final title = json['title'];
  if (id is! String || title is! String || title.trim().isEmpty) {
    throw const FormatException('Entrada inválida');
  }
  return Entry(id: id, title: title);
}
```

Para modelos pequeños, serialización manual puede ser suficiente si tiene tests. En proyectos medianos o grandes, generación reduce código repetitivo y errores. La decisión depende de escala, modelos anidados y políticas del equipo, no de que una opción sea siempre «más profesional».

## Límites: UI, Repository y Service

Un Service conoce una tecnología concreta: ejecuta HTTP, consulta SQLite o lee un archivo. Un Repository ofrece datos significativos para la aplicación, transforma modelos, coordina fuentes y aplica políticas de caché y error. La UI consume estados y envía eventos; no interpreta códigos HTTP ni sentencias SQL.

```text
View → ViewModel → EntryRepository → RemoteEntryService
                             └──────→ LocalEntryService
```

Separar estos límites permite sustituir red por un fake en tests y añadir persistencia sin reescribir los widgets. SQLite es una opción para consultas y volúmenes locales; no es la respuesta automática para cada preferencia pequeña. Evalúa estructura, consultas, plataformas soportadas y migraciones.

## P — Predice

Simula dos búsquedas. A comienza primero y tarda 800 ms; B comienza después y tarda 200 ms. Escribe la línea temporal y predice qué verá la persona si ambas respuestas asignan estado al terminar. Luego define una regla: solo la generación asociada a la intención más reciente puede publicar.

Predice también qué estados aparecen en primera carga, recarga con datos visibles, respuesta vacía y error con caché disponible. Si tu modelo no puede expresarlos, amplíalo antes de escribir widgets.

## E — Escribe

Implementa `LoadState<T>` y una función exhaustiva que produzca una etiqueta de UI. Añade tests para cada variante. Después crea un `FakeEntryRepository` configurable para devolver datos, vacío o error. No necesitas instalar un cliente HTTP para aprender el contrato.

El starter actual no incluye una práctica real de red/persistencia, por eso esta lección no enlaza un laboratorio ejecutable. Mantén los snippets en un ejercicio aislado hasta que exista un workspace con dependencias, rutas y tests verificables.

## N — Nombra el fallo

Fallo temporal: `FutureBuilder(future: fetchEntries(), ...)` crea trabajo durante `build`. Una reconstrucción no relacionada puede repetir la petición. Obtén el Future antes o delega la carga a un propietario de estado.

Fallo de frontera: `json['title'] as String` lanza en runtime si el campo falta o cambia de tipo. Valida en el borde, devuelve un fallo entendible y prueba casos incompletos. No disperses casts dinámicos por widgets.

## S — Sustenta

Lee **Fetch data** como receta: identifica la secuencia y sus supuestos. Lee **JSON and serialization** como árbol de decisión: manual frente a generación. Lee `FutureBuilder` como contrato: busca **Managing the future** y **Builder contract**. Finalmente, en SQLite verifica plataformas, dependencias y advertencias como `whereArgs`.

Para cada fuente oficial escribe: pregunta inicial, párrafo o firma que la responde, y decisión resultante. Si la documentación refleja una versión distinta a tu proyecto, verifica changelog o API de tu SDK antes de copiar.

## A — Argumenta

Defiende por qué `Repository` no debe devolver un `Widget` de error y por qué `Service` no debería decidir el copy final. Eso invertiría dependencias: datos conocería presentación. El Repository puede exponer un fallo tipado; el ViewModel lo traduce a estado presentable; la View decide composición y accesibilidad.

## R — Reaplica

Diseña una bitácora offline-first. Al abrir, muestra caché local. Inicia sincronización sin borrar contenido. Si termina bien, reconcilia por identidad y versión; si falla, conserva datos y muestra que todavía no se sincronizaron. Para una creación sin red, genera identidad local y marca el registro como pendiente.

Especifica conflictos, reintentos e indicador de estado antes de elegir base de datos o backend. La arquitectura de datos empieza con semántica y fallos; la tecnología viene después.
