import '../../domain/entities/exchange_rate.dart';

class ExchangeRateModel extends ExchangeRate {
  const ExchangeRateModel({
    required super.from,
    required super.to,
    required super.rate,
    required super.asOf,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      asOf: json['asOf']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'rate': rate,
      'asOf': asOf,
    };
  }
}
