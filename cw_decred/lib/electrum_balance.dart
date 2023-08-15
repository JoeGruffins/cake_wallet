import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cw_decred/decred_amount_format.dart';
import 'package:cw_core/balance.dart';

class ElectrumBalance extends Balance {
  const ElectrumBalance({required this.confirmed, required this.unconfirmed, required this.frozen})
      : super(confirmed, unconfirmed);

  static ElectrumBalance? fromJSON(String? jsonSource) {
    if (jsonSource == null) {
      return null;
    }

    final decoded = json.decode(jsonSource) as Map;

    return ElectrumBalance(
        confirmed: decoded['confirmed'] as int? ?? 0,
        unconfirmed: decoded['unconfirmed'] as int? ?? 0,
        frozen: decoded['frozen'] as int? ?? 0);
  }

  final int confirmed;
  final int unconfirmed;
  final int frozen;

  @override
  String get formattedAvailableBalance => decredAmountToString(amount: confirmed - frozen);

  @override
  String get formattedAdditionalBalance => decredAmountToString(amount: unconfirmed);

  String get formattedFrozenBalance {
    final frozenFormatted = decredAmountToString(amount: frozen);
    return frozenFormatted == '0.0' ? '' : frozenFormatted;
  }

  String toJSON() =>
      json.encode({'confirmed': confirmed, 'unconfirmed': unconfirmed, 'frozen': frozen});
}
