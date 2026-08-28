---
id: 'D07-L05'
trackId: 'dart'
moduleId: 'D07'
kind: 'taller'
order: 4
slug: 'mixins-y-sus-limites'
title: 'Mezclar comportamiento sin heredar'
summary: 'Agrega una capacidad transversal con un mixin y descubre qué no puede hacer un mixin que una clase sí.'
estimatedMinutes: 50
objectives:
  - 'Declarar un mixin con estado y usarlo con with.'
  - 'Explicar por qué un mixin no puede declarar constructores.'
  - 'Elegir entre mixin, composición y herencia según el caso.'
prerequisites: ['D07-L04']
activities:
  - id: 'predecir-mixin'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, predice si dos instancias de una clase que usa un mixin con una lista comparten esa lista, y por qué.'
    required: true
    hints:
      - 'Un mixin aporta miembros a la clase, no una instancia compartida.'
      - 'Cada objeto tiene sus propios campos, vengan de donde vengan.'
  - id: 'resolver-m08-5'
    kind: 'evidence'
    prompt: 'Implementa el mixin Registrable con su vista de solo lectura. Ejecuta sus pruebas y pega la salida del test que comprueba que cada instancia tiene su propio registro.'
    required: true
    hints:
      - 'El mixin puede declarar campos, pero no un constructor.'
      - 'Reutiliza la técnica de encapsulación de D06-L05 para la lista.'
  - id: 'sustentar-mixins'
    kind: 'source'
    prompt: 'En Mixins, encuentra qué puede y qué no puede declarar un mixin, y qué significa la cláusula on.'
    required: true
    sourceLabel: 'Mixins'
    hints:
      - 'Busca la limitación sobre constructores.'
      - 'Anota qué añade on al mixin.'
  - id: 'defender-mixin'
    kind: 'judgment'
    prompt: 'Decide entre un mixin Registrable y un campo con un objeto Registro inyectado, y nombra qué gana y qué pierde cada opción.'
    required: true
    hints:
      - 'El mixin no se puede sustituir en una prueba: viene soldado a la clase.'
      - 'La composición cuesta un parámetro más y se puede reemplazar.'
docRefs:
  - label: 'Mixins'
    url: 'https://dart.dev/language/mixins'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Cuándo aporta un mixin y qué limitación tiene respecto de construcción y estado?'
  - 'En un archivo vacío, vuelve a escribir el mixin Registrable y una clase que lo use, sin mirar.'
  - 'Explica en voz alta por qué dos instancias no comparten el estado que aporta un mixin.'
  - 'Diseña un EnviadorMensaje con implementaciones de correo y consola, y explica cómo probarías una entrega sin enviar nada real.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m08_contratos.dart'
  testCommand: 'fvm dart test test/m08_contratos_test.dart --name m08-5'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm08-5'
  revealReference: true
---

Ya viste dos formas de reutilizar comportamiento: heredar y componer. Falta una tercera, y tiene un lugar bastante estrecho.

## Un mixin aporta miembros

```dart
mixin Registrable {
  // ignore: unused_field
  final List<String> _registro = <String>[];

  List<String> get registro => List<String>.unmodifiable(_registro);

  void registrar(String evento) => _registro.add(evento);
}

class ContadorRegistrado with Registrable {
  int _valor = 0;

  void incrementar() {
    _valor++;
    registrar('incrementar -> $_valor');
  }
}
```

`with` inyecta los miembros del mixin en la clase. `ContadorRegistrado` no _es_ un `Registrable` en el sentido de la herencia ni _tiene_ uno como campo: sus miembros pasan a ser suyos.

Fíjate en que el getter reutiliza exactamente la técnica de D06-L05: lista privada, vista no modificable.

## Cada instancia, su estado

Un mixin puede declarar campos, y esos campos son **de cada objeto**:

```dart
final uno = ContadorRegistrado()..incrementar();
final otro = ContadorRegistrado();
// uno.registro tiene 1 elemento; otro.registro está vacío
```

No hay ningún estado compartido. El mixin describe qué campos tendrá la clase, no una instancia que todas usen.

## Lo que un mixin no puede

**No puede declarar constructores.** Sus campos se inicializan en la declaración o quedan sin inicializar. Eso limita bastante: no puedes exigirle nada a quien lo use ni recibir configuración.

También conviene conocer la cláusula `on`, que restringe a qué clases se puede aplicar el mixin y le permite usar los miembros de esa clase.

## Cuándo usar cuál

| Necesidad                                         | Herramienta |
| ------------------------------------------------- | ----------- |
| es un tipo de X                                   | herencia    |
| usa un X que puede cambiar                        | composición |
| gana una capacidad transversal, sin configuración | mixin       |

El caso legítimo del mixin es el tercero: algo que muchas clases sin relación entre sí necesitan, y que no requiere parámetros.

## Intento · antes de mirar

Predice, por escrito:

- si dos instancias comparten el registro
- qué pasa si intentas darle un constructor al mixin
- si puedes sustituir el mixin por otra cosa en una prueba

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m08_contratos_test.dart --name m08-5
```

Pega la salida del test que comprueba que cada instancia tiene su propio registro. Experimento: intenta agregarle un constructor al mixin y lee el error del analizador entero.

## Fuente · lee con una pregunta

Abre **Mixins** con dos preguntas: ¿qué no puede declarar un mixin?, ¿qué añade la cláusula `on`? Anota los dos encabezados.

## Criterio · decide y acepta el costo

Defiende el mixin frente a un campo `final Registro _registro` inyectado por constructor.

El punto que suele decidirlo: el mixin viene **soldado** a la clase. No lo puedes sustituir en una prueba ni cambiarlo en tiempo de ejecución. Después de todo un módulo sobre por qué la sustituibilidad importa, eso pesa.

A cambio, la composición cuesta un parámetro más en cada construcción. Elige y nombra el costo. Cierra el módulo:

```bash
fvm dart analyze
```

En D08 el foco pasa del _quién depende de quién_ al **modelado**: hacer que los estados imposibles no se puedan escribir.
