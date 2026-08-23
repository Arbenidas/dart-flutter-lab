---
id: 'D03-L01'
trackId: 'dart'
moduleId: 'D03'
order: 0
slug: 'decisiones-ciclos-y-patterns'
title: 'El control de flujo hace visible tu lógica'
summary: 'Convierte reglas y casos borde en ramas exhaustivas, ciclos acotados y patterns que describen la forma del dato.'
estimatedMinutes: 90
objectives:
  - 'Elegir entre if, switch y un ciclo según la estructura del problema.'
  - 'Ordenar casos desde el más específico al más general.'
  - 'Usar patterns para comprobar y desestructurar datos.'
prerequisites: ['D02-L01']
activities:
  - id: 'predecir-fronteras'
    kind: 'predict'
    prompt: 'Antes de ejecutar, completa una tabla con la clasificación esperada para -1, 0, 12, 13, 17, 18, 64 y 65.'
    required: true
    hints:
      - 'Cada frontera debe aparecer a ambos lados de un cambio de categoría.'
      - 'No agrupes cero con números negativos.'
  - id: 'resolver-m04'
    kind: 'code'
    prompt: 'Implementa lib/m04_control.dart, primero con la construcción más directa y luego refactoriza donde el módulo lo solicita.'
    required: true
    hints:
      - 'Haz pasar un grupo de tests antes de iniciar el siguiente.'
      - 'Para switch, empieza por listar todos los resultados posibles.'
  - id: 'diagnosticar-orden'
    kind: 'debug'
    prompt: 'Construye un caso donde una rama general capture un valor antes que la rama específica y explica por qué el orden cambia el resultado.'
    required: true
    hints:
      - 'Prueba a pensar en el punto (0, 0) frente a cualquier punto con y igual a cero.'
      - 'El primer patrón que coincide gana.'
  - id: 'rastrear-patterns'
    kind: 'docs'
    prompt: 'En la guía oficial de Patterns, identifica dónde pueden aparecer los patterns y registra dos lugares además de switch.'
    required: true
    hints:
      - 'Busca el encabezado Places patterns can appear.'
      - 'Relaciona cada lugar con una transformación de datos real.'
  - id: 'comparar-if-switch'
    kind: 'explain'
    prompt: 'Compara la versión if/else y la versión switch de una clasificación: ¿cuál hace más visible la exhaustividad y los límites?'
    required: true
    hints:
      - 'No respondas solo cuál tiene menos líneas.'
      - 'Evalúa orden, cobertura y facilidad para agregar un caso.'
  - id: 'transferir-estado'
    kind: 'transfer'
    prompt: 'Modela los estados de una descarga —pendiente, activa, completada y fallida— y describe una rama para cada uno sin usar strings libres.'
    required: true
    hints:
      - 'Una sealed class o un enum hacen finito el conjunto de estados.'
      - 'Pregunta qué datos adicionales necesita cada estado.'
docRefs:
  - label: 'Branches'
    url: 'https://dart.dev/language/branches'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Loops'
    url: 'https://dart.dev/language/loops'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Patterns'
    url: 'https://dart.dev/language/patterns'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué conviene probar ambos lados de cada frontera numérica?'
  - '¿Qué diferencia hay entre un switch statement y una switch expression?'
  - '¿Por qué el orden de los patterns puede cambiar el resultado?'
  - '¿Cuándo elegirías un ciclo for en lugar de transformar un Iterable?'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m04_control.dart'
  testCommand: 'fvm dart test test/m04_control_test.dart'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm04_control'
---

Una condición traduce una regla del problema a una ruta de ejecución. Si esa regla queda repartida en comparaciones solapadas, el código puede funcionar con los ejemplos fáciles y fallar justamente en las fronteras.

## Diseña los casos antes de escribir la sintaxis

Supón que una aplicación clasifica una temperatura:

```dart
String describirTemperatura(int valor) => switch (valor) {
  < 0 => 'bajo cero',
  0 => 'cero',
  <= 30 => 'templada',
  _ => 'alta',
};
```

La expresión `switch` devuelve un valor. Las ramas se leen como una partición del dominio y `_` cubre lo restante. El orden sigue importando: una rama amplia colocada primero puede volver inalcanzable una más precisa.

No todo debe ser `switch`:

- usa `if` cuando decides entre pocas condiciones que no forman un catálogo claro;
- usa `switch` cuando un valor tiene variantes reconocibles y quieres ver su cobertura;
- usa un ciclo cuando una acción se repite sobre datos;
- usa transformaciones de `Iterable` cuando expresan mejor qué resultado construyes.

## P — Predice

Construye una tabla de fronteras para `clasificarEdad`. No escribas solo un ejemplo por categoría: incluye el valor inmediatamente anterior y posterior a cada cambio. Esa tabla será tu primera especificación.

Después predice qué pattern capturaría `(0, 0)` si el caso `(_, 0)` apareciera antes del caso exacto.

## E — Escribe

Empieza `clasificarEdad` con `if / else if` porque hace visible cada comparación. Cuando los tests pasen, reescribe con una switch expression y vuelve a ejecutar. La segunda versión no debe cambiar el contrato:

```bash
cd dart_lab
fvm dart test test/m04_control_test.dart
```

En `fibonacci`, conserva la versión iterativa como solución principal. La recursiva sirve como experimento para hablar de costo, no como sinónimo de elegancia.

## N — Nombra el fallo

Cuando una rama produce un valor incorrecto, localiza una de estas causas:

- frontera inclusiva o exclusiva equivocada;
- caso específico después de uno general;
- caso faltante absorbido por `_`;
- normalización de entrada ausente;
- ciclo con inicio, condición o actualización incorrectos.

Describe el fallo con una entrada mínima. «Falla la edad 13 porque la condición anterior usa `<= 13`» es accionable; «el switch está mal» no lo es.

## S — Sustenta

Lee primero **Branches** para comparar statements y expressions. Luego abre **Patterns** y busca dónde pueden usarse además de `switch`. Registra un ejemplo propio de desestructuración en una declaración y otro en un `for`.

La documentación de referencia enumera posibilidades; tu trabajo es conectar cada una con una necesidad. No uses un pattern solo porque es nuevo: úsalo cuando expresa la forma del dato con menos ambigüedad.

## A — Argumenta

Compara tus dos versiones de `clasificarEdad` con cuatro criterios:

1. visibilidad de los límites;
2. exhaustividad;
3. facilidad para agregar una categoría;
4. probabilidad de solapamiento.

La respuesta puede favorecer cualquiera de las dos, siempre que cites el problema concreto y no solo la cantidad de líneas.

## R — Reaplica

Modela una descarga con estados finitos. Imagina luego que el estado fallido contiene un mensaje y el completado una ruta local. ¿Sigue bastando un enum o una jerarquía sellada representa mejor los datos de cada variante?

Finaliza con `fvm dart analyze`. Un control de flujo correcto no solo produce el resultado esperado: hace difícil olvidar un caso nuevo cuando el dominio cambia.
