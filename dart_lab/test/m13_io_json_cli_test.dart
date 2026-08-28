import 'package:dart_lab/m13_io_json_cli.dart';
import 'package:test/test.dart';

void main() {
  group('m13-1 construirConsulta', () {
    test('arma la ruta y la consulta', () {
      final uri = construirConsulta(
        base: 'https://api.ejemplo.com',
        ruta: '/v1/entradas',
        parametros: <String, String>{'limite': '10'},
      );
      expect(uri.toString(), 'https://api.ejemplo.com/v1/entradas?limite=10');
    });

    test('codifica los valores con caracteres especiales', () {
      final uri = construirConsulta(
        base: 'https://api.ejemplo.com',
        ruta: '/buscar',
        parametros: <String, String>{'q': 'dart & flutter'},
      );
      expect(uri.queryParameters['q'], 'dart & flutter');
      expect(uri.toString(), isNot(contains(' ')));
    });

    test('rechaza una base que no sea https', () {
      expect(
        () => construirConsulta(base: 'http://api.ejemplo.com', ruta: '/x'),
        throwsArgumentError,
      );
    });

    test('sin parametros no agrega interrogacion', () {
      final uri = construirConsulta(base: 'https://a.com', ruta: '/x');
      expect(uri.toString(), 'https://a.com/x');
    });
  });

  group('m13-2 decodificarEntrada acepta lo valido', () {
    test('construye el modelo', () {
      final entrada = decodificarEntrada(
        '{"id":"e1","titulo":" Primera ","etiquetas":["dart"]}',
      );
      expect(entrada.id, 'e1');
      expect(entrada.titulo, 'Primera');
      expect(entrada.etiquetas, <String>['dart']);
    });

    test('etiquetas ausentes se toman como lista vacia', () {
      final entrada = decodificarEntrada('{"id":"e1","titulo":"Primera"}');
      expect(entrada.etiquetas, isEmpty);
    });
  });

  group('m13-3 decodificarEntrada distingue los fallos', () {
    test('sintaxis invalida es FormatException', () {
      expect(() => decodificarEntrada('{no es json'), throwsFormatException);
    });

    test('raiz que no es objeto es FormatException', () {
      expect(() => decodificarEntrada('[1,2]'), throwsFormatException);
    });

    test('forma incorrecta es FormatException', () {
      expect(
        () => decodificarEntrada('{"id":1,"titulo":"x"}'),
        throwsFormatException,
      );
    });

    test('etiquetas con un numero es FormatException', () {
      expect(
        () => decodificarEntrada('{"id":"e1","titulo":"x","etiquetas":[1]}'),
        throwsFormatException,
      );
    });

    test('titulo vacio es un fallo de dominio, no de formato', () {
      expect(
        () => decodificarEntrada('{"id":"e1","titulo":"   "}'),
        throwsArgumentError,
      );
    });
  });

  group('m13-4 interpretarArgumentos', () {
    test('separa comando, opciones y libres', () {
      final resultado = interpretarArgumentos(<String>[
        'listar',
        '--limite=10',
        'hoy',
        '--formato=json',
      ]);
      expect(resultado.comando, 'listar');
      expect(resultado.opciones, <String, String>{
        'limite': '10',
        'formato': 'json',
      });
      expect(resultado.libres, <String>['hoy']);
    });

    test('sin argumentos lanza', () {
      expect(() => interpretarArgumentos(<String>[]), throwsArgumentError);
    });

    test('una opcion sin igual lanza', () {
      expect(
        () => interpretarArgumentos(<String>['listar', '--limite']),
        throwsArgumentError,
      );
    });

    test('acepta un valor con signo igual dentro', () {
      final resultado = interpretarArgumentos(<String>['x', '--q=a=b']);
      expect(resultado.opciones['q'], 'a=b');
    });
  });
}
