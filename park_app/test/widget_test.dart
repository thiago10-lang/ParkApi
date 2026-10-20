import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_app/models/tarifa.dart';
import 'package:park_app/models/ticket.dart';
import 'package:park_app/utils/pix.dart';

void main() {
  test('calcula o custo igual à tabela da API', () {
    const tarifa = Tarifa.padrao;
    expect(tarifa.calcularCusto(10), 5.00);
    expect(tarifa.calcularCusto(60), 9.25);
    expect(tarifa.calcularCusto(61), 11.00);
    expect(tarifa.calcularCusto(90), 12.75);
  });

  test('gera o Pix copia e cola com CRC válido', () {
    final payload = Pix.gerarPayload(
      chave: '123e4567-e12b-12d1-a456-426655440000',
      nome: 'Fulano de Tal',
      cidade: 'BRASILIA',
      valor: 1.00,
      identificador: '***',
    );
    expect(payload.startsWith('000201'), isTrue);
    expect(payload, contains('br.gov.bcb.pix'));
    expect(payload, contains('54041.00'));
    expect(payload, contains('5913FULANO DE TAL'));
    expect(payload.substring(payload.length - 8, payload.length - 4), '6304');
    expect(payload.substring(payload.length - 4), Pix.crc16(payload.substring(0, payload.length - 4)));
  });

  test('CRC16 confere com o exemplo do manual do Banco Central', () {
    const exemplo = '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d1-a456-426655440000'
        '5204000053039865802BR5913Fulano de Tal6008BRASILIA62070503***6304';
    expect(Pix.crc16(exemplo), '1D3D');
  });

  test('QR Code carrega o recibo e mascara o CPF', () {
    final ticket = Ticket.fromJson({
      'recibo': '20260927-143012',
      'placa': 'ABC1D23',
      'marca': 'Fiat',
      'modelo': 'Uno',
      'cor': 'Prata',
      'vagaCodigo': 'A-03',
      'clienteNome': 'Maria',
      'clienteCpf': '52998224725',
      'dataEntrada': '2026-09-27 14:30:12',
    });
    final payload = jsonDecode(ticket.qrPayload) as Map<String, dynamic>;
    expect(payload['recibo'], '20260927-143012');
    expect(payload['vaga'], 'A-03');
    expect(payload['cpf'], '***.982.247-**');
    expect(Ticket.reciboDoQr(ticket.qrPayload), '20260927-143012');
    expect(Ticket.reciboDoQr(' 20260927-143012 '), '20260927-143012');
    expect(Ticket.reciboDoQr('qualquer coisa'), isNull);
  });
}
