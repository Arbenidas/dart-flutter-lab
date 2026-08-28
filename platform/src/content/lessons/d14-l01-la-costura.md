---
id: 'D14-L01'
trackId: 'dart'
moduleId: 'D14'
kind: 'taller'
order: 0
slug: 'testing-y-calidad'
title: 'Sin costura no hay prueba barata'
summary: 'Separa el almacenamiento del resto detrás de un contrato, y comprueba que la lista que expone no se puede corromper.'
estimatedMinutes: 55
objectives:
  - 'Definir un contrato de repositorio y una implementación en memoria.'
  - 'Explicar qué es una costura y por qué abarata las pruebas.'
  - 'Fijar con una prueba que una colección expuesta no es modificable.'
prerequisites: ['D13-L03']
activities:
  - id: 'predecir-costura'
    kind: 'attempt'
    prompt: 'Sin abrir el archivo, escribe qué necesitarías para probar una regla de negocio sin tocar disco, y qué te lo impide si la clase abre el archivo por dentro.'
    required: true
    hints:
      - 'Una clase que construye su propia dependencia no se puede sustituir.'
      - 'Recuerda la inyección de D07.'
  - id: 'resolver-m15-1'
    kind: 'evidence'
    prompt: 'Implementa RepositorioEnMemoria con su orden, su reemplazo por id y su lista no modificable. Ejecuta sus pruebas y pega la salida del test de la lista.'
    required: true
    hints:
      - 'Un mapa por id resuelve el reemplazo sin buscar.'
      - 'listar ordena por id y devuelve una vista no modificable.'
  - id: 'sustentar-test'
    kind: 'source'
    prompt: 'En Testing, encuentra cómo se organiza un archivo de pruebas y qué hacen group y test.'
    required: true
    sourceLabel: 'Testing'
    hints:
      - 'Busca la estructura básica de un test en la página.'
      - 'Fíjate en cómo se ejecuta un archivo suelto.'
  - id: 'defender-en-memoria'
    kind: 'judgment'
    prompt: 'Decide si el repositorio en memoria es solo un doble de prueba o también una implementación legítima, y nombra qué pierdes al usarlo en producción.'
    required: true
    hints:
      - 'Un repositorio en memoria pierde todo al cerrar el proceso.'
      - 'Para un prototipo o una caché, puede ser exactamente lo que hace falta.'
docRefs:
  - label: 'Testing'
    url: 'https://dart.dev/tools/dart-test'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
  - label: 'Class modifiers'
    url: 'https://dart.dev/language/class-modifiers'
    kind: 'guide'
    version: 'Documentación vigente'
    lastVerified: '2026-08-23'
reviewPrompts:
  - '¿Qué es una costura y por qué abarata una prueba?'
  - 'En un archivo vacío, vuelve a escribir RepositorioEnMemoria sin mirar tu solución.'
  - 'Explica en voz alta por qué una lista expuesta debe ser no modificable.'
  - 'Toma una clase tuya que abra un archivo por dentro y define el contrato que la volvería probable.'
lab:
  workspace: 'dart_lab'
  targetPath: 'lib/m15_calidad.dart'
  testCommand: 'fvm dart test test/m15_calidad_test.dart --name m15-1'
  analyzeCommand: 'fvm dart analyze'
  exerciseId: 'm15-1'
---

Una **costura** es un punto donde puedes cambiar una pieza sin tocar el resto. Todo este módulo es sobre ponerlas donde hacen falta.

## Sin costura

```dart
class ServicioTareas {
  final File _archivo = File('tareas.json'); // construye su dependencia
}
```

Para probar una regla de negocio de esta clase necesitas un archivo, un directorio temporal, limpieza después de cada prueba y aceptar que la suite toque disco. Y todo eso para comprobar que un título vacío se rechaza.

## Con costura

```dart
abstract interface class RepositorioTareas {
  List<Tarea> listar();
  void guardar(Tarea tarea);
  void eliminar(String id);
}
```

Tres métodos. A partir de aquí, «dónde viven las tareas» es una decisión de quien construye el servicio — la inyección de D07-L02 aplicada a datos.

## La implementación en memoria

```dart
class RepositorioEnMemoria implements RepositorioTareas {
  final Map<String, Tarea> _tareas = <String, Tarea>{};

  @override
  List<Tarea> listar() => List<Tarea>.unmodifiable(
        _tareas.values.toList()..sort((a, b) => a.id.compareTo(b.id)),
      );

  @override
  void guardar(Tarea tarea) => _tareas[tarea.id] = tarea;

  @override
  void eliminar(String id) {
    if (_tareas.remove(id) == null) {
      throw StateError('No existe la tarea $id');
    }
  }
}
```

Tres decisiones de contrato en muy pocas líneas:

- **Un mapa por id.** `guardar` con un id existente reemplaza, sin buscar.
- **Orden estable.** `listar` ordena por id. Sin eso, el orden dependería de la implementación del mapa y las pruebas serían frágiles.
- **Lista no modificable.** D06-L05, ahora fijado por una prueba.

## `eliminar` lanza

Borrar algo que no existe es, casi siempre, un bug de quien llama. Lanzar lo convierte en un fallo temprano. La alternativa —no hacer nada— vuelve la operación idempotente, que es cómodo con reintentos y esconde el error para siempre.

## Intento · antes de mirar

Escribe qué necesitarías para probar «un título vacío se rechaza» en las dos versiones: con el archivo dentro y con el contrato.

## Evidencia · ejecuta y compara

```bash
cd dart_lab
fvm dart test test/m15_calidad_test.dart --name m15-1
```

Pega la salida del test de la lista no modificable.

## Fuente · lee con una pregunta

Abre **Testing** con una pregunta concreta: ¿cómo se organiza un archivo de pruebas y qué hacen `group` y `test`? Anota el encabezado.

## Criterio · decide y acepta el costo

Defiende si `RepositorioEnMemoria` es solo un doble o también una implementación legítima. Pierde todo al cerrar el proceso, y para un prototipo o una caché puede ser exactamente lo que hace falta.

Nombra tu postura. En la próxima lección las reglas se separan de los datos.
