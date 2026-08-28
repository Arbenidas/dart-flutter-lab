---
id: 'D04-L03'
trackId: 'dart'
moduleId: 'D04'
kind: 'taller'
order: 2
slug: 'closures-con-estado'
title: 'Una función que se acuerda'
summary: 'Construye un contador con closure y comprueba que cada instancia tiene su propio estado.'
estimatedMinutes: 55
objectives:
  - 'Explicar qué captura una closure y cuánto vive lo capturado.'
  - 'Devolver una función desde otra función.'
  - 'Comprobar que dos closures creadas por separado no comparten estado.'
prerequisites: ['D04-L02']
activities:
  - id: 'predecir-contador'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice la salida de crear dos contadores y llamar al primero dos veces y al segundo una vez.'
    required: true
    hints:
      - 'La variable local vive dentro de la función externa: ¿qué pasa cuando esa función termina?'
      - 'Cada llamada a crearContador ejecuta el cuerpo otra vez.'
  - id: 'resolver-m05-3'
    kind: 'evidence'
    prompt: 'Implementa crearContador, ejecuta sus pruebas y pega la salida del test que comprueba que dos contadores son independientes.'
    required: true
    hints:
      - 'Declara la variable en la función externa y devuélve una función que la use.'
      - 'La función devuelta no recibe parámetros y devuelve int.'
  - id: 'sustentar-closures'
    kind: 'source'
    prompt: 'En Functions, localiza la sección de closures y encuentra qué dice sobre el ámbito léxico que la función se lleva consigo.'
    required: true
    sourceLabel: 'Functions'
    hints:
      - 'Busca la palabra closure dentro de la página.'
      - 'Fíjate si menciona lexical scope.'
  - id: 'defender-closure-vs-clase'
    kind: 'judgment'
    prompt: 'Compara este contador con una clase que tenga un campo y un método incrementar. Elige una para un proyecto real y nombra el costo.'
    required: true
    hints:
      - 'La closure no permite inspeccionar ni reiniciar el estado desde afuera.'
      - 'La clase cuesta más código y ofrece un nombre para cada operación.'
docRefs:
  - label: 'Functions'
    url: 'https://dart.dev/language/functions'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Variables'
    url: 'https://dart.dev/language/variables'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué conserva una closure después de que termina la función exterior?'
  - 'En un archivo vacío, vuelve a escribir crearContador sin mirar tu solución.'
  - 'Explica en voz alta por qué dos contadores creados por separado no comparten estado.'
  - 'Escribe una closure que acumule textos y devuelva el total concatenado; decide qué expone y qué esconde.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m05_funciones.dart'
  testCommand: 'fvm dart test test/m05_funciones_test.dart --name m05-3'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm05-3'
---

Hasta ahora una función recibía todo lo que necesitaba. Una **closure** rompe esa regla: se lleva consigo variables del lugar donde fue creada, y esas variables sobreviven a la función que las declaró.

## Qué ocurre exactamente

```dart
int Function() crearContador() {
  var cuenta = 0;              // variable local de crearContador
  return () {
    cuenta++;                  // la función interna la usa
    return cuenta;
  };
}
```

Normalmente `cuenta` moriría cuando `crearContador` termina. No muere: la función devuelta **captura** esa variable y la mantiene viva mientras alguien conserve la función.

```dart
final contar = crearContador();
contar(); // 1
contar(); // 2

final otro = crearContador();
otro();   // 1  <- estado propio, no compartido
```

Cada llamada a `crearContador` ejecuta el cuerpo de nuevo y crea **su propia** `cuenta`. Ese aislamiento es la propiedad que hace útiles a las closures.

## Detalle que confunde

La función devuelta puede declararse `final` y aun así su estado interno cambia. No es una contradicción: `final` protege la **referencia** a la función, no las variables que la función capturó. Es la misma distinción que trabajaste en D01-L04 con `final` y una lista.

## Intento · antes de mirar

Predice la salida completa de esta secuencia, línea por línea:

```dart
final a = crearContador();
final b = crearContador();
print(a()); print(a()); print(b()); print(a());
```

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m05_funciones_test.dart --name m05-3
```

Pega la salida del test que comprueba que dos contadores son independientes. Si tu implementación declaró la variable **fuera** de `crearContador`, ese es el test que lo delata.

## Fuente · lee con una pregunta

Abre **Functions** y busca la sección sobre closures. Pregunta concreta: ¿qué se lleva consigo la función y de dónde? Anota el encabezado y la expresión que usa la documentación para el ámbito.

## Criterio · decide y acepta el costo

Compara la closure con esta alternativa:

```dart
class Contador {
  int _cuenta = 0;
  int incrementar() => ++_cuenta;
}
```

La clase da un nombre a la operación, permite agregar `reiniciar` o `valorActual`, y se lee sin saber qué es una closure. La closure es cuatro líneas y esconde el estado por completo — lo cual es una virtud hasta que necesitas inspeccionarlo.

Elige una y nombra qué aceptas perder. En la próxima lección la closure deja de guardar un contador y empieza a guardar una **configuración**.
