---
id: 'F06-L05'
trackId: 'flutter'
moduleId: 'F06'
kind: 'taller'
order: 4
slug: 'widget-test-y-el-arte-de-pump'
title: 'El widget test comprueba que alguien puede terminar'
summary: 'Monta la pantalla en una prueba, distingue pump de pumpAndSettle y cierra el proyecto con las tres capas verdes.'
estimatedMinutes: 65
objectives:
  - 'Montar un widget en una prueba y encontrar elementos con finders.'
  - 'Distinguir pump de pumpAndSettle y saber cuándo cada uno se cuelga.'
  - 'Cerrar el proyecto verificando análisis, pruebas y compilación.'
prerequisites: ['F06-L04']
activities:
  - id: 'predecir-pump'
    kind: 'attempt'
    prompt: 'Sin abrir las pruebas, escribe qué diferencia esperas entre pump y pumpAndSettle, y en qué caso pumpAndSettle nunca terminaría.'
    required: true
    hints:
      - 'Uno avanza un frame; el otro avanza hasta que no queden animaciones.'
      - 'Piensa en un indicador de carga que gira para siempre.'
  - id: 'recorrido-completo'
    kind: 'evidence'
    prompt: 'Extiende el widget test para cubrir crear, editar y eliminar en un solo recorrido. Ejecuta el archivo y pega la salida.'
    required: true
    hints:
      - 'Los finders localizan por texto, por tipo o por clave.'
      - 'Después de cada interacción hace falta bombear al menos un frame.'
  - id: 'sustentar-tester'
    kind: 'source'
    prompt: 'En WidgetTester class, encuentra la diferencia documentada entre pump y pumpAndSettle y qué parámetro acepta cada uno.'
    required: true
    sourceLabel: 'WidgetTester class'
    hints:
      - 'Busca los dos métodos en la lista de la clase.'
      - 'Fíjate en qué devuelve pumpAndSettle.'
  - id: 'defender-limites'
    kind: 'judgment'
    prompt: 'Evalúa los límites de InMemoryJournalRepository y decide qué cambiaría al pasar a persistencia real; nombra qué pruebas seguirían valiendo.'
    required: true
    hints:
      - 'Un repositorio en memoria pierde todo al cerrar la app.'
      - 'Un contrato asíncrono cambia las firmas de todas las capas de arriba.'
docRefs:
  - label: 'WidgetTester class'
    url: 'https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'Testing Flutter apps'
    url: 'https://docs.flutter.dev/testing/overview'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo basta pump y cuándo necesitas pumpAndSettle?'
  - 'En un archivo vacío, vuelve a escribir un widget test que cree una entrada y compruebe que aparece, sin mirar.'
  - 'Explica en voz alta por qué un widget test puede pasar con la lógica de datos rota.'
  - 'Diseña el reemplazo del repositorio en memoria por persistencia y define qué pruebas nuevas hacen falta.'
lab:
  workspace: 'flutter_lab'
  targetPath: 'test/features/journal/presentation/journal_view_test.dart'
  testCommand: 'fvm flutter test test/features/journal/presentation/journal_view_test.dart'
  analyzeCommand: 'fvm flutter analyze'
  revealReference: true
---

Las dos capas anteriores demuestran que las piezas funcionan. Esta demuestra algo que ninguna de las dos puede: que **una persona puede completar el recorrido**.

## Montar y buscar

```dart
testWidgets('crear una entrada la muestra en la lista', (tester) async {
  await tester.pumpWidget(const ProviderScope(child: FlutterLabApp()));

  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).first, 'Primera');
  await tester.tap(find.text('Guardar'));
  await tester.pumpAndSettle();

  expect(find.text('Primera'), findsOneWidget);
});
```

`pumpWidget` monta el árbol. Los **finders** localizan elementos por texto, por tipo o por clave. `tap` y `enterText` simulan la interacción.

## pump y pumpAndSettle

|                   | qué hace                                                 | cuándo se usa                                    |
| ----------------- | -------------------------------------------------------- | ------------------------------------------------ |
| `pump()`          | avanza **un** frame                                      | tras un `setState` o un cambio de estado directo |
| `pumpAndSettle()` | avanza frames hasta que no queden animaciones pendientes | tras abrir o cerrar rutas y diálogos             |

Y la trampa: `pumpAndSettle` **nunca termina** si hay una animación infinita en pantalla. Un `CircularProgressIndicator` que gira para siempre cuelga la prueba hasta el timeout. En esos casos hay que usar `pump()` con una duración concreta.

Si una prueba de widget se queda colgada, esta es casi siempre la razón.

## Lo que un widget test no demuestra

Un recorrido verde puede convivir con un repositorio roto: si nada lo obliga a persistir de verdad, la pantalla muestra lo que tiene en memoria y la prueba pasa. Por eso las tres capas no son redundantes — cada una tapa un hueco que las otras dejan.

## Intento · antes de mirar

Escribe, antes de abrir el archivo:

- la diferencia entre `pump` y `pumpAndSettle`
- un caso concreto en que `pumpAndSettle` no terminaría nunca
- qué finder usarías para el botón «Guardar» y cuál para el campo de título

## Evidencia · ejecuta y compara

Extiende el widget test para cubrir crear, editar y eliminar en un solo recorrido. Ejecuta:

```bash
cd flutter_lab
fvm flutter test test/features/journal/presentation/journal_view_test.dart
```

Pega la salida. Si se cuelga, no cambies nada al azar: revisa qué `pumpAndSettle` está esperando una animación que no termina.

## Fuente · lee con una pregunta

Abre **WidgetTester class** y busca los dos métodos. Pregunta concreta: ¿qué devuelve `pumpAndSettle` y qué parámetro acepta? Anota el encabezado.

## Criterio de terminado

El proyecto está cerrado cuando estas tres cosas pasan desde un clon limpio:

```bash
cd flutter_lab
fvm flutter analyze
fvm flutter test
fvm flutter build web --release
```

Sin avisos, sin pruebas rojas y con la compilación completa.

## Criterio · decide y acepta el costo

Evalúa los límites de `InMemoryJournalRepository`: pierde todo al cerrar la app, no soporta varios dispositivos y no tiene concurrencia.

Diseña su reemplazo por persistencia real y responde tres cosas concretas: qué firmas cambian —todo lo que hoy es síncrono pasaría a devolver `Future`—, qué se propaga hacia arriba, y **cuáles de tus pruebas actuales seguirían valiendo tal cual**.

Esa última respuesta mide la calidad de la arquitectura que construiste: si las pruebas del `ViewModel` sobreviven al cambio de repositorio, la separación era real.
