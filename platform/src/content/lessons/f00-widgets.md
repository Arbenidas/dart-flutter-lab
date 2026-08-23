---
id: 'F00-L01'
trackId: 'flutter'
moduleId: 'F00'
order: 0
slug: 'widgets-como-descripciones'
title: 'Un widget describe; Flutter hace el resto'
summary: 'Construye tu primer StatelessWidget entendiendo inmutabilidad, composición y el papel de build.'
estimatedMinutes: 95
objectives:
  - 'Explicar por qué un Widget es una descripción inmutable de interfaz.'
  - 'Crear un StatelessWidget configurable con constructor const.'
  - 'Separar composición visual de datos que cambian durante la ejecución.'
prerequisites: ['D04-L01']
activities:
  - id: 'predecir-arbol'
    kind: 'predict'
    prompt: 'Dibuja el árbol que produciría MaterialApp > Scaffold > Center > Text y predice qué nodo contiene a cuál.'
    required: true
    hints:
      - 'Empieza por el widget exterior y sigue cada propiedad child.'
      - 'Un árbol describe relaciones, no coordenadas.'
  - id: 'crear-widget'
    kind: 'code'
    prompt: 'Crea un StatelessWidget PracticeSummary con título, mensaje y minutos; úsalo dos veces con datos distintos.'
    required: true
    hints:
      - 'Declara los campos final y recíbelos en un constructor const.'
      - 'El método build debe componer widgets, no modificar los campos.'
  - id: 'diagnosticar-mutacion'
    kind: 'debug'
    prompt: 'Explica por qué incrementar directamente un campo final del widget no representa estado y qué objeto debería conservar un dato mutable local.'
    required: true
    hints:
      - 'Widget y State tienen ciclos de vida distintos.'
      - 'Pregunta quién debe notificar que el valor cambió.'
  - id: 'leer-widget-api'
    kind: 'docs'
    prompt: 'En la referencia de Widget, encuentra qué describe un widget y qué relación tiene con Element; parafrasea ambas ideas.'
    required: true
    hints:
      - 'Lee primero el resumen de la clase, no la lista completa de métodos.'
      - 'Busca las palabras immutable description e inflated.'
  - id: 'explicar-build'
    kind: 'explain'
    prompt: 'Explica qué recibe build, qué devuelve y por qué debe poder ejecutarse muchas veces.'
    required: true
    hints:
      - 'BuildContext representa una ubicación en el árbol.'
      - 'No asumas que build se llama una sola vez.'
  - id: 'transferir-composicion'
    kind: 'transfer'
    prompt: 'Descompón una tarjeta de perfil en widgets pequeños e identifica qué datos serían parámetros y cuáles podrían ser estado local.'
    required: true
    hints:
      - 'Avatar, nombre y biografía pueden llegar desde el padre.'
      - 'Un control expandido/colapsado sí puede cambiar durante la vida de la vista.'
docRefs:
  - label: 'Create widgets'
    url: 'https://docs.flutter.dev/learn/pathway/tutorial/widget-fundamentals'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Widget class'
    url: 'https://api.flutter.dev/flutter/widgets/Widget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
  - label: 'StatelessWidget class'
    url: 'https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html'
    kind: 'api'
    version: 'API estable'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué significa afirmar que un Widget es una descripción inmutable?'
  - '¿Qué recibe y qué devuelve el método build?'
  - '¿Por qué conviene declarar const un widget cuando sus argumentos lo permiten?'
  - '¿Qué diferencia conceptual existe entre Widget y State?'
lab:
  workspace: 'flutter_lab'
  targetPath: 'lib/main.dart'
  testCommand: 'fvm flutter test'
  analyzeCommand: 'fvm flutter analyze'
  exerciseId: 'f00_widgets'
---

Flutter no te pide dibujar píxeles de forma imperativa. Te pide describir qué interfaz corresponde al estado actual. Cuando los datos cambian, el framework vuelve a construir las partes necesarias y reconcilia la nueva descripción con lo que ya existe.

## Tres piezas que no son lo mismo

- **Widget:** configuración inmutable. Dice qué quieres mostrar.
- **Element:** instancia montada que conecta una configuración con una ubicación del árbol.
- **RenderObject:** participa en layout, pintura y hit testing cuando ese nivel es necesario.

Al comenzar, trabajarás casi siempre con widgets. La distinción importa porque evita la idea equivocada de que un objeto widget «vive en pantalla» y cambia sus propios campos.

## Un StatelessWidget configurable

```dart
import 'package:flutter/material.dart';

class Greeting extends StatelessWidget {
  const Greeting({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Hola, $name'),
    );
  }
}
```

Los campos son `final`, el constructor es `const` y `build` devuelve otra descripción. El widget no descarga datos, no escribe archivos y no incrementa contadores. Sus entradas bastan para construir la vista.

`BuildContext` representa la ubicación de este widget en el árbol. Permite consultar dependencias disponibles por encima, como el tema. No es un almacén global ni un objeto que debas guardar indefinidamente.

## Preparar el laboratorio local

Si `flutter_lab/` todavía no existe, créalo una sola vez desde la raíz del repositorio:

```bash
fvm flutter create flutter_lab
cd flutter_lab
fvm flutter run -d chrome
```

Después trabaja siempre dentro de esa carpeta y verifica con:

```bash
fvm flutter test
fvm flutter analyze
```

La plataforma no ejecuta estos comandos. Registra la evidencia solo después de ver el resultado local.

## P — Predice

Dibuja el árbol `MaterialApp → Scaffold → Center → Text`. Después agrega un `Padding` entre `Center` y `Text` y predice qué relación cambia. No pienses todavía en coordenadas: piensa en composición y responsabilidades.

## E — Escribe

Crea `PracticeSummary`, un StatelessWidget con `title`, `message` y `minutes`. Instáncialo dos veces con valores distintos. Si copias toda la composición en ambos lugares, todavía no construiste una abstracción reusable.

Mantén `main.dart` pequeño: extrae la clase a su propio archivo si la pantalla deja de leerse de una sola mirada.

## N — Nombra el fallo

Si intentas hacer `minutes++` dentro del widget, el analizador señalará que el campo final no puede asignarse. El problema no es que falte una palabra mágica; el modelo está mezclando configuración inmutable con estado que cambia.

Pregunta:

1. ¿El valor llega desde el padre?
2. ¿Cambia durante la vida de esta parte de la UI?
3. ¿Qué parte mínima necesita reconstruirse cuando cambia?

Estas preguntas preparan la decisión entre `StatelessWidget`, `StatefulWidget` y estado compartido.

## S — Sustenta

Abre la referencia de `Widget` y lee el resumen antes de mirar propiedades. Localiza las ideas de descripción inmutable e inflación a un `Element`. Luego abre `StatelessWidget` y encuentra cuándo puede volver a llamarse `build`.

La API reference no se lee de principio a fin. Empieza por resumen, constructores, métodos que usarás y sección **See also** para navegar al concepto vecino.

## A — Argumenta

Explica por qué `build` puede ejecutarse muchas veces. Una respuesta completa menciona que devuelve descripciones, que los widgets son baratos y que efectos externos dentro de `build` podrían repetirse sin control.

## R — Reaplica

Descompón una tarjeta de perfil. Decide qué parte sería `ProfileCard`, qué widgets pequeños extraerías y qué datos llegarían por constructor. Añade después un control «mostrar biografía»: identifica el estado mínimo que cambia y evita convertir toda la pantalla en un único StatefulWidget.

Finaliza con `fvm flutter analyze`. La meta no es acumular widgets, sino construir un árbol donde cada clase tenga una razón clara para cambiar.
