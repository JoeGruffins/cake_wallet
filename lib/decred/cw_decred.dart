part of 'decred.dart';

class CWDecred extends Decred {
	@override
	TransactionPriority getMediumTransactionPriority() => DecredTransactionPriority.medium;	

	@override
	WalletCredentials createDecredRestoreWalletFromSeedCredentials({
    required String name,
    required String mnemonic,
    required String password})
		=> DecredRestoreWalletFromSeedCredentials(name: name, mnemonic: mnemonic, password: password);
	
	@override
	WalletCredentials createDecredRestoreWalletFromWIFCredentials({
    required String name,
    required String password,
    required String wif,
    WalletInfo? walletInfo})
		=> DecredRestoreWalletFromWIFCredentials(name: name, password: password, wif: wif, walletInfo: walletInfo);
	
	@override
	WalletCredentials createDecredNewWalletCredentials({
    required String name,
    WalletInfo? walletInfo})
		=> DecredNewWalletCredentials(name: name, walletInfo: walletInfo);

	@override
	List<String> getWordList() => wordlist;

	@override
	Map<String, String> getWalletKeys(Object wallet) {
		final decredWallet = wallet as ElectrumWallet;
		final keys = decredWallet.keys;
		
		return <String, String>{
			'wif': keys.wif,
			'privateKey': keys.privateKey,
			'publicKey': keys.publicKey	
		};
	}
	
	@override
	List<TransactionPriority> getTransactionPriorities() 
		=> DecredTransactionPriority.all;

	@override
	TransactionPriority deserializeDecredTransactionPriority(int raw)
		=> DecredTransactionPriority.deserialize(raw: raw);

	@override
	int getFeeRate(Object wallet, TransactionPriority priority) {
		final decredWallet = wallet as ElectrumWallet;
		return decredWallet.feeRate(priority);
	}

	@override
	Future<void> generateNewAddress(Object wallet) async {
		final decredWallet = wallet as ElectrumWallet;
		await decredWallet.walletAddresses.generateNewAddress();
	}
	
	@override
	Object createDecredTransactionCredentials(List<Output> outputs, {required TransactionPriority priority, int? feeRate})
		=> DecredTransactionCredentials(
			outputs.map((out) => OutputInfo(
					fiatAmount: out.fiatAmount,
					cryptoAmount: out.cryptoAmount,
					address: out.address,
					note: out.note,
					sendAll: out.sendAll,
					extractedAddress: out.extractedAddress,
					isParsedAddress: out.isParsedAddress,
					formattedCryptoAmount: out.formattedCryptoAmount))
			.toList(),
			priority: priority != null ? priority as DecredTransactionPriority : null,
			feeRate: feeRate);

	@override
	Object createDecredTransactionCredentialsRaw(List<OutputInfo> outputs, {TransactionPriority? priority, required int feeRate})
		=> DecredTransactionCredentials(
				outputs,
				priority: priority != null ? priority as DecredTransactionPriority : null,
				feeRate: feeRate);

	@override
	List<String> getAddresses(Object wallet) {
		final decredWallet = wallet as ElectrumWallet;
		return decredWallet.walletAddresses.addresses
			.map((DecredAddressRecord addr) => addr.address)
			.toList();
	}

	@override
	String getAddress(Object wallet) {
		final decredWallet = wallet as ElectrumWallet;
		return decredWallet.walletAddresses.address;
	}

	@override
	String formatterDecredAmountToString({required int amount})
		=> decredAmountToString(amount: amount);

	@override	
	double formatterDecredAmountToDouble({required int amount})
		=> decredAmountToDouble(amount: amount);

	@override	
	int formatterStringDoubleToDecredAmount(String amount)
		=> stringDoubleToDecredAmount(amount);

  @override
  String decredTransactionPriorityWithLabel(TransactionPriority priority, int rate)
    => (priority as DecredTransactionPriority).labelWithRate(rate);

	@override
	List<Unspent> getUnspents(Object wallet) {
		final decredWallet = wallet as ElectrumWallet;
		return decredWallet.unspentCoins
			.map((DecredUnspent decredUnspent) => Unspent(
				decredUnspent.address.address,
				decredUnspent.hash,
				decredUnspent.value,
				decredUnspent.vout))
			.toList();
	}

	void updateUnspents(Object wallet) async {
		final decredWallet = wallet as ElectrumWallet;
		await decredWallet.updateUnspent();
	}

	WalletService createDecredWalletService(Box<WalletInfo> walletInfoSource, Box<UnspentCoinsInfo> unspentCoinSource) {
		return DecredWalletService(walletInfoSource, unspentCoinSource);
	}
  
  @override
  TransactionPriority getDecredTransactionPriorityMedium()
    => DecredTransactionPriority.medium;

  @override
  TransactionPriority getDecredTransactionPrioritySlow()
    => DecredTransactionPriority.slow;
}
