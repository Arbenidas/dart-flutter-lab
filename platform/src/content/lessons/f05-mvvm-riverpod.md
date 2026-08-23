---
id: 'F05-L01'
trackId: 'flutter'
moduleId: 'F05'
order: 0
slug: 'mvvm-feature-first-riverpod-notifier'
title: 'Arquitectura es decidir dónde cambia cada cosa'
summary: 'Aplica MVVM feature-first y Riverpod Notifier para separar View, estado y acceso a datos con dependencias sustituibles.'
estimatedMinutes: 155
objectives:
  - 'Asignar responsabilidades a View, ViewModel, Repository y Service sin crear capas ceremoniales.'
  - 'Organizar una capacidad completa con estructura feature-first y dependencias que apuntan hacia contratos.'
  - 'Exponer estado inmutable y comandos mediante Riverpod Notifier, con repositorios sustituibles en tests.'
prerequisites: ['F04-L01']
activities:
  - id: 'predecir-flujo-riverpod'
    kind: 'predict'
    prompt: 'Traza desde el tap en “Crear entrada” hasta la nueva JournalState y predice qué piezas se ejecutan y cuál widget observa el cambio.'
    required: true
    hints:
      - 'Distingue ref.read del notifier y ref.watch del estado.'
      - 'El Repository muta su almacenamiento; el Notifier publica un nuevo estado.'
  - id: 'escribir-override'
    kind: 'code'
    prompt: 'Escribe un test de JournalViewModel que inyecte InMemoryJournalRepository con journalRepositoryProvider.overrideWithValue y compruebe una regla sin renderizar widgets.'
    required: true
    hints:
      - 'Crea ProviderContainer y registra container.dispose con addTearDown.'
      - 'Lee el notifier para actuar y el provider para observar JournalState.'
  - id: 'diagnosticar-limites'
    kind: 'debug'
    prompt: 'Detecta tres dependencias incorrectas: View importa HTTP, Repository recibe BuildContext y ViewModel devuelve AlertDialog; explica qué límite cruza cada una.'
    required: true
    hints:
      - 'Datos no debe depender de widgets.'
      - 'Un test unitario del ViewModel no debería levantar MaterialApp.'
  - id: 'leer-arquitectura-y-api'
    kind: 'docs'
    prompt: 'En la guía oficial, extrae responsabilidades de ViewModel y Repository; en la API de Notifier, confirma qué devuelve build y cómo se publica estado.'
    required: true
    hints:
      - 'Lee UI layer y Data layer antes de la capa de dominio opcional.'
      - 'En API reference, empieza por resumen, ejemplo mínimo y métodos propios.'
  - id: 'explicar-patrones'
    kind: 'explain'
    prompt: 'Explica por qué MVVM, Riverpod, Cubit y Clean Architecture no son cuatro opciones equivalentes; indica qué problema organiza cada concepto.'
    required: true
    hints:
      - 'Separa patrón de presentación, mecanismo de estado y dirección de dependencias.'
      - 'Una app puede combinar decisiones de categorías distintas.'
  - id: 'transferir-fuente-datos'
    kind: 'transfer'
    prompt: 'Sustituye conceptualmente el repositorio en memoria por API + caché local; dibuja qué clases cambian y cuáles deberían conservar su interfaz.'
    required: true
    hints:
      - 'La View no necesita conocer el origen.'
      - 'Un Repository puede coordinar dos Services.'
docRefs:
  - label: 'Guide to app architecture'
    url: 'https://docs.flutter.dev/app-architecture/guide'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Common architecture concepts'
    url: 'https://docs.flutter.dev/app-architecture/concepts'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Notifier class — Riverpod API'
    url: 'https://pub.dev/documentation/riverpod/latest/riverpod/Notifier-class.html'
    kind: 'package'
    version: 'Riverpod 3.x'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué transforma un ViewModel y qué coordina un Repository?'
  - '¿Qué diferencia existe entre ref.watch(provider) y ref.read(provider.notifier)?'
  - '¿Por qué feature-first reduce distancia cognitiva frente a agrupar toda la app por tipo?'
  - '¿Qué condiciones justifican añadir Service o una capa de dominio?'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/features/journal'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_model_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Arquitectura no significa acumular carpetas. Significa que una decisión tiene un lugar claro, que puedes probarla sin levantar todo el sistema y que sustituir una dependencia no obliga a reescribir sus consumidores.

La guía oficial de Flutter propone separar dos grandes capas:

- **UI:** View y ViewModel.
- **Datos:** Repository y, cuando existe una tecnología externa concreta, Service.

MVVM nombra la separación de presentación. Riverpod hace observable el estado e inyecta dependencias. Feature-first organiza archivos por capacidad. Clean Architecture aporta reglas de límites y dirección de dependencias. Cubit o Bloc son otros mecanismos para modelar cambios de estado. No compiten todos en la misma categoría.

## Responsabilidades con entradas y salidas

### View

Compone widgets, presenta un estado y reenvía eventos. Puede decidir layout, animación, foco y condiciones simples de presentación. No interpreta JSON ni consulta una base de datos.

### ViewModel

Recibe eventos, solicita datos a repositorios y transforma resultados en estado listo para la View. En Riverpod, un `Notifier<JournalState>` puede cumplir ese papel. No debe devolver widgets ni necesitar `BuildContext` para validar datos.

### Repository

Es la fuente de verdad de un tipo de dato para la aplicación. Ofrece operaciones significativas, transforma modelos y decide políticas como caché, reintentos o coordinación de fuentes. La interfaz protege a consumidores de detalles.

### Service

Habla con un sistema específico: HTTP, SQLite, Firebase, archivo o plugin. No es obligatorio cuando un repositorio en memoria resuelve el caso. Añadirlo sin una fuente externa crea una capa que solo reenvía llamadas.

```text
evento → View → ViewModel → Repository → Service externo
            ↑       │            │
            └── UI State ← modelos┘
```

Los datos vuelven hacia la View. Las dependencias se programan contra contratos que puedan sustituirse.

## Feature-first mantiene junta una capacidad

El starter agrupa la bitácora así:

```text
lib/
  core/
    theme/
  features/
    journal/
      data/
        models/
        journal_repository.dart
        in_memory_journal_repository.dart
      presentation/
        journal_state.dart
        journal_view_model.dart
        journal_view.dart
        widgets/
```

Para entender una acción recorres una sola feature. Una estructura global `screens/`, `models/`, `repositories/` puede funcionar en proyectos pequeños, pero la distancia crece al añadir capacidades. Feature-first tampoco implica repetir infraestructura: temas, cliente de red y utilidades realmente transversales pueden vivir en `core/`.

No agregues `domain/` por reflejo. La guía trata la capa de dominio como opcional cuando una regla es compleja, reusable entre ViewModels o combina repositorios. Un caso de uso que solo llama un método con los mismos argumentos añade navegación sin aislar una decisión.

## Riverpod Notifier como mecanismo

El laboratorio registra un contrato y su implementación:

```dart
final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => InMemoryJournalRepository(),
);

final journalViewModelProvider =
    NotifierProvider<JournalViewModel, JournalState>(JournalViewModel.new);
```

El ViewModel obtiene la dependencia y publica estado:

```dart
class JournalViewModel extends Notifier<JournalState> {
  late JournalRepository _repository;

  @override
  JournalState build() {
    _repository = ref.watch(journalRepositoryProvider);
    return JournalState(entries: _repository.getAll());
  }

  void deleteEntry(String id) {
    _repository.delete(id);
    state = JournalState(entries: _repository.getAll());
  }
}
```

La View usa `ref.watch(journalViewModelProvider)` para reconstruirse cuando cambia el valor expuesto. Para enviar un comando usa `ref.read(journalViewModelProvider.notifier)`. No muta directamente la lista observada.

`Notifier` inicializa estado de forma síncrona. Si la inicialización requiere `await`, revisa `AsyncNotifier` en la documentación de la versión instalada en lugar de introducir un Future sin contrato. El paquete es una herramienta: los límites deben seguir comprensibles aunque cambies el mecanismo.

## Inyección que produce pruebas baratas

Un provider permite sustituir la implementación sin cambiar la ViewModel:

```dart
final repository = InMemoryJournalRepository();
final container = ProviderContainer(
  overrides: [journalRepositoryProvider.overrideWithValue(repository)],
);
addTearDown(container.dispose);

final viewModel = container.read(journalViewModelProvider.notifier);
expect(viewModel.createEntry(title: 'Idea', body: 'Separar límites'), isTrue);
expect(container.read(journalViewModelProvider).entries.single.title, 'Idea');
```

Esto es inyección de dependencias concreta: producción recibe una implementación y el test otra controlable. No necesitas red para comprobar reglas de título.

## P — Predice

Traza `createEntry` desde `JournalEditorDialog._save`. Marca dónde se normaliza el título, dónde se crea el modelo, dónde se publica `JournalState` y qué `ref.watch` provoca la reconstrucción. Antes de ejecutar, predice qué ocurre si el título solo contiene espacios.

Después traza `deleteEntry`. Comprueba que la View conoce el identificador y el comando, pero no sabe cómo el repositorio elimina internamente.

## E — Escribe

Añade un test unitario del límite de 80 caracteres usando el `ProviderContainer` ya presente. Actúa a través de `JournalViewModel`, observa `JournalState` y confirma que el repositorio no recibió una entrada inválida. Evita inspeccionar campos privados: prueba el contrato público.

Luego crea una segunda implementación fake solo si necesitas simular un fallo que el repositorio en memoria no representa. Cada doble debe responder a una hipótesis, no existir por costumbre.

## N — Nombra el fallo

- **View importa cliente HTTP:** mezcla presentación y transporte; una prueba de widget depende de red.
- **Repository recibe BuildContext:** datos depende de UI; no puede usarse desde CLI o isolate sin Flutter.
- **ViewModel devuelve AlertDialog:** lógica de presentación se filtra al estado; un unit test necesita widgets.
- **Widget modifica una lista expuesta:** existe más de un escritor y el cambio deja de ser explícito.

Nombra siempre la consecuencia verificable: qué cambio obliga a editar más archivos o qué prueba requiere demasiado entorno.

## S — Sustenta

En **Guide to app architecture**, lee overview, UI layer, data layer y solo después optional domain layer. Haz una tabla de componente, entrada, salida y dependencia permitida. En **Common architecture concepts**, confirma separación por capas y por feature.

En la API de `Notifier`, identifica el tipo genérico, el contrato de `build`, la propiedad `state` y el ejemplo mínimo. La guía responde «por qué y dónde»; la referencia del paquete responde «qué firma existe». Comprueba el `pubspec.yaml` antes de copiar una API de otro major.

## A — Argumenta

Una bitácora de una pantalla podría funcionar con un solo `StatefulWidget`. Defiende por qué aquí Repository + ViewModel aportan valor: el proyecto enseña sustitución de fuente, valida sin renderizar UI y prueba CRUD por capas. Defiende también por qué no hay Service ni UseCase todavía: no existe sistema externo ni regla compartida que los justifique.

## R — Reaplica

Imagina API remota y caché local. Conserva `JournalView` y los comandos del ViewModel. Convierte el contrato del Repository a operaciones asíncronas y estados explícitos; añade `RemoteJournalService` y `LocalJournalService`; deja que el Repository coordine ambos.

Dibuja las flechas antes de crear archivos. Si la UI importa los services, el límite falló. Termina ejecutando el test unitario existente y `fvm flutter analyze`: la arquitectura debe verse en la facilidad de sustituir dependencias, no en el número de carpetas.
