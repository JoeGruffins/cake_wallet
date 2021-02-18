import 'dart:convert';
import 'package:cake_wallet/exchange/trade_not_found_exeption.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:cake_wallet/.secrets.g.dart' as secrets;
import 'package:cake_wallet/entities/crypto_currency.dart';
import 'package:cake_wallet/exchange/exchange_pair.dart';
import 'package:cake_wallet/exchange/exchange_provider.dart';
import 'package:cake_wallet/exchange/limits.dart';
import 'package:cake_wallet/exchange/trade.dart';
import 'package:cake_wallet/exchange/trade_request.dart';
import 'package:cake_wallet/exchange/trade_state.dart';
import 'package:cake_wallet/exchange/changenow/changenow_request.dart';
import 'package:cake_wallet/exchange/exchange_provider_description.dart';
import 'package:cake_wallet/exchange/trade_not_created_exeption.dart';

class ChangeNowExchangeProvider extends ExchangeProvider {
  ChangeNowExchangeProvider()
      : super(
            pairList: CryptoCurrency.all
                .map((i) => CryptoCurrency.all
                    .map((k) => ExchangePair(from: i, to: k, reverse: true))
                    .where((c) => c != null))
                .expand((i) => i)
                .toList());

  static const apiUri = 'https://changenow.io/api/v1';
  static const apiKey = secrets.change_now_api_key;
  static const _exchangeAmountUriSufix = '/exchange-amount/';
  static const _transactionsUriSufix = '/transactions/';
  static const _minAmountUriSufix = '/min-amount/';
  static const _marketInfoUriSufix = '/market-info/';
  static const _fixedRateUriSufix = 'fixed-rate/';

  @override
  String get title => 'ChangeNOW';

  @override
  bool get isAvailable => true;

  @override
  ExchangeProviderDescription get description =>
      ExchangeProviderDescription.changeNow;

  @override
  Future<bool> checkIsAvailable() async => true;

  @override
  Future<Limits> fetchLimits({CryptoCurrency from, CryptoCurrency to,
    bool isFixedRateMode}) async {
    final symbol = from.toString() + '_' + to.toString();
    final url = isFixedRateMode
        ? apiUri + _marketInfoUriSufix + _fixedRateUriSufix + apiKey
        : apiUri + _minAmountUriSufix + symbol;
    final response = await get(url);

    if (isFixedRateMode) {
      final responseJSON = json.decode(response.body) as List<dynamic>;

      for (var elem in responseJSON) {
        final elemFrom = elem["from"] as String;
        final elemTo = elem["to"] as String;

        if ((elemFrom == from.toString().toLowerCase()) &&
            (elemTo == to.toString().toLowerCase())) {
          final min = elem["min"] as double;
          final max = elem["max"] as double;

          return Limits(min: min, max: max);
        }
      }
      return Limits(min: 0, max: 0);
    } else {
      final responseJSON = json.decode(response.body) as Map<String, dynamic>;
      final min = responseJSON['minAmount'] as double;

      return Limits(min: min, max: null);
    }
  }

  @override
  Future<Trade> createTrade({TradeRequest request, bool isFixedRateMode}) async {
    final url = isFixedRateMode
    ? apiUri + _transactionsUriSufix + _fixedRateUriSufix + apiKey
    : apiUri + _transactionsUriSufix + apiKey;
    final _request = request as ChangeNowRequest;
    final body = {
      'from': _request.from.toString(),
      'to': _request.to.toString(),
      'address': _request.address,
      'amount': _request.amount,
      'refundAddress': _request.refundAddress
    };

    final response = await post(url,
        headers: {'Content-Type': 'application/json'}, body: json.encode(body));

    if (response.statusCode != 200) {
      if (response.statusCode == 400) {
        final responseJSON = json.decode(response.body) as Map<String, dynamic>;
        final error = responseJSON['message'] as String;

        throw TradeNotCreatedException(description, description: error);
      }

      throw TradeNotCreatedException(description);
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final id = responseJSON['id'] as String;
    final inputAddress = responseJSON['payinAddress'] as String;
    final refundAddress = responseJSON['refundAddress'] as String;
    final extraId = responseJSON['payinExtraId'] as String;

    return Trade(
        id: id,
        from: _request.from,
        to: _request.to,
        provider: description,
        inputAddress: inputAddress,
        refundAddress: refundAddress,
        extraId: extraId,
        createdAt: DateTime.now(),
        amount: _request.amount,
        state: TradeState.created);
  }

  @override
  Future<Trade> findTradeById({@required String id}) async {
    final url = apiUri + _transactionsUriSufix + id + '/' + apiKey;
    final response = await get(url);

    if (response.statusCode != 200) {
      if (response.statusCode == 400) {
        final responseJSON = json.decode(response.body) as Map<String, dynamic>;
        final error = responseJSON['message'] as String;

        throw TradeNotFoundException(id,
            provider: description, description: error);
      }

      throw TradeNotFoundException(id, provider: description);
    }

    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final fromCurrency = responseJSON['fromCurrency'] as String;
    final from = CryptoCurrency.fromString(fromCurrency);
    final toCurrency = responseJSON['toCurrency'] as String;
    final to = CryptoCurrency.fromString(toCurrency);
    final inputAddress = responseJSON['payinAddress'] as String;
    final expectedSendAmount = responseJSON['expectedSendAmount'].toString();
    final status = responseJSON['status'] as String;
    final state = TradeState.deserialize(raw: status);
    final extraId = responseJSON['payinExtraId'] as String;
    final outputTransaction = responseJSON['payoutHash'] as String;

    return Trade(
        id: id,
        from: from,
        to: to,
        provider: description,
        inputAddress: inputAddress,
        amount: expectedSendAmount,
        state: state,
        extraId: extraId,
        outputTransaction: outputTransaction);
  }

  @override
  Future<double> calculateAmount(
      {CryptoCurrency from,
      CryptoCurrency to,
      double amount,
      bool isFixedRateMode,
      bool isReceiveAmount}) async {
    final url = isFixedRateMode
        ? apiUri +
          _exchangeAmountUriSufix +
          _fixedRateUriSufix +
          amount.toString() +
          '/' +
          from.toString() +
          '_' +
          to.toString() +
          '?api_key=' + apiKey
        : apiUri +
          _exchangeAmountUriSufix +
          amount.toString() +
          '/' +
          from.toString() +
          '_' +
          to.toString();
    final response = await get(url);
    final responseJSON = json.decode(response.body) as Map<String, dynamic>;
    final estimatedAmount = responseJSON['estimatedAmount'] as double;

    return estimatedAmount;
  }
}
