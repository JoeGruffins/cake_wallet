import 'package:mobx/mobx.dart';
import 'package:cw_core/transaction_info.dart';
import 'package:cw_core/transaction_history.dart';

class DecredTransactionHistory extends TransactionHistoryBase<TransactionInfo> {
  DecredTransactionHistory() {
    transactions = ObservableMap<String, TransactionInfo>();
  }

  Future<void> init() async {}

  @override
  void addOne(TransactionInfo transaction) =>
      transactions[transaction.id] = transaction;

  @override
  void addMany(Map<String, TransactionInfo> transactions) =>
      this.transactions.addAll(transactions);

  @override
  Future<void> save() async {}

  Future<void> changePassword(String password) async {}

  // update returns true if a known transaction that is not pending was found.
  bool update(Map<String, TransactionInfo> txs) {
    var foundOldTx = false;
    txs.forEach((_, tx) {
      if (!this.transactions.containsKey(tx.id) ||
          this.transactions[tx.id]!.isPending) {
        this.transactions[tx.id] = tx;
      } else {
        foundOldTx = true;

        // NOTE: We are only fetching 5 transactions from
        // libdcrwallet.listTransactions and we could run into issues where the
        // wrong tx amount is reported if a user creates a send transaction that
        // spends to more than 5 output, i.e we fetch the first 2, 3 or 4 as
        // part of an initial request and account for outputs that have the same
        // txid but when a second request is made to update this.transactions,
        // the last transaction will be ignored since they share the same id.
        // However, this edge case is handle by the block of code below.
        final oldTx = this.transactions[tx.id];
        if (oldTx!.amount != tx.amount) {
          // Update tx amount.
          tx.amount += oldTx.amount;

          // Update list of output address but avoid duplicates.
          oldTx.outputAddresses?.every((outputAddress) {
            final bool outputAddressExists =
                tx.outputAddresses!.contains(outputAddress);
            if (!outputAddressExists) {
              tx.outputAddresses?.add(outputAddress);
            }
            return true;
          });

          this.transactions[tx.id] = tx;
        }
      }
    });
    return foundOldTx;
  }
}
