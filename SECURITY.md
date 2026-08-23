# Política de seguridad

## Versiones compatibles

Este proyecto está en desarrollo activo. Solo la rama `main` recibe correcciones de seguridad.

## Reportar una vulnerabilidad

No abras un issue público ni un pull request con una vulnerabilidad explotable, credenciales, tokens o datos personales.

1. Abre la pestaña **Security** del repositorio.
2. Selecciona **Report a vulnerability** para crear un aviso privado.
3. Incluye el componente afectado, impacto, pasos mínimos para reproducir, versión o commit y una mitigación si la conoces.

Se confirmará la recepción cuando un mantenedor pueda revisar el reporte. Después se acordarán alcance, corrección y divulgación. No se garantiza una recompensa económica.

## Alcance

Son especialmente relevantes:

- importación/exportación de progreso y notas;
- XSS o ejecución de contenido importado;
- dependencias, build y cadena de suministro;
- archivos incluidos por error en el ZIP público;
- configuración de Netlify, Firebase, CSP y encabezados;
- exposición de soluciones privadas, secretos o datos locales.

Los errores pedagógicos, enlaces rotos y fallos visuales deben usar los formularios públicos de issues.
