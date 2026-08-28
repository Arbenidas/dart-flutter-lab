import 'package:dart_lab/m02_tipos.dart';
import 'package:dart_lab/m03_null_safety.dart';
import 'package:dart_lab/m04_control.dart';
import 'package:dart_lab/m05_funciones.dart';
import 'package:dart_lab/m06_colecciones.dart';
import 'package:dart_lab/m07_clases.dart';
import 'package:dart_lab/m08_contratos.dart';
import 'package:dart_lab/m09_modelado.dart';
import 'package:dart_lab/m10_errores.dart' as m10;
import 'package:dart_lab/m11_asincronia.dart';
import 'package:dart_lab/m12_isolates.dart';
import 'package:dart_lab/m13_io_json_cli.dart';
import 'package:dart_lab/m14_paquetes.dart';
import 'package:dart_lab/m15_calidad.dart';
import 'package:dart_lab/m16_bitacora.dart';
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
final List<int> Function(List<Pedido>) _totalesPagados = totalesPagados;
final Set<String> Function(Iterable<String>) _etiquetasUnicas = etiquetasUnicas;
final Map<int, String> Function(Iterable<String>, int Function(String))
_indexarPor = indexarPor<String, int>;
final Map<int, int> Function(Iterable<String>, int Function(String))
_contarPorClave = contarPorClave<String, int>;
final String? Function(Iterable<String>, bool Function(String))
_primeroQueCumple = primeroQueCumple<String>;
final Porcentaje Function(int) _porcentaje = Porcentaje.new;
final Porcentaje Function(double) _porcentajeDesdeFraccion =
    Porcentaje.desdeFraccion;
final RangoFecha Function({required DateTime inicio, required DateTime fin})
_rangoFecha = RangoFecha.new;
final Bitacora Function() _bitacora = Bitacora.new;
final Reloj Function(DateTime) _relojFijo = RelojFijo.new;
final ServicioVencimiento Function(Reloj) _servicioVencimiento =
    ServicioVencimiento.new;
final EnviadorMensaje Function() _enviadorEnMemoria = EnviadorEnMemoria.new;
final ContadorRegistrado Function() _contadorRegistrado =
    ContadorRegistrado.new;
final List<EstadoDescarga> _estadosDescarga = EstadoDescarga.values;
final String Function(Resultado<int>) _describir = describir<int>;
final Resultado<String> Function(String) _validarUsuario = validarUsuario;
final String? Function(Iterable<String>) _primeroONull = primeroONull<String>;
final ({List<int> cumplen, List<int> resto}) Function(
  Iterable<int>,
  bool Function(int),
)
_separar = separar<int>;
final int Function(String) _parsearEdadEstricta = m10.parsearEdad;
final int Function(List<String>, int Function()) _conRegistro =
    m10.conRegistro<int>;
final ({int total, List<String> rechazos}) Function(Iterable<String>)
_sumarEdades = m10.sumarEdades;
final String Function(Object) _mensajeParaUsuario = m10.mensajeParaUsuario;
final Future<List<String>> Function(List<String>) _ordenDeEjecucion =
    ordenDeEjecucion;
final Future<List<String>> Function(
  Future<String> Function(),
  Future<String> Function(),
)
_enSecuencia = enSecuencia;
final Future<List<String>> Function(
  Future<String> Function(),
  Future<String> Function(),
)
_enParalelo = enParalelo;
final Stream<int> Function(int) _contarHasta = contarHasta;
final Stream<int> Function(Stream<int>) _paresDuplicados = paresDuplicados;
final Future<({List<int> valores, String? error})> Function(Stream<int>)
_recolectar = recolectar;
final int Function(int) _sumaDeCuadrados = sumaDeCuadrados;
final Future<int> Function(int) _sumaDeCuadradosEnIsolate =
    sumaDeCuadradosEnIsolate;
final Future<({List<int> aqui, List<int> alla})> Function(List<int>)
_noCompartenMemoria = noCompartenMemoria;
final Future<List<String>> Function(int) _bloqueaElIsolate = bloqueaElIsolate;
final EntradaBitacora Function(String) _decodificarEntrada = decodificarEntrada;
final Argumentos Function(List<String>) _interpretarArgumentos =
    interpretarArgumentos;
final Version Function(String) _versionParsear = Version.parsear;
final bool Function(Version, Version) _satisfaceCaret = satisfaceCaret;
final Version? Function(Version, Iterable<Version>) _resolverMasAlta =
    resolverMasAlta;
final bool Function(String) _esApiPublica = esApiPublica;
final RepositorioTareas Function() _repositorioEnMemoria =
    RepositorioEnMemoria.new;
final RepositorioTareas Function() _repositorioQueFalla =
    RepositorioQueFalla.new;
final ServicioTareas Function(RepositorioTareas) _servicioTareas =
    ServicioTareas.new;
final AlmacenTexto Function([String?]) _almacenEnMemoria = AlmacenEnMemoria.new;
final RepositorioBitacora Function(AlmacenTexto) _repositorioBitacora =
    RepositorioBitacora.new;
final ServicioBitacora Function(RepositorioBitacora) _servicioBitacora =
    ServicioBitacora.new;

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
      _totalesPagados,
      _etiquetasUnicas,
      _indexarPor,
      _contarPorClave,
      _primeroQueCumple,
      _porcentaje,
      _porcentajeDesdeFraccion,
      _rangoFecha,
      _bitacora,
      _relojFijo,
      _servicioVencimiento,
      _enviadorEnMemoria,
      _contadorRegistrado,
      _estadosDescarga,
      _describir,
      _validarUsuario,
      _primeroONull,
      _separar,
      _parsearEdadEstricta,
      _conRegistro,
      _sumarEdades,
      _mensajeParaUsuario,
      _ordenDeEjecucion,
      _enSecuencia,
      _enParalelo,
      _contarHasta,
      _paresDuplicados,
      _recolectar,
      _sumaDeCuadrados,
      _sumaDeCuadradosEnIsolate,
      _noCompartenMemoria,
      _bloqueaElIsolate,
      _decodificarEntrada,
      _interpretarArgumentos,
      _versionParsear,
      _satisfaceCaret,
      _resolverMasAlta,
      _esApiPublica,
      _repositorioEnMemoria,
      _repositorioQueFalla,
      _servicioTareas,
      _almacenEnMemoria,
      _repositorioBitacora,
      _servicioBitacora,
    ], hasLength(66));
  });
}
