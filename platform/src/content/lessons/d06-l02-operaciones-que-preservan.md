---
id: 'D06-L02'
trackId: 'dart'
moduleId: 'D06'
kind: 'taller'
order: 1
slug: 'operaciones-que-preservan-la-invariante'
title: 'Una operación no puede romper lo que la clase promete'
summary: 'Devuelve objetos nuevos en vez de mutar, y deja que la invariante rechace un resultado imposible.'
estimatedMinutes: 45
objectives:
  - 'Escribir una operación que devuelve una instancia nueva sin mutar los operandos.'
  - 'Reutilizar la validación del constructor en lugar de duplicarla.'
  - 'Explicar por qué un objeto inmutable es más fácil de razonar.'
prerequisites: ['D06-L01']
activities:
  - id: 'predecir-suma'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice qué debería ocurrir al sumar un Porcentaje de 80 con uno de 30, y decide si tu operación mutaría alguno de los dos.'
    required: true
    hints:
      - 'La suma produce 110, que está fuera de la invariante.'
      - 'Si sumar cambia el operando de la izquierda, quien lo tenga guardado se lleva una sorpresa.'
  - id: 'resolver-m07-2'
    kind: 'evidence'
    prompt: 'Implementa sumar y ejecuta sus pruebas. Pega la salida del test que comprueba que los operandos no cambiaron.'
    required: true
    hints:
      - 'No escribas una validación nueva: deja que la haga el constructor.'
      - 'Devuelve un Porcentaje nuevo, no this.'
  - id: 'sustentar-constructores'
    kind: 'source'
    prompt: 'En Constructors, encuentra qué ocurre con los campos final y por qué no se pueden reasignar después de construir.'
    required: true
    sourceLabel: 'Constructors'
    hints:
      - 'Busca la sección sobre campos final e inicialización.'
      - 'Conecta lo que leas con lo que viste en D01 sobre final.'
  - id: 'defender-inmutable'
    kind: 'judgment'
    prompt: 'Decide si Porcentaje debería ser inmutable o permitir cambiar su valor, y nombra qué se vuelve difícil con la opción que descartas.'
    required: true
    hints:
      - 'Un objeto inmutable se puede compartir sin miedo entre partes del programa.'
      - 'Uno mutable ahorra construir instancias nuevas y obliga a rastrear quién lo cambió.'
docRefs:
  - label: 'Constructors'
    url: 'https://dart.dev/language/constructors'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Classes'
    url: 'https://dart.dev/language/classes'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Por qué una operación sobre un valor inmutable devuelve una instancia nueva?'
  - 'En un archivo vacío, vuelve a escribir Porcentaje.sumar sin mirar tu solución.'
  - 'Explica en voz alta cómo la operación reutiliza la validación del constructor.'
  - 'Escribe una operación restar y decide qué hace cuando el resultado quedaría por debajo de cero.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m07_clases.dart'
  testCommand: 'fvm dart test test/m07_clases_test.dart --name m07-2'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm07-2'
---

Tener la invariante en el constructor no alcanza si una operación puede dejar el objeto en un estado imposible. La forma de evitarlo es más simple de lo que parece.

## Producir, no mutar

```dart
Porcentaje sumar(Porcentaje otro) => Porcentaje(valor + otro.valor);
```

Una línea, y en ella hay dos decisiones:

1. **Devuelve una instancia nueva.** Ni `this` ni `otro` cambian. Quien tuviera guardado cualquiera de los dos sigue teniendo lo mismo que antes.
2. **No repite la validación.** El constructor ya sabe rechazar un valor fuera de rango. Escribir aquí otro `if` sería duplicar la regla en dos sitios que pueden desincronizarse.

`Porcentaje(80).sumar(Porcentaje(30))` lanza, y lanza desde el constructor. La operación no tuvo que saber nada sobre el rango.

## Por qué esto se lee mejor

Con objetos inmutables, esta línea siempre es verdad:

```dart
final a = Porcentaje(30);
hacerCosas(a);
// aquí a.valor sigue siendo 30, sin importar qué haga hacerCosas
```

Con un objeto mutable no puedes afirmar eso sin leer `hacerCosas` entera, y las que ella llame. Ese es el costo real de la mutabilidad: no es rendimiento, es **cuánto código tienes que leer para saber qué vale algo**.

Es la misma distinción de D01-L04 entre `final` y `const`, y de D05-L01 entre devolver una lista fija o ampliable. El patrón se repite: cada vez que entregas algo que otro puede cambiar, entregas también la obligación de vigilarlo.

## Intento · antes de mirar

Predice el resultado de estas tres líneas, indicando si alguna muta algo:

```dart
final a = Porcentaje(30);
final b = a.sumar(Porcentaje(20));
final c = Porcentaje(80).sumar(Porcentaje(30));
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m07_clases_test.dart --name m07-2
```

Pega la salida del test que comprueba que los operandos no cambiaron. Ese test existe porque una implementación que mute `this` pasa los otros dos y rompe todo lo demás en silencio.

## Fuente · lee con una pregunta

Abre **Constructors** con una pregunta concreta: ¿por qué un campo `final` no se puede reasignar después de construir? Anota el encabezado y conéctalo con lo que ya sabes de D01.

## Criterio · decide y acepta el costo

Defiende la inmutabilidad de `Porcentaje`. A favor: se comparte sin vigilancia y las operaciones son fáciles de razonar. En contra: cada operación construye un objeto nuevo, y en un ciclo apretado eso se nota.

Nombra a partir de qué escala te importaría, y fíjate en que hoy no tienes forma de medirlo — eso llega en D14. En la próxima lección aparece un constructor que puede hacer algo que este no: **elegir**.
