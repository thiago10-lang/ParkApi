class Pix {
  static String gerarPayload({
    required String chave,
    required String nome,
    required String cidade,
    required double valor,
    required String identificador,
  }) {
    final contaRecebedor = _campo('00', 'br.gov.bcb.pix') + _campo('01', chave.trim());
    final txid = identificador.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final dadosAdicionais = _campo('05', txid.isEmpty ? '***' : _limitar(txid, 25));

    final payload = StringBuffer()
      ..write(_campo('00', '01'))
      ..write(_campo('26', contaRecebedor))
      ..write(_campo('52', '0000'))
      ..write(_campo('53', '986'))
      ..write(_campo('54', valor.toStringAsFixed(2)))
      ..write(_campo('58', 'BR'))
      ..write(_campo('59', _limitar(_normalizar(nome.isEmpty ? 'PARKAPI' : nome), 25)))
      ..write(_campo('60', _limitar(_normalizar(cidade.isEmpty ? 'SAO PAULO' : cidade), 15)))
      ..write(_campo('62', dadosAdicionais))
      ..write('6304');

    final semCrc = payload.toString();
    return semCrc + crc16(semCrc);
  }

  static String _campo(String id, String valor) => '$id${valor.length.toString().padLeft(2, '0')}$valor';

  static String _limitar(String valor, int maximo) => valor.length > maximo ? valor.substring(0, maximo) : valor;

  static String _normalizar(String texto) {
    const deParaOrigem = 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇáàâãäéèêëíìîïóòôõöúùûüç';
    const deParaDestino = 'AAAAAEEEEIIIIOOOOOUUUUCaaaaaeeeeiiiiooooouuuuc';
    final buffer = StringBuffer();
    for (final rune in texto.runes) {
      final char = String.fromCharCode(rune);
      final indice = deParaOrigem.indexOf(char);
      buffer.write(indice >= 0 ? deParaDestino[indice] : char);
    }
    return buffer.toString().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9 ]'), '').trim();
  }

  static String crc16(String dados) {
    var crc = 0xFFFF;
    for (final byte in dados.codeUnits) {
      crc ^= byte << 8;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1);
        crc &= 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
