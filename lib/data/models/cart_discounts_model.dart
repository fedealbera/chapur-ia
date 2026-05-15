import 'package:chapur_ia/domain/entities/cart_discounts.dart';

class CartDiscountsModel extends CartDiscounts {
  const CartDiscountsModel({
    super.subtotal = 0.0,
    super.iva21 = 0.0,
    super.iva105 = 0.0,
    super.total = 0.0,
    super.appliesDiscounts = false,
    super.dcgAmount = 0.0,
    super.volumeDiscountAmount = 0.0,
    super.isBiglieri = false,
    super.grpMaq = 0.0,
    super.grpAcc = 0.0,
    super.grpRep = 0.0,
    super.montoTotal2 = 0.0,
    super.financial30DFFAmount = 0.0,
    super.financialCashAmount = 0.0,
    super.montoTotal3 = 0.0,
    super.montoTotal4 = 0.0,
  });

  factory CartDiscountsModel.fromJson(Map<String, dynamic> json) {
    return CartDiscountsModel(
      subtotal: ((json['subtotal'] ?? 0) as num).toDouble(),
      iva21: ((json['iva21'] ?? 0) as num).toDouble(),
      iva105: ((json['iva105'] ?? 0) as num).toDouble(),
      total: ((json['total'] ?? 0) as num).toDouble(),
      appliesDiscounts: json['appliesDiscounts'] == true,
      dcgAmount: ((json['dcgAmount'] ?? 0) as num).toDouble(),
      volumeDiscountAmount: ((json['volumeDiscountAmount'] ?? 0) as num).toDouble(),
      isBiglieri: json['isBiglieri'] == true,
      grpMaq: ((json['grpMaq'] ?? 0) as num).toDouble(),
      grpAcc: ((json['grpAcc'] ?? 0) as num).toDouble(),
      grpRep: ((json['grpRep'] ?? 0) as num).toDouble(),
      montoTotal2: ((json['montoTotal2'] ?? 0) as num).toDouble(),
      financial30DFFAmount: ((json['financial30DFFAmount'] ?? 0) as num).toDouble(),
      financialCashAmount: ((json['financialCashAmount'] ?? 0) as num).toDouble(),
      montoTotal3: ((json['montoTotal3'] ?? 0) as num).toDouble(),
      montoTotal4: ((json['montoTotal4'] ?? 0) as num).toDouble(),
    );
  }
}
