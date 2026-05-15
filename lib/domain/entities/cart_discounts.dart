class CartDiscounts {
  final double subtotal;
  final double iva21;
  final double iva105;
  final double total;
  final bool appliesDiscounts;
  final double dcgAmount;
  final double volumeDiscountAmount;
  final bool isBiglieri;
  final double grpMaq;
  final double grpAcc;
  final double grpRep;
  final double montoTotal2;
  final double financial30DFFAmount;
  final double financialCashAmount;
  final double montoTotal3;
  final double montoTotal4;

  const CartDiscounts({
    required this.subtotal,
    required this.iva21,
    required this.iva105,
    required this.total,
    required this.appliesDiscounts,
    required this.dcgAmount,
    required this.volumeDiscountAmount,
    required this.isBiglieri,
    required this.grpMaq,
    required this.grpAcc,
    required this.grpRep,
    required this.montoTotal2,
    required this.financial30DFFAmount,
    required this.financialCashAmount,
    required this.montoTotal3,
    required this.montoTotal4,
  });
}
