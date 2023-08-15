import 'package:cw_core/crypto_currency.dart';

class DecredTransactionWrongBalanceException implements Exception {
  DecredTransactionWrongBalanceException(this.currency);

  final CryptoCurrency currency;

  @override
  String toString() => 'You do not have enough ${currency.title} to send this amount.';
}