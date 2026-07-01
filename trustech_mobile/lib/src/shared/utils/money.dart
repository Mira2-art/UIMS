import 'package:intl/intl.dart';

/// Currency formatting for the app. Trustech operates in **FCFA** (Central
/// African CFA franc, XAF) — no minor units, space/comma grouped.
final _fcfa = NumberFormat('#,##0', 'en');

/// Formats an amount as FCFA, e.g. `1,250,000 FCFA`.
String formatFcfa(num amount) => '${_fcfa.format(amount)} FCFA';
