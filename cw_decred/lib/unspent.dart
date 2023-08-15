class Unspent {
  Unspent(this.address, this.hash, this.value, this.vout)
      : isSending = true,
        isFrozen = false,
        note = '';

  final String address;
  final String hash;
  final int value;
  final int vout;

  bool isSending;
  bool isFrozen;
  String note;
}
