---
id: 'F06-L04'
trackId: 'flutter'
moduleId: 'F06'
kind: 'taller'
order: 3
slug: 'probar-el-viewmodel-sin-interfaz'
title: 'Probar el ViewModel sin abrir una pantalla'
summary: 'Comprueba reglas y transiciones de estado con un ProviderContainer, sin bombear un solo frame.'
estimatedMinutes: 60
objectives:
  - 'Probar un Notifier con un ProviderContainer y dependencias sustituidas.'
  - 'Comprobar una transición de estado y no solo un valor final.'
  - 'Cubrir las reglas de validación y su efecto sobre el estado.'
prerequisites: ['F06-L03']
activities:
  - id: 'predecir-estado-invalido'
    kind: 'attempt'
    prompt: 'Sin abrir las pruebas, predice qué pasa con la lista y con el mensaje de error cuando createEntry recibe un título vacío.'
    required: true
    hints:
      - 'La operación devuelve un valor además de cambiar el estado.'
      - 'Un fallo de validación no debe agregar nada a la lista.'
  - id: 'probar-validacion'
    kind: 'evidence'
    prompt: 'Agrega una prueba que compruebe que un título de más de 80 caracteres no crea la entrada y publica su mensaje. Ejecuta el archivo y pega la salida.'
    required: true
    hints:
      - 'Lee el estado antes y después de llamar al comando.'
      - 'El mensaje exacto está en el ViewModel.'
  - id: 'sustentar-container'
    kind: 'source'
    prompt: 'En Notifier class, encuentra cómo se lee el estado de un Notifier fuera de un widget y qué hay que liberar al terminar.'
    required: true
    sourceLabel: 'Notifier class — Riverpod API'
    hints:
      - 'Busca cómo se obtiene el notifier desde un contenedor.'
      - 'Anota qué recurso debe liberarse.'
  - id: 'defender-cobertura'
    kind: 'judgment'
    prompt: 'Decide qué reglas del ViewModel merecen una prueba propia y cuáles no, y nombra el costo de probar de más.'
    required: true
    hints:
      - 'Una prueba por rama de validación suele valer la pena.'
      - 'Probar detalles internos acopla la prueba a la implementación.'
docRefs:
  - label: 'Notifier class — Riverpod API'
    url: 'https://pub.dev/documentation/riverpod/latest/riverpod/Notifier-class.html'
    kind: 'package'
    version: 'Riverpod 3.x'
    lastVerified: '2026-08-23'
  - label: 'Testing Flutter apps'
    url: 'https://docs.flutter.dev/testing/overview'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cómo se lee el estado de un Notifier sin montar un widget?'
  - 'En un archivo vacío, vuelve a escribir una prueba de validación del ViewModel, sin mirar el original.'
  - 'Explica en voz alta la diferencia entre comprobar un valor final y comprobar una transición.'
  - 'Agrega una regla nueva al ViewModel y escribe su prueba antes que su implementación.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'test/features/journal/presentation/journal_view_model_test.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_model_test.dart'
  analyzeCommand: 'fvm flutter analyze'
---

Esta es la capa donde viven las reglas, y por tanto donde una prueba compra más por lo que cuesta.

## Sin widgets, sin frames

```dart
test('createEntry rechaza un título vacío', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final viewModel = container.read(journalViewModelProvider.notifier);
  final creada = viewModel.createEntry(title: '   ', body: 'Cuerpo');

  expect(creada, isFalse);
  expect(container.read(journalViewModelProvider).entries, isEmpty);
  expect(
    container.read(journalViewModelProvider).validationError,
    'Ponle un título antes de guardarla.',
  );
});
```

Ni `WidgetTester`, ni `pump`, ni árbol de widgets. Un contenedor, un comando, tres comprobaciones. Milisegundos.

El `addTearDown(container.dispose)` no es opcional: un contenedor sin liberar mantiene vivos los providers entre pruebas y produce fallos que dependen del orden de ejecución.

## Comprobar la transición, no solo el final

Fíjate en que la prueba comprueba **tres cosas distintas**:

1. el valor devuelto por el comando (`false`)
2. que la lista **no** creció
3. que el mensaje publicado es el correcto

Comprobar solo la primera dejaría pasar un `ViewModel` que devuelve `false` y aun así guarda la entrada. Comprobar solo la tercera dejaría pasar uno que publica el mensaje y también guarda.

Una regla de validación tiene dos efectos —impedir y avisar— y los dos merecen comprobarse.

## Una prueba por rama

El `ViewModel` de la bitácora tiene dos reglas: título vacío y título de más de 80 caracteres. Son dos ramas con dos mensajes distintos, así que son dos pruebas. Fusionarlas en una sola con dos `expect` funciona hasta que falla: el informe dice «la prueba de validación falló» y no cuál de las dos reglas se rompió.

## Intento · antes de mirar

Predice, antes de abrir el archivo:

- qué devuelve `createEntry` con un título vacío
- cuántas entradas hay en la lista después
- qué mensaje queda publicado
- qué pasa si después llamas a `clearValidationError`

## Evidencia · ejecuta y compara

Agrega la prueba de la regla de los 80 caracteres y ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_model_test.dart
```

Pega la salida. Después rompe la regla en el `ViewModel` —sube el límite a 200— y comprueba que tu prueba se pone roja.

## Fuente · lee con una pregunta

Abre **Notifier class — Riverpod API**. Dos preguntas: ¿cómo se obtiene el notifier desde un contenedor?, ¿qué hay que liberar al terminar? Anota el encabezado.

## Criterio · decide y acepta el costo

Decide qué merece una prueba propia. Cada rama de validación, casi seguro. ¿El orden interno de las comprobaciones? Probablemente no: eso ata la prueba a la implementación y te obliga a reescribirla en cada refactor.

Nombra el costo de probar de más: una suite que se rompe cuando el comportamiento no cambió deja de ser una señal y pasa a ser un impuesto.

En la última lección aparece el nivel que ninguno de los dos anteriores puede cubrir: ¿puede una persona completar el recorrido?
