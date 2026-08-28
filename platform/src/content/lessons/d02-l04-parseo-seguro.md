---
id: 'D02-L04'
trackId: 'dart'
moduleId: 'D02'
kind: 'taller'
order: 3
slug: 'parseo-seguro-de-entrada-externa'
title: 'Datos de afuera se parsean, no se confían'
summary: 'Distingue tryParse de parse y convierte texto de usuario en un valor validado o en una ausencia explícita.'
estimatedMinutes: 55
objectives:
  - 'Elegir entre int.tryParse e int.parse según el origen del dato.'
  - 'Separar la validación sintáctica de la validación de dominio.'
  - 'Distinguir una entrada inválida de una entrada válida fuera de rango.'
prerequisites: ['D02-L03']
activities:
  - id: 'predecir-parseo'
    kind: 'attempt'
    prompt: 'Sin ejecutar nada, escribe qué debería devolver parsearEdad con «30», «abc», «-1», «500» y « 30 », y en qué orden harías las comprobaciones.'
    required: true
    hints:
      - 'Hay dos validaciones distintas: que sea un número y que sea una edad posible.'
      - 'Los espacios alrededor son un caso real, no un capricho del test.'
  - id: 'resolver-m03-4'
    kind: 'evidence'
    prompt: 'Implementa parsearEdad y ejecuta sus pruebas. Pega la salida del caso con espacios alrededor.'
    required: true
    hints:
      - 'tryParse devuelve int? en lugar de lanzar.'
      - 'trim se aplica antes de intentar convertir.'
  - id: 'sustentar-tryparse'
    kind: 'source'
    prompt: 'En Built-in types, localiza cómo se convierte texto a número y encuentra qué distingue a la variante que no lanza.'
    required: true
    sourceLabel: 'Built-in types'
    hints:
      - 'Busca la sección de numbers y strings.'
      - 'Anota el nombre exacto del método y qué devuelve ante una entrada inválida.'
  - id: 'defender-rango'
    kind: 'judgment'
    prompt: 'Decide si «500» debería devolver null igual que «abc», o si merecen respuestas distintas. Nombra qué información se pierde con tu elección.'
    required: true
    hints:
      - 'Una es un error de formato; la otra es un dato bien formado pero imposible.'
      - 'Un formulario querría mostrar mensajes distintos en cada caso.'
docRefs:
  - label: 'Built-in types'
    url: 'https://dart.dev/language/built-in-types'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Understanding null safety'
    url: 'https://dart.dev/null-safety/understanding-null-safety'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo usarías int.tryParse y cuándo int.parse?'
  - 'En un archivo vacío, vuelve a escribir parsearEdad sin mirar tu solución.'
  - 'Explica en voz alta la diferencia entre una entrada mal formada y una bien formada pero fuera de rango.'
  - 'Modela la lectura de una fecha desde un formulario: entrada vacía, texto inválido y fecha válida deben quedar distinguibles.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m03_null_safety.dart'
  testCommand: 'fvm dart test test/m03_null_safety_test.dart --name m03-4'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm03-4'
---

Todo lo que entra desde afuera —el usuario, una API, un archivo— es texto hasta que demuestres lo contrario. Esta lección es sobre esa frontera.

## Dos funciones, dos actitudes

```dart
int.parse('abc');    // lanza FormatException
int.tryParse('abc'); // devuelve null
```

La regla práctica es sobre el **origen** del dato, no sobre tu gusto:

- Si el dato viene de afuera, un fallo es un **caso esperado**: usa `tryParse` y trata el `null`.
- Si el dato lo controlas tú y un fallo sería un bug, usa `parse` y deja que explote fuerte y temprano.

Usar `parse` sobre entrada de usuario convierte cada dedazo en una excepción no atrapada.

## Dos validaciones, no una

`parsearEdad` tiene que responder dos preguntas distintas:

1. **¿Es un número?** — validación sintáctica. La resuelve `tryParse`.
2. **¿Es una edad posible?** — validación de dominio. Ningún método de la librería la conoce: el rango 0–130 sale de tu problema, no del lenguaje.

Confundirlas es el error clásico. `'500'` es un entero impecable y una edad imposible.

Y hay un tercer detalle práctico: `' 30 '` con espacios. Los formularios los mandan constantemente. `trim` va **antes** de intentar convertir.

## Intento · antes de mirar

Escribe la tabla completa antes de tocar el archivo:

| Entrada  | Resultado esperado |
| -------- | ------------------ |
| `'30'`   | ?                  |
| `'abc'`  | ?                  |
| `'-1'`   | ?                  |
| `'500'`  | ?                  |
| `' 30 '` | ?                  |

Y anota el orden en que harías las comprobaciones.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m03_null_safety_test.dart --name m03-4
```

Pega la salida del caso con espacios. Si falla solo ese, el problema no es la validación: es el orden.

## Fuente · lee con una pregunta

Abre **Built-in types** y busca cómo se convierte texto a número. Pregunta concreta: ¿cuál es la variante que no lanza y qué devuelve ante una entrada inválida? Anota el nombre exacto del método.

## Criterio · decide y acepta el costo

Ahora la decisión de diseño: `'abc'` y `'500'` devuelven ambos `null` con este contrato. ¿Está bien? Un formulario querría decir «eso no es un número» en un caso y «esa edad no existe» en el otro, y con `null` no puede distinguirlos.

Defiende el contrato tal como está, o propón uno que conserve el motivo, y nombra qué cuesta cada opción. En D08 vas a tener las herramientas para modelar la segunda; hoy basta con **ver** la pérdida.

En la última lección del módulo aparece la promesa más peligrosa de null safety: `late`.
