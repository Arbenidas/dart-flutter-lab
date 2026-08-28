import 'package:dart_lab/m08_contratos.dart';
import 'package:test/test.dart';

void main() {
  final hoy = DateTime.utc(2026, 6, 15);

  group('m08-1 RelojFijo cumple el contrato Reloj', () {
    test('siempre devuelve el mismo instante', () {
      final reloj = RelojFijo(hoy);
      expect(reloj.ahora(), hoy);
      expect(reloj.ahora(), hoy);
    });

    test('es sustituible donde se espera un Reloj', () {
      final Reloj reloj = RelojFijo(hoy);
      expect(reloj.ahora(), hoy);
    });
  });

  group('m08-2 ServicioVencimiento depende del contrato', () {
    final servicio = ServicioVencimiento(RelojFijo(hoy));

    test('detecta una fecha vencida', () {
      expect(servicio.vencio(DateTime.utc(2026, 6, 14)), isTrue);
    });

    test('una fecha futura no vencio', () {
      expect(servicio.vencio(DateTime.utc(2026, 6, 16)), isFalse);
    });

    test('el instante exacto todavia no vencio', () {
      expect(servicio.vencio(hoy), isFalse);
    });

    test('cuenta dias restantes con signo', () {
      expect(servicio.diasRestantes(DateTime.utc(2026, 6, 20)), 5);
      expect(servicio.diasRestantes(DateTime.utc(2026, 6, 10)), -5);
    });
  });

  group('m08-3 EnviadorEnMemoria', () {
    test('acumula lo enviado', () {
      final enviador = EnviadorEnMemoria()
        ..enviar(destino: 'ana@ejemplo.com', cuerpo: 'Hola');
      expect(enviador.enviados, hasLength(1));
      expect(enviador.enviados.single.destino, 'ana@ejemplo.com');
    });

    test('rechaza un destino vacio', () {
      expect(
        () => EnviadorEnMemoria().enviar(destino: '  ', cuerpo: 'Hola'),
        throwsArgumentError,
      );
    });
  });

  group('m08-4 NotificadorVencimiento compone contratos', () {
    test('avisa solo cuando la fecha vencio', () {
      final enviador = EnviadorEnMemoria();
      final notificador = NotificadorVencimiento(
        servicio: ServicioVencimiento(RelojFijo(hoy)),
        enviador: enviador,
      );

      expect(
        notificador.avisarSiVencio(
          destino: 'ana@ejemplo.com',
          limite: DateTime.utc(2026, 6, 14),
        ),
        isTrue,
      );
      expect(enviador.enviados, hasLength(1));
    });

    test('no envia nada cuando la fecha no vencio', () {
      final enviador = EnviadorEnMemoria();
      final notificador = NotificadorVencimiento(
        servicio: ServicioVencimiento(RelojFijo(hoy)),
        enviador: enviador,
      );

      expect(
        notificador.avisarSiVencio(
          destino: 'ana@ejemplo.com',
          limite: DateTime.utc(2026, 7, 1),
        ),
        isFalse,
      );
      expect(enviador.enviados, isEmpty);
    });
  });

  group('m08-5 mixin Registrable', () {
    test('registra cada operacion en orden', () {
      final contador = ContadorRegistrado()
        ..incrementar()
        ..incrementar()
        ..reiniciar();

      expect(contador.valor, 0);
      expect(contador.registro, <String>[
        'incrementar -> 1',
        'incrementar -> 2',
        'reiniciar -> 0',
      ]);
    });

    test('el registro expuesto no se puede modificar', () {
      final contador = ContadorRegistrado()..incrementar();
      expect(() => contador.registro.add('colado'), throwsUnsupportedError);
    });

    test('cada instancia tiene su propio registro', () {
      final uno = ContadorRegistrado()..incrementar();
      final otro = ContadorRegistrado();
      expect(uno.registro, hasLength(1));
      expect(otro.registro, isEmpty);
    });
  });
}
