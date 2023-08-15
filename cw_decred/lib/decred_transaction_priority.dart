import 'package:cw_core/transaction_priority.dart';
//import 'package:cake_wallet/generated/i18n.dart';

class DecredTransactionPriority extends TransactionPriority {
  const DecredTransactionPriority({required String title, required int raw})
      : super(title: title, raw: raw);

  static const List<DecredTransactionPriority> all = [fast, medium, slow];
  static const DecredTransactionPriority slow =
      DecredTransactionPriority(title: 'Slow', raw: 0);
  static const DecredTransactionPriority medium =
      DecredTransactionPriority(title: 'Medium', raw: 1);
  static const DecredTransactionPriority fast =
      DecredTransactionPriority(title: 'Fast', raw: 2);

  static DecredTransactionPriority deserialize({required int raw}) {
    switch (raw) {
      case 0:
        return slow;
      case 1:
        return medium;
      case 2:
        return fast;
      default:
        throw Exception('Unexpected token: $raw for DecredTransactionPriority deserialize');
    }
  }

  String get units => 'sat';

  @override
  String toString() {
    var label = '';

    switch (this) {
      case DecredTransactionPriority.slow:
        label = 'Slow ~24hrs'; // '${S.current.transaction_priority_slow} ~24hrs';
        break;
      case DecredTransactionPriority.medium:
        label = 'Medium'; // S.current.transaction_priority_medium;
        break;
      case DecredTransactionPriority.fast:
        label = 'Fast'; // S.current.transaction_priority_fast;
        break;
      default:
        break;
    }

    return label;
  }

  String labelWithRate(int rate) => '${toString()} ($rate ${units}/byte)';
}

class LitecoinTransactionPriority extends DecredTransactionPriority {
  const LitecoinTransactionPriority({required String title, required int raw})
      : super(title: title, raw: raw);

  static const List<LitecoinTransactionPriority> all = [fast, medium, slow];
  static const LitecoinTransactionPriority slow =
      LitecoinTransactionPriority(title: 'Slow', raw: 0);
  static const LitecoinTransactionPriority medium =
      LitecoinTransactionPriority(title: 'Medium', raw: 1);
  static const LitecoinTransactionPriority fast =
      LitecoinTransactionPriority(title: 'Fast', raw: 2);

  static LitecoinTransactionPriority deserialize({required int raw}) {
    switch (raw) {
      case 0:
        return slow;
      case 1:
        return medium;
      case 2:
        return fast;
      default:
        throw Exception('Unexpected token: $raw for LitecoinTransactionPriority deserialize');
    }
  }

  @override
  String get units => 'Latoshi';

  @override
  String toString() {
    var label = '';

    switch (this) {
      case LitecoinTransactionPriority.slow:
        label = 'Slow'; // S.current.transaction_priority_slow;
        break;
      case LitecoinTransactionPriority.medium:
        label = 'Medium'; // S.current.transaction_priority_medium;
        break;
      case LitecoinTransactionPriority.fast:
        label = 'Fast'; // S.current.transaction_priority_fast;
        break;
      default:
        break;
    }

    return label;
  }
}
