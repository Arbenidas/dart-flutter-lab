import 'package:dart_lab/m02_tipos.dart';
import 'package:dart_lab/m03_null_safety.dart';
import 'package:dart_lab/m04_control.dart';
import 'package:dart_lab/m05_funciones.dart';
import 'package:test/test.dart';

// Estas asignaciones fallan al compilar si cambia una firma publica del lab.
final String Function(Object) _describirTipo = describirTipo;
final double Function(double) _aCelsius = aCelsius;
final String Function(int) _formatearPrecio = formatearPrecio;
final List<String> _diasHabiles = diasHabiles;
final List<String> Function() _semanaCompleta = semanaCompleta;
final String Function(String?) _saludar = saludar;
final int Function(String?) _longitudSegura = longitudSegura;
final String? Function(List<String>) _primerNoVacio = primerNoVacio;
final int? Function(String) _parsearEdad = parsearEdad;
final SesionDeEstudio _sesion = SesionDeEstudio();
final void Function(DateTime) _comenzarSesion = _sesion.comenzar;
final int Function(DateTime) _minutosHasta = _sesion.minutosHasta;
final String Function(int) _clasificarEdad = clasificarEdad;
final String Function(String) _tipoDeDia = tipoDeDia;
final String Function((int, int)) _describirPunto = describirPunto;
final int Function(String) _contarVocales = contarVocales;
final List<int> Function(int) _fibonacci = fibonacci;
final int Function(int, int Function(int)) _aplicar = aplicar;
final String Function(String, {bool mayusculas, String prefijo}) _etiqueta =
    etiqueta;
final int Function() Function() _crearContador = crearContador;
final int Function(int) Function(int) _multiplicadorPor = multiplicadorPor;
final List<int> Function(List<int>, int Function(int)) _transformarTodos =
    transformarTodos;
final int Function(void Function()) _medirMilisegundos = medirMilisegundos;

void main() {
  test('las firmas publicas del laboratorio permanecen estables', () {
    expect(<Object>[
      _describirTipo,
      _aCelsius,
      _formatearPrecio,
      _diasHabiles,
      _semanaCompleta,
      _saludar,
      _longitudSegura,
      _primerNoVacio,
      _parsearEdad,
      _comenzarSesion,
      _minutosHasta,
      _clasificarEdad,
      _tipoDeDia,
      _describirPunto,
      _contarVocales,
      _fibonacci,
      _aplicar,
      _etiqueta,
      _crearContador,
      _multiplicadorPor,
      _transformarTodos,
      _medirMilisegundos,
    ], hasLength(22));
  });
}
