import 'package:dartz/dartz.dart';
import 'package:chapur_ia/core/error/failures.dart';
import 'package:chapur_ia/domain/entities/delivery_defaults.dart';
import 'package:chapur_ia/domain/repositories/i_cart_repository.dart';

class GetDeliveryDefaultsUseCase {
  final ICartRepository repository;

  GetDeliveryDefaultsUseCase({required this.repository});

  Future<Either<Failure, DeliveryDefaults?>> execute() async {
    return await repository.getDeliveryDefaults();
  }
}
