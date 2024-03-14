import 'package:cw_core/wallet_credentials.dart';
import 'package:cw_core/wallet_info.dart';

class DecredNewWalletCredentials extends WalletCredentials {
  DecredNewWalletCredentials({required String name, WalletInfo? walletInfo})
      : super(name: name, walletInfo: walletInfo);
}

class DecredRestoreWalletFromSeedCredentials extends WalletCredentials {
  DecredRestoreWalletFromSeedCredentials(
      {required String name,
      required String password,
      required this.mnemonic,
      WalletInfo? walletInfo})
      : super(name: name, password: password, walletInfo: walletInfo);

  final String mnemonic;
}

class DecredRestoreWalletFromPubkeyCredentials extends WalletCredentials {
  DecredRestoreWalletFromPubkeyCredentials(
      {required String name,
      required String password,
      required String this.pubkey,
      WalletInfo? walletInfo})
      : super(name: name, password: password, walletInfo: walletInfo);

  final String pubkey;
}
