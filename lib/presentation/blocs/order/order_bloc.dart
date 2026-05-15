import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/domain/entities/order.dart';
import 'package:chapur_ia/domain/usecases/orders/order_use_cases.dart';
import 'package:chapur_ia/domain/entities/order_confirmation.dart';
import 'package:chapur_ia/domain/usecases/cart/get_delivery_defaults_use_case.dart';
import 'package:chapur_ia/domain/entities/delivery_defaults.dart';

// --- Events ---
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class FetchOrdersRequested extends OrderEvent {
  final String? accountNumber;
  const FetchOrdersRequested({this.accountNumber});
  @override
  List<Object?> get props => [accountNumber];
}

class FetchOrderDetailRequested extends OrderEvent {
  final String orderId;
  const FetchOrderDetailRequested(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class FetchDeliveryDefaultsRequested extends OrderEvent {}

/* 
  Since the API manages the cart on the server side (/api/cart),
  the Bloc will trigger API calls for cart modifications.
*/
class AddToCartRequested extends OrderEvent {
  final String articleCode;
  final int quantity;
  const AddToCartRequested({required this.articleCode, required this.quantity});
  @override
  List<Object?> get props => [articleCode, quantity];
}

class SubmitOrderRequested extends OrderEvent {
  final String deliveryAddress;
  final String deliveryContact;
  final String deliveryPhone;
  final String? notes;
  final String? estimatedDeliveryDate;

  const SubmitOrderRequested({
    required this.deliveryAddress,
    required this.deliveryContact,
    required this.deliveryPhone,
    this.notes,
    this.estimatedDeliveryDate,
  });

  @override
  List<Object?> get props => [
        deliveryAddress,
        deliveryContact,
        deliveryPhone,
        notes,
        estimatedDeliveryDate,
      ];
}

// --- States ---
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderListLoaded extends OrderState {
  final List<Order> orders;
  const OrderListLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final Order order;
  const OrderDetailLoaded(this.order);
  @override
  List<Object?> get props => [order];
}

class DeliveryDefaultsLoaded extends OrderState {
  final DeliveryDefaults defaults;
  const DeliveryDefaultsLoaded(this.defaults);
  @override
  List<Object?> get props => [defaults];
}

class OrderSuccess extends OrderState {
  final OrderConfirmation confirmation;
  const OrderSuccess(this.confirmation);
  @override
  List<Object?> get props => [confirmation];
}

class OrderFailure extends OrderState {
  final String message;
  const OrderFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderDetailUseCase getOrderDetailUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final GetDeliveryDefaultsUseCase? getDeliveryDefaultsUseCase;

  OrderBloc({
    required this.getOrdersUseCase,
    required this.getOrderDetailUseCase,
    required this.createOrderUseCase,
    this.getDeliveryDefaultsUseCase,
  }) : super(OrderInitial()) {
    on<FetchOrdersRequested>(_onFetchOrders);
    on<FetchOrderDetailRequested>(_onFetchOrderDetail);
    on<SubmitOrderRequested>(_onSubmitOrder);
    on<FetchDeliveryDefaultsRequested>(_onFetchDeliveryDefaults);
    // AddToCart logic would typically go into a CartDataSource/Repository
    // For now, focusing on Order flow as per the task list.
  }

  Future<void> _onFetchOrders(
    FetchOrdersRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await getOrdersUseCase.execute(accountNumber: event.accountNumber);
    result.fold(
      (failure) => emit(OrderFailure(failure.message)),
      (orders) => emit(OrderListLoaded(orders)),
    );
  }

  Future<void> _onFetchOrderDetail(
    FetchOrderDetailRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await getOrderDetailUseCase.execute(event.orderId);
    result.fold(
      (failure) => emit(OrderFailure(failure.message)),
      (order) => emit(OrderDetailLoaded(order)),
    );
  }

  Future<void> _onFetchDeliveryDefaults(
    FetchDeliveryDefaultsRequested event,
    Emitter<OrderState> emit,
  ) async {
    if (getDeliveryDefaultsUseCase == null) return;
    emit(OrderLoading());
    final result = await getDeliveryDefaultsUseCase!.execute();
    result.fold(
      (failure) => emit(OrderFailure(failure.message)),
      (defaults) {
        if (defaults != null) {
          emit(DeliveryDefaultsLoaded(defaults));
        } else {
          // If null, we just emit initial state or handled empty
          emit(OrderInitial());
        }
      },
    );
  }

  Future<void> _onSubmitOrder(
    SubmitOrderRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await createOrderUseCase.execute(
      deliveryAddress: event.deliveryAddress,
      deliveryContact: event.deliveryContact,
      deliveryPhone: event.deliveryPhone,
      notes: event.notes,
      estimatedDeliveryDate: event.estimatedDeliveryDate,
    );

    result.fold(
      (failure) => emit(OrderFailure(failure.message)),
      (confirmation) => emit(OrderSuccess(confirmation)),
    );
  }
}
