import 'dart:convert';

class DecredAddressRecord {
  DecredAddressRecord(this.address,
    {required this.index, this.isHidden = false, bool isUsed = false})
   : _isUsed = isUsed;

  factory DecredAddressRecord.fromJSON(String jsonSource) {
    final decoded = json.decode(jsonSource) as Map;

    return DecredAddressRecord(
      decoded['address'] as String,
      index: decoded['index'] as int,
      isHidden: decoded['isHidden'] as bool? ?? false,
      isUsed: decoded['isUsed'] as bool? ?? false);
  }

  @override
  bool operator ==(Object o) =>
      o is DecredAddressRecord && address == o.address;

  final String address;
  final bool isHidden;
  final int index;
  bool get isUsed => _isUsed;

  @override
  int get hashCode => address.hashCode;

  bool _isUsed;

  void setAsUsed() => _isUsed = true;

  String toJSON() =>
      json.encode({
        'address': address,
        'index': index,
        'isHidden': isHidden,
        'isUsed': isUsed});
}
