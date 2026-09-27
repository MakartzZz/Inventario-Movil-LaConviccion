import 'package:flutter_test/flutter_test.dart';
import 'package:inv_movil_laconviccion/core/utils/helpers.dart';

void main() {
  group('Helpers', () {
    test('valida PINs de cuatro digitos', () {
      expect(Helpers.validarPin('1234'), isTrue);
      expect(Helpers.validarPin('9999'), isTrue);
      expect(Helpers.validarPin('123'), isFalse);
      expect(Helpers.validarPin('12a4'), isFalse);
    });

    test('formatea cantidades enteras y decimales', () {
      expect(Helpers.formatearCantidad(20), '20');
      expect(Helpers.formatearCantidad(3.5), '3.5');
    });
  });
}
