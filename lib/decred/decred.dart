import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_info.dart';
import 'package:cw_core/transaction_priority.dart';
import 'package:cw_core/output_info.dart';
import 'package:cw_core/unspent_coins_info.dart';
import 'package:cw_core/wallet_service.dart';
import 'package:cake_wallet/view_model/send/output.dart';
import 'package:hive/hive.dart';
import 'package:cw_decred/electrum_wallet.dart';
import 'package:cw_decred/decred_unspent.dart';
import 'package:cw_decred/decred_mnemonic.dart';
import 'package:cw_decred/decred_transaction_priority.dart';
import 'package:cw_decred/decred_wallet.dart';
import 'package:cw_decred/decred_wallet_service.dart';
import 'package:cw_decred/decred_wallet_creation_credentials.dart';
import 'package:cw_decred/decred_amount_format.dart';
import 'package:cw_decred/decred_address_record.dart';
import 'package:cw_decred/decred_transaction_credentials.dart';

part 'cw_decred.dart';

Decred? decred = CWDecred();

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

  bool get isP2wpkh => address.startsWith('bc') || address.startsWith('ltc');
}

abstract class Decred {
  TransactionPriority getMediumTransactionPriority();

  WalletCredentials createDecredRestoreWalletFromSeedCredentials({required String name, required String mnemonic, required String password});
  WalletCredentials createDecredRestoreWalletFromWIFCredentials({required String name, required String password, required String wif, WalletInfo? walletInfo});
  WalletCredentials createDecredNewWalletCredentials({required String name, WalletInfo? walletInfo});
  List<String> getWordList();
  Map<String, String> getWalletKeys(Object wallet);
  List<TransactionPriority> getTransactionPriorities();
  TransactionPriority deserializeDecredTransactionPriority(int raw); 
  int getFeeRate(Object wallet, TransactionPriority priority);
  Future<void> generateNewAddress(Object wallet);
  Object createDecredTransactionCredentials(List<Output> outputs, {required TransactionPriority priority, int? feeRate});
  Object createDecredTransactionCredentialsRaw(List<OutputInfo> outputs, {TransactionPriority? priority, required int feeRate});

  List<String> getAddresses(Object wallet);
  String getAddress(Object wallet);

  String formatterDecredAmountToString({required int amount});
  double formatterDecredAmountToDouble({required int amount});
  int formatterStringDoubleToDecredAmount(String amount);
  String decredTransactionPriorityWithLabel(TransactionPriority priority, int rate);

  List<Unspent> getUnspents(Object wallet);
  void updateUnspents(Object wallet);
  WalletService createDecredWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource);
  TransactionPriority getDecredTransactionPriorityMedium();
  TransactionPriority getDecredTransactionPrioritySlow();
}
  