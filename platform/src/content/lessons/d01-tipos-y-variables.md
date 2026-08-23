---
id: 'D01-L01'
trackId: 'dart'
moduleId: 'D01'
order: 0
slug: 'tipos-valores-y-variables'
title: 'Un tipo es una promesa verificable'
summary: 'Comprende qué sabe el analizador sobre cada valor y cuándo var, final y const expresan contratos distintos.'
estimatedMinutes: 75
objectives:
  - 'Distinguir tipo estático de tipo en tiempo de ejecución.'
  - 'Elegir var, final o const según mutabilidad y momento de construcción.'
  - 'Usar el analizador para localizar una contradicción de tipos.'
prerequisites: ['D00-L01']
activities:
  - id: 'predecir-asignaciones'
    kind: 'predict'
    prompt: 'Predice cuáles declaraciones y reasignaciones del ejemplo compilarán; justifica cada respuesta sin ejecutarlo.'
    required: true
    hints:
      - 'Separa dos preguntas: ¿puede cambiar la variable?, ¿puede cambiar el objeto?'
      - 'La inferencia no convierte a var en un tipo dinámico.'
  - id: 'resolver-m02'
    kind: 'code'
    prompt: 'Implementa los ejercicios de lib/m02_tipos.dart y ejecuta su archivo de tests.'
    required: true
    hints:
      - 'Empieza por leer cada firma antes de la instrucción del ejercicio.'
      - 'Resuelve un grupo de tests a la vez.'
  - id: 'diagnosticar-tipo'
    kind: 'debug'
    prompt: 'Provoca una asignación incompatible en un archivo de prueba, lee el diagnóstico y explica qué tipo esperaba el analizador.'
    required: true
    hints:
      - 'El mensaje suele nombrar el tipo recibido y el tipo esperado.'
      - 'No agregues dynamic para silenciar el problema.'
  - id: 'comparar-fuentes'
    kind: 'docs'
    prompt: 'Consulta Variables y Built-in types; encuentra una frase o ejemplo que distinga inferencia de ausencia de tipo.'
    required: true
    hints:
      - 'Busca type inference dentro de la página.'
      - 'Registra el encabezado y una paráfrasis.'
  - id: 'defender-const'
    kind: 'explain'
    prompt: 'Explica por qué una lista const y una variable final no prometen lo mismo.'
    required: true
    hints:
      - 'Pregunta qué queda fijo: la referencia, el objeto o ambos.'
      - 'Incluye el momento en que se conoce el valor.'
  - id: 'modelar-precio'
    kind: 'transfer'
    prompt: 'Diseña la representación de un precio, un descuento y una moneda; elige tipos y mutabilidad y defiende cada decisión.'
    required: true
    hints:
      - 'El dinero decimal introduce errores de representación binaria.'
      - 'Una moneda se parece más a un dato de configuración que a un contador.'
docRefs:
  - label: 'Variables'
    url: 'https://dart.dev/language/variables'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'The Dart type system'
    url: 'https://dart.dev/language/type-system'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué var edad = 30 no permite asignar después un String?'
  - '¿Qué garantiza final y qué garantía adicional ofrece const?'
  - '¿Cuál es la diferencia entre el tipo estático de una referencia y el tipo real del objeto?'
  - '¿Por qué conviene representar centavos con int en lugar de double?'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m02_tipos.dart'
  testCommand: 'fvm dart test test/m02_tipos_test.dart'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm02_tipos'
---

Un tipo no es una etiqueta decorativa. Es una promesa sobre las operaciones que serán válidas. El analizador usa esa promesa antes de ejecutar el programa y te señala contradicciones mientras todavía son baratas de corregir.

## Dos preguntas distintas

Observa este código:

```dart
Object entrada = '42';

if (entrada is String) {
  print(entrada.length);
}
```

El tipo estático de `entrada` es `Object`: eso es lo que se declaró y lo que puede asumir cualquier línea sin más evidencia. El objeto actual es un `String`. Dentro del `if`, la comprobación `is String` aporta evidencia y Dart promueve temporalmente la variable para permitir `length`.

Confundir ambos niveles produce dos errores frecuentes: usar `dynamic` para evitar pensar en el contrato o forzar conversiones con `as` sin haber comprobado el dato.

## `var`, `final` y `const`

```dart
var intentos = 0;
final inicio = DateTime.now();
const diasDeRepaso = 4;
```

- `var` pide al compilador inferir el tipo; la variable puede reasignarse con valores compatibles.
- `final` permite una sola asignación, incluso si el valor se obtiene durante la ejecución.
- `const` describe un valor conocido en compilación y profundamente inmutable cuando el objeto también es constante.

`final` no vuelve inmutable al objeto apuntado:

```dart
final etiquetas = <String>[];
etiquetas.add('dart'); // La referencia no cambió; la lista sí.
```

La pregunta correcta no es «¿cuál palabra se ve más profesional?», sino «¿qué cambios debe permitir este modelo?».

## P — Predice

Antes de tocar `m02_tipos.dart`, escribe qué ocurriría al reasignar cada variable anterior y qué tipo infiere Dart. Incluye una predicción para `final lista = <int>[]` seguida de `lista.add(1)`.

## E — Escribe

Trabaja una función a la vez. Lee primero su firma: entradas, salida y nulabilidad. Después ejecuta solo los tests del módulo:

```bash
cd dart_lab
fvm dart test test/m02_tipos_test.dart
```

Un test rojo acota el contrato que aún no cumples; no juzga tu capacidad.

## N — Nombra el fallo

Cuando falle un test, clasifica el problema antes de editar:

- **tipo:** una operación no es válida para la promesa declarada;
- **valor:** el tipo es correcto pero el cálculo no;
- **mutabilidad:** cambiaste algo que debía permanecer fijo;
- **representación:** elegiste un tipo que no conserva la información necesaria.

Para `formatearPrecio`, por ejemplo, un resultado aproximado no basta: el contrato exige centavos exactos y dos dígitos.

## S — Sustenta

En la documentación de Variables, localiza la recomendación sobre inferencia para variables locales. Después abre Built-in types y encuentra cómo Dart trata `int`, `double`, `String`, `bool`, listas y mapas. Anota el encabezado que responde cada pregunta; así podrás regresar sin releer toda la página.

## A — Argumenta

Defiende una decisión concreta: ¿por qué `diasHabiles` debe ser `const`, pero la hora de inicio de una sesión solo puede ser `final`? Una buena respuesta menciona tanto mutabilidad como momento de evaluación.

## R — Reaplica

Modela sin código una compra con subtotal, moneda, artículos y fecha. Especifica tipo y mutabilidad de cada dato. Después imagina que la compra permite agregar artículos: revisa qué decisión cambia y cuál permanece.

Cuando todos los tests pasen, ejecuta `fvm dart analyze`. Solo entonces compara con otra implementación y pregúntate cuál hace más visible el contrato.
