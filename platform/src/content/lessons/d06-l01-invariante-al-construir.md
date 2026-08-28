---
id: 'D06-L01'
trackId: 'dart'
moduleId: 'D06'
kind: 'taller'
order: 0
slug: 'clases-objetos-e-invariantes'
title: 'Una invariante se valida una vez, al construir'
summary: 'Convierte una regla repetida en cada consumidor en una condición que el objeto garantiza desde que existe.'
estimatedMinutes: 60
objectives:
  - 'Validar una invariante en el constructor y lanzar ante un valor imposible.'
  - 'Explicar qué gana el resto del código cuando la clase garantiza la regla.'
  - 'Implementar == y hashCode de forma coherente.'
prerequisites: ['D05-L05']
activities:
  - id: 'predecir-fronteras-porcentaje'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué debería ocurrir al construir un Porcentaje con -1, 0, 100 y 101, y cuántos lugares tendrían que comprobar la regla si valor fuera público y mutable.'
    required: true
    hints:
      - 'Los valores de frontera son los que rompen implementaciones apuradas.'
      - 'Cuenta los consumidores: cada uno tendría que repetir la comprobación.'
  - id: 'resolver-m07-1'
    kind: 'evidence'
    prompt: 'Implementa el constructor de Porcentaje con su validación, == y hashCode. Ejecuta sus pruebas y pega la salida del caso de los extremos.'
    required: true
    hints:
      - 'RangeError.range te deja nombrar el mínimo, el máximo y el campo.'
      - 'Dos objetos iguales deben tener el mismo hashCode.'
  - id: 'sustentar-clases'
    kind: 'source'
    prompt: 'En Classes, encuentra dónde se puede validar dentro de un constructor y qué relación exige Dart entre == y hashCode.'
    required: true
    sourceLabel: 'Classes'
    hints:
      - 'Busca el cuerpo del constructor y las listas de inicializadores.'
      - 'Anota la regla sobre hashCode.'
  - id: 'defender-invariante'
    kind: 'judgment'
    prompt: 'Decide si la validación debe vivir en el constructor o en cada operación que use el valor, y nombra el costo de cada opción.'
    required: true
    hints:
      - 'Validar al construir hace imposible que exista un objeto inválido.'
      - 'Validar en cada uso permite construir primero y corregir después.'
docRefs:
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Constructors'
    url: 'https://dart.dev/language/constructors'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué diferencia hay entre validar una invariante al construir y comprobarla en cada consumidor?'
  - 'En un archivo vacío, vuelve a escribir la clase Porcentaje con su validación, sin mirar tu solución.'
  - 'Explica en voz alta qué relación exige Dart entre == y hashCode.'
  - 'Diseña un tipo Edad con su invariante y tres casos de frontera antes de escribir el cuerpo.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m07_clases.dart'
  testCommand: 'fvm dart test test/m07_clases_test.dart --name m07-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm07-1'
---

Una **invariante** es algo que siempre es verdad sobre un objeto, desde que se construye hasta que deja de existir. Un `Porcentaje` siempre está entre 0 y 100. Si eso es cierto, ningún consumidor tiene que comprobarlo nunca más.

## El costo de no tenerla

```dart
int porcentaje = leerDeFormulario();

// en el reporte
if (porcentaje >= 0 && porcentaje <= 100) { ... }
// en la gráfica
if (porcentaje >= 0 && porcentaje <= 100) { ... }
// en la exportación
// ...alguien se olvidó
```

La regla existe en la cabeza del equipo y en algunos `if`. El que falta es donde aparece el bug.

## La invariante vive en el constructor

```dart
class Porcentaje {
  Porcentaje(this.valor) {
    if (valor < 0 || valor > 100) {
      throw RangeError.range(valor, 0, 100, 'valor');
    }
  }

  final int valor;
}
```

A partir de aquí, **no puede existir** un `Porcentaje` inválido. Los tres consumidores del ejemplo anterior borran sus `if`. La regla se escribe una vez, en el único lugar por donde pasan todos.

`RangeError.range` no es capricho: nombra el valor recibido, el mínimo, el máximo y el campo. Un `throw Exception('valor malo')` obliga a abrir el código para saber qué pasó.

## `==` y `hashCode` van juntos

Dos porcentajes de 30 deberían ser iguales. Por defecto no lo son: Dart compara identidad.

```dart
@override
bool operator ==(Object other) => other is Porcentaje && other.valor == valor;

@override
int get hashCode => valor.hashCode;
```

La regla que exige el lenguaje: **si dos objetos son iguales, deben tener el mismo `hashCode`**. Implementar `==` sin `hashCode` produce un objeto que se comporta bien en un `expect` y mal dentro de un `Set` o como clave de un `Map` — que es exactamente lo que acabas de estudiar en D05.

## Intento · antes de mirar

Escribe la tabla de fronteras antes de tocar el archivo: `-1`, `0`, `100`, `101`. Después cuenta, en un proyecto imaginario con cinco consumidores, cuántos `if` desaparecen al mover la regla al constructor.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m07_clases_test.dart --name m07-1
```

Pega la salida del caso de los extremos. Prueba también a implementar `==` sin `hashCode` y observa que los tests de igualdad pasan igual: ese test extra existe porque el bug no aparece donde uno lo busca.

## Fuente · lee con una pregunta

Abre **Classes** con dos preguntas: ¿dónde se puede validar dentro de un constructor?, ¿qué relación exige Dart entre `==` y `hashCode`? Anota los dos encabezados.

## Criterio · decide y acepta el costo

Defiende validar al construir frente a validar en cada uso. Lo primero hace imposible el estado inválido y te obliga a tener el dato correcto **antes** de crear el objeto — lo cual es incómodo cuando estás llenando un formulario y todavía no terminaste.

Nombra ese costo y cómo lo resolverías: normalmente, con un tipo aparte para «lo que se está escribiendo» y una conversión al final. En la próxima lección la invariante tiene que sobrevivir a una operación.
