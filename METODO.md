# Método de estudio

Dijiste algo importante: *"he usado mucha IA y eso ha quemado todo mi
conocimiento"*. Vale la pena mirarlo de frente, porque cambia cómo
tenemos que armar esto.

## Qué te pasó (y no es culpa tuya)

Cuando un modelo te escribe el código, vos hacés dos cosas: leerlo y
aprobarlo. Las dos son **reconocimiento**. Lo que nunca hacés es
**recuperación**: sacar la respuesta de tu cabeza cuando no está delante
tuyo. La memoria se construye recuperando, no reconociendo. Por eso
sentís que "entendés todo" mientras leés y no podés escribir treinta
líneas en blanco. No perdiste inteligencia; perdiste rutas de acceso.

Se recuperan. Rápido, además, porque el reconocimiento que tenés es
andamio. Pero solo se recuperan escribiendo código que no funciona
todavía y haciéndolo funcionar.

## El ciclo de evidencia

Cada ejercicio se recorre en cuatro movimientos. No son cuatro casillas
que rellenar: cada uno **produce un artefacto de tipo distinto**, y están
ordenados de la prueba más débil a la más fuerte. Si dos movimientos te
piden lo mismo, uno de los dos está mal escrito.

| Movimiento    | La pregunta                         | Lo que dejás por escrito                | Quién lo verifica    |
| ------------- | ----------------------------------- | --------------------------------------- | -------------------- |
| **Intento**   | ¿Qué escribís sin mirar nada?       | tu código o tu predicción, aunque falle  | vos                  |
| **Evidencia** | ¿Qué respondió la máquina?          | la salida, el error o el test, exactos   | la máquina           |
| **Fuente**    | ¿Qué dice la documentación oficial? | un encabezado citado y su regla          | el enlace oficial    |
| **Criterio**  | ¿Qué decidís y qué costo aceptás?   | dos opciones comparadas, una descartada  | vos, y el repaso     |

El orden importa. Empezar por la documentación se siente mejor y enseña
menos: sin un intento previo no hay hueco donde entre lo que leés.

## La escalera de repaso

Reaplicar algo el mismo día que lo aprendiste todavía es reconocimiento:
el ejemplo sigue caliente. Por eso el ciclo no se cierra en la sesión,
sino días después, y cada etapa pide algo más difícil que la anterior.

| Cuándo   | Qué te pide                                                    |
| -------- | -------------------------------------------------------------- |
| Día 1    | **Recordar** — respondé la pregunta central sin abrir nada.     |
| Día 3    | **Reescribir** — volvé a escribir el ejercicio en un archivo vacío. |
| Día 7    | **Explicar** — contáselo en voz alta a alguien, sin apuntes.    |
| Día 21   | **Transferir** — aplicá la idea a un problema que no viste.     |

La plataforma programa estas cuatro fechas sola cuando confirmás una
lección, y las junta en `/repasos/`. Es la parte que más rinde y la que
todos saltean.

## Las cinco reglas de la mesa

El ciclo gobierna el ejercicio; estas reglas gobiernan la sesión entera.

**1. Página en blanco antes que documentación.**
Cada ejercicio empieza intentando escribirlo de memoria, aunque salga
mal. El intento fallido es lo que abre el hueco donde después entra la
información.

**2. Veinte minutos de pelea antes de buscar.**
Cuando te trabás, poné un temporizador. Hasta que suene: releés el
error, leés tu código en voz alta, probás algo. Cuando suene, vas a la
**documentación oficial** — no a un modelo, no a un blog, no a Stack
Overflow. La doc de Dart y Flutter es excelente y aprender a leerla es
la mitad de esta carrera.

**3. Explicalo en voz alta.**
Antes de dar un ejercicio por cerrado, explicá tu solución en voz alta
como si le hablaras a alguien. Si te trabás explicando, no lo entendiste:
lo hiciste funcionar. Son cosas distintas.

**4. Reescribí lo que ya funciona.**
Varios ejercicios te piden resolver algo dos veces, de dos formas. No es
relleno. La segunda versión es donde aparece el criterio: cuál se lee
mejor, cuál es más rápida, cuál rompe con datos raros.

**5. La IA entra después, nunca antes.**
Una vez que el test pasa y lo explicaste en voz alta, ahí sí:
"aquí está mi solución, ¿qué le criticarías?", "¿qué caso borde no
consideré?", "¿cómo lo escribiría alguien del equipo de Flutter?".
Eso es tutoría. Pedirle el código antes es volver a lo de siempre.

## Ritmo sugerido

Una hora al día es mejor que siete horas el domingo. La memoria se
consolida entre sesiones, no dentro de una sesión.

- **20 min** — la escalera de repaso vencida, de memoria y sin mirar.
- **30 min** — una lección nueva, con el ciclo de evidencia completo.
- **10 min** — cuaderno: escribí con tus palabras qué aprendiste y qué
  no te cerró. En papel o en un `.md`, da igual, pero escrito.

Una lección está pensada para caber en esos 30 minutos más algo de
desborde: si te lleva más de hora y media, está mal partida y es un
problema del curso, no tuyo.

## Cómo saber si estás avanzando de verdad

No por módulos completados. Por estas tres señales:

1. Podés escribir un `StatelessWidget` completo en un archivo vacío sin
   consultar nada.
2. Cuando leés un mensaje de error, sabés en qué archivo mirar antes de
   abrirlo.
3. Cuando ves código ajeno, notás lo que está mal.

La tercera es la que llega última y la que importa.
