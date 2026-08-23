---
id: 'D14-L01'
trackId: 'dart'
moduleId: 'D14'
order: 0
slug: 'calidad-pruebas-fakes-y-limites-de-datos'
title: 'La prueba mejora el diseño cuando observa contratos'
summary: 'Combina formatter, analyzer y tests; separa Repository de Service y usa fakes que revelan comportamiento.'
estimatedMinutes: 135
objectives:
  - 'Distinguir las garantías del formatter, analyzer y suite de pruebas.'
  - 'Separar una fuente externa en Service de la fuente de verdad del dominio en Repository.'
  - 'Escribir tests por comportamiento con fakes pequeños e inyectados por constructor.'
prerequisites: ['D13-L01']
activities:
  - id: 'predecir-garantias'
    kind: 'predict'
    prompt: 'Clasifica seis defectos —espaciado, tipo incorrecto, rama faltante, total equivocado, archivo ilegible y llamada duplicada— según si formatter, analyzer o test puede detectarlos. Señala los que requieren más de una herramienta.'
    required: true
    hints:
      - 'Formato no demuestra comportamiento; análisis estático no conoce todos los requisitos.'
      - 'Una prueba solo protege el caso y contrato que expresa.'
  - id: 'escribir-fake'
    kind: 'code'
    prompt: 'En un scratch local, define EntradaService, un FakeEntradaService en memoria y EntradaRepository que valide y transforme mapas. Escribe tests de éxito, esquema inválido y guardado sin tocar disco.'
    required: true
    hints:
      - 'Inyecta el service por constructor.'
      - 'El fake implementa el mismo contrato y guarda entradas observables para la prueba.'
  - id: 'diagnosticar-prueba'
    kind: 'debug'
    prompt: 'Refactoriza una prueba que verifica cada llamada privada y se rompe al cambiar un ciclo por map aunque el resultado siga igual. Conserva solo salida, estado persistido y error público.'
    required: true
    hints:
      - 'Prueba qué promete la unidad, no cada paso interno.'
      - 'Una interacción importa si forma parte del contrato con una dependencia externa.'
  - id: 'rastrear-herramientas'
    kind: 'docs'
    prompt: 'En dart format, analysis, testing y la guía oficial de arquitectura, identifica la garantía de cada herramienta y las responsabilidades distintas de Repository y Service.'
    required: true
    hints:
      - 'Service envuelve una fuente externa; Repository administra datos del dominio como fuente de verdad.'
      - 'Las recomendaciones de arquitectura son adaptables, no una obligación de agregar capas vacías.'
  - id: 'defender-doble'
    kind: 'explain'
    prompt: 'Compara fake manual, stub y mock de interacciones para probar un repositorio. Defiende el doble mínimo que mantenga el test legible y resistente al refactor.'
    required: true
    hints:
      - 'Un fake tiene una implementación funcional simplificada.'
      - 'Verifica llamadas solo cuando la colaboración observada es el comportamiento importante.'
  - id: 'transferir-gate'
    kind: 'transfer'
    prompt: 'Diseña un quality gate local y de CI: formato sin cambios, análisis sin errores y pruebas deterministas. Define orden, salida esperada y qué evidencia conservar ante un fallo.'
    required: true
    hints:
      - 'Falla rápido en lo más barato antes de ejecutar lo más lento.'
      - 'Fija SDK y dependencias para reducir diferencias entre máquinas.'
docRefs:
  - label: 'dart format'
    url: 'https://dart.dev/tools/dart-format'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Customizing static analysis'
    url: 'https://dart.dev/tools/analysis'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'Dart testing'
    url: 'https://dart.dev/tools/testing'
    kind: 'guide'
    version: 'Dart 3.13'
    lastVerified: '2026-08-23'
  - label: 'test package'
    url: 'https://pub.dev/packages/test'
    kind: 'package'
    version: 'test 1.31.1'
    lastVerified: '2026-08-23'
  - label: 'Flutter architecture recommendations'
    url: 'https://docs.flutter.dev/app-architecture/recommendations'
    kind: 'guide'
    version: 'Guía oficial vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué garantía aporta formatter, analyzer y test, y qué no puede demostrar cada uno?'
  - '¿Cómo separas la responsabilidad de un Service de la de un Repository?'
  - '¿Por qué una prueba acoplada a pasos privados dificulta refactorizar?'
  - '¿Cuándo un fake manual comunica mejor la prueba que un mock de interacciones?'
---

Calidad no es una fase al final. Es un circuito corto: una herramienta elimina discusiones mecánicas, otra detecta contradicciones estáticas y las pruebas expresan comportamiento. Juntas permiten cambiar diseño sin perder la promesa.

## Tres herramientas, tres garantías

`dart format` produce una forma canónica. No decide si el algoritmo es correcto.

`dart analyze` aplica el sistema de tipos, reglas del lenguaje y lints configurados. Puede encontrar un retorno incompatible o código inalcanzable; no sabe que una comisión debía redondearse hacia arriba.

`dart test` ejecuta ejemplos convertidos en especificaciones. Solo protege los contratos y casos que escribiste. Una suite verde no demuestra ausencia total de bugs.

Un gate reproducible usa el SDK fijado por el proyecto:

```bash
cd dart_lab
fvm dart format .
fvm dart analyze
fvm dart test
```

En CI, configura el formatter en modo de comprobación para que falle sin reescribir. Ejecuta primero los pasos más rápidos y conserva el diagnóstico exacto.

## Service cruza la frontera; Repository administra el dato

La separación oficial de arquitectura Flutter aplica a estas clases Dart aunque todavía no exista interfaz gráfica. Un Service envuelve una fuente externa concreta: archivo, HTTP o SDK. Un Repository es la fuente de verdad para un tipo de dato, transforma representaciones y aplica reglas de acceso.

```dart
abstract interface class EntradaService {
  Future<List<Map<String, Object?>>> leer();
  Future<void> escribir(List<Map<String, Object?>> datos);
}

abstract interface class EntradaRepository {
  Future<List<Entrada>> obtenerTodas();
  Future<void> agregar(Entrada entrada);
}
```

El Service habla mapas porque esa es la frontera serializada. El Repository entrega `Entrada` validada y decide cómo actualizar la colección. El comando CLI depende del Repository, no de `File`.

No agregues una capa de casos de uso por rutina. Para una bitácora pequeña, el Repository y un controlador de comandos bastan. Extrae otra unidad solo cuando exista lógica compleja compartida o un motivo de prueba propio.

## Un fake es una implementación pequeña

```dart
final class FakeEntradaService implements EntradaService {
  List<Map<String, Object?>> datos = [];

  @override
  Future<List<Map<String, Object?>>> leer() async =>
      datos.map(Map<String, Object?>.from).toList();

  @override
  Future<void> escribir(List<Map<String, Object?>> nuevos) async {
    datos = nuevos.map(Map<String, Object?>.from).toList();
  }
}
```

El fake permite probar Repository sin disco. Conserva estado observable y comportamiento suficiente. No intenta reproducir permisos, bloqueos o fallos reales del sistema de archivos; esos pertenecen a pruebas del Service o integración.

## Prueba el contrato, no la coreografía privada

```dart
test('agregar conserva la entrada y permite recuperarla', () async {
  final service = FakeEntradaService();
  final repository = JsonEntradaRepository(service);
  const entrada = Entrada(id: 'e-1', texto: 'Practiqué tests');

  await repository.agregar(entrada);

  expect(await repository.obtenerTodas(), [entrada]);
});
```

La prueba observa resultado. Cambiar un ciclo por `map` no debería romperla. Verifica interacciones cuando sean contrato: por ejemplo, una escritura debe ocurrir una sola vez para evitar duplicar una operación externa no idempotente.

## P — Predice

Clasifica defectos reales. Un espacio inconsistente pertenece al formatter; asignar `String` a `int`, al analyzer; total incorrecto, a una prueba. Archivo inaccesible requiere una prueba del Service o integración. Una llamada duplicada puede necesitar un fake contador si esa interacción afecta el exterior.

Para cada uno escribe también qué herramienta **no** puede demostrar. Eso evita convertir una suite verde o análisis limpio en confianza absoluta.

## E — Escribe

Implementa contratos, fake y Repository en un scratch local. Escribe pruebas de lista vacía, agregar, JSON inválido y fallo de escritura. Usa preparación, acción y verificación visibles; no ocultes todo en helpers.

Ejecuta el gate con FVM. Introduce intencionalmente un fallo por herramienta y observa su salida. Luego revierte la causa y conserva una nota sobre qué evidencia fue más útil.

## N — Nombra el fallo

Clasifica la causa de una prueba frágil:

- **contrato ausente:** no está claro qué resultado importa;
- **detalle privado verificado:** la prueba replica la implementación;
- **doble sobredimensionado:** configura más comportamiento del necesario;
- **I/O mezclado:** una prueba unitaria depende de disco o red real;
- **estado compartido:** dos pruebas reutilizan datos mutables;
- **tiempo o azar real:** el resultado depende del reloj o identificadores no inyectados;
- **capa vacía:** una clase solo reenvía llamadas sin agregar límite o responsabilidad.

“El test es flaky” describe frecuencia. Nombra la fuente no determinista para poder quitarla.

## S — Sustenta

Lee **dart format**, **analysis** y **testing** con una pregunta: ¿qué entrada procesa y qué fallo puede emitir? Después abre las recomendaciones oficiales de arquitectura y localiza Repository, Service, inyección y pruebas separadas.

La guía Flutter es una fuente oficial para responsabilidades, no una orden de copiar toda la estructura en una CLI. Adapta el principio: una frontera externa sustituible y una fuente de verdad testeable.

## A — Argumenta

Un fake manual comunica bien cuando el contrato es pequeño y el estado en memoria ayuda a observar resultados. Un stub basta si solo necesitas devolver un valor fijo. Un mock de interacciones aporta valor cuando número u orden de llamadas forma parte del contrato; usado para cada método privado, acopla el test a la coreografía.

Defiende también Repository–Service. Separarlos vale si permite validar dominio sin I/O y probar el adaptador externo en aislamiento. Si ambos solo reenvían una función idéntica, revisa si existe una responsabilidad real.

## R — Reaplica

Diseña un gate que cualquier persona y CI puedan repetir con la misma versión: formato comprobado, análisis limpio y tests deterministas. Define orden, códigos de salida y artefactos de diagnóstico.

Transfiere el fake a reloj, identificadores y cliente HTTP. Cada dependencia no determinista que pasa por constructor abre un punto de control. El objetivo no es aumentar el número de clases: es hacer que una prueba pueda formular y comprobar una promesa sin levantar el mundo entero.
