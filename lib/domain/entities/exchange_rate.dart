import 'package:equatable/equatable.dart';

class ExchangeRate extends Equatable {
  final String from;
  final String to;
  final double rate;
  final String asOf;

  const ExchangeRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.asOf,
  });

  @override
  List<Object?> get props => [from, to, rate, asOf];
}
