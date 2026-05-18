import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';
import 'package:chapur_ia/domain/usecases/cart/get_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/add_item_to_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/clear_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/remove_item_from_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/select_cart_customer_use_case.dart';
import 'package:chapur_ia/domain/entities/cart_discounts.dart';
import 'package:chapur_ia/domain/usecases/cart/get_cart_discounts_use_case.dart';

// --- Events ---
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCartRequested extends CartEvent {}

class AddToCartRequested extends CartEvent {
  final CartItem item;
  const AddToCartRequested(this.item);
  @override
  List<Object?> get props => [item];
}

class RemoveFromCartRequested extends CartEvent {
  final String articleCode;
  const RemoveFromCartRequested(this.articleCode);
  @override
  List<Object?> get props => [articleCode];
}

class SelectCartCustomerRequested extends CartEvent {
  final String customerAccountNumber;
  const SelectCartCustomerRequested(this.customerAccountNumber);
  @override
  List<Object?> get props => [customerAccountNumber];
}

class ClearCartRequested extends CartEvent {}

// --- States ---
abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final Cart cart;
  final CartDiscounts? discounts;
  const CartLoaded(this.cart, {this.discounts});
  @override
  List<Object?> get props => [cart, discounts];
}

class CartFailure extends CartState {
  final String message;
  const CartFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;
  final ClearCartUseCase clearCartUseCase;
  final RemoveItemFromCartUseCase removeItemFromCartUseCase;
  final SelectCartCustomerUseCase selectCartCustomerUseCase;
  final GetCartDiscountsUseCase getCartDiscountsUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addItemToCartUseCase,
    required this.clearCartUseCase,
    required this.removeItemFromCartUseCase,
    required this.selectCartCustomerUseCase,
    required this.getCartDiscountsUseCase,
  }) : super(CartInitial()) {
    on<LoadCartRequested>(_onLoadCart);
    on<AddToCartRequested>(_onAddToCart);
    on<RemoveFromCartRequested>(_onRemoveFromCart);
    on<SelectCartCustomerRequested>(_onSelectCartCustomer);
    on<ClearCartRequested>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await getCartUseCase.execute();
    
    await result.fold(
      (failure) async => emit(CartFailure(failure.message)),
      (cart) async {
        final discountsResult = await getCartDiscountsUseCase.execute();
        CartDiscounts? discounts;
        discountsResult.fold(
          (failure) => null, // Just ignore discounts error if it fails
          (d) => discounts = d,
        );
        emit(CartLoaded(cart, discounts: discounts));
      },
    );
  }

  Future<void> _onAddToCart(AddToCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    // If we haven't loaded the cart yet, we should ideally load it or assume it's new.
    // The user said: "cuando se agrega por primera vez un item al carrito debe llamarse al endpoint api/cart"
    // We'll treat 'LoadCartRequested' as that initialization if needed.
    
    if (state is! CartLoaded) {
      // First time initialization
      final initResult = await getCartUseCase.execute();
      if (initResult.isLeft()) {
        initResult.fold((f) => emit(CartFailure(f.message)), (_) => null);
        return;
      }
    }

    final addResult = await addItemToCartUseCase.execute(event.item);
    addResult.fold(
      (failure) => emit(CartFailure(failure.message)),
      (_) => add(LoadCartRequested()), // Reload cart after adding
    );
  }

  Future<void> _onRemoveFromCart(RemoveFromCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await removeItemFromCartUseCase.execute(event.articleCode);
    result.fold(
      (failure) => emit(CartFailure(failure.message)),
      (_) => add(LoadCartRequested()), // Reload cart after removing
    );
  }

  Future<void> _onSelectCartCustomer(SelectCartCustomerRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await selectCartCustomerUseCase.execute(event.customerAccountNumber);
    result.fold(
      (failure) => emit(CartFailure(failure.message)),
      (_) => add(LoadCartRequested()), // Reload/Initialize cart for selected customer
    );
  }

  Future<void> _onClearCart(ClearCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await clearCartUseCase.execute();
    result.fold(
      (failure) => emit(CartFailure(failure.message)),
      (_) => emit(const CartLoaded(Cart(
            items: [],
            subtotal: 0.0,
            ivaTotal: 0.0,
            grandTotal: 0.0,
            subtotalUsd: 0.0,
            ivaTotalUsd: 0.0,
            grandTotalUsd: 0.0,
            iva21Usd: 0.0,
            iva105Usd: 0.0,
          ))),
    );
  }
}
