import 'models/account.dart';
import 'models/user.dart';

class MockAccounts {
  static const Account everydayChecking = Account(
    id: 'acc_001',
    name: 'Everyday Checking',
    type: AccountType.checking,
    balance: 4285.50,
    currency: 'GBP',
  );

  static const Account savingsGoal = Account(
    id: 'acc_002',
    name: 'Savings Goal',
    type: AccountType.savings,
    balance: 12750.00,
    currency: 'GBP',
  );

  static const Account creditCard = Account(
    id: 'acc_003',
    name: 'Credit Card',
    type: AccountType.credit,
    balance: -1430.22,
    currency: 'GBP',
  );

  static const List<Account> all = [everydayChecking, savingsGoal, creditCard];

  static const User currentUser = User(
    name: 'Alex Johnson',
    email: 'alex.johnson@email.com',
    accounts: all,
  );
}
