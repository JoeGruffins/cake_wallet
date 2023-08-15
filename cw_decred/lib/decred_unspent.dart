import 'package:cw_decred/decred_address_record.dart';

class DecredUnspent {
  DecredUnspent(this.address, this.hash, this.value, this.vout)
      : isSending = true,
        isFrozen = false,
        note = '';

  factory DecredUnspent.fromJSON(
          DecredAddressRecord address, Map<String, dynamic> json) =>
      DecredUnspent(address, json['tx_hash'] as String, json['value'] as int,
          json['tx_pos'] as int);

  final DecredAddressRecord address;
  final String hash;
  final int value;
  final int vout;

  bool get isP2wpkh =>
      address.address.startsWith('bc') || address.address.startsWith('ltc');
  bool isSending;
  bool isFrozen;
  String note;
}
