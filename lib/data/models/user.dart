import 'account.dart';

class User {
  final String name;
  final String email;
  final List<Account> accounts;

  const User({
    required this.name,
    required this.email,
    required this.accounts,
  });
}
