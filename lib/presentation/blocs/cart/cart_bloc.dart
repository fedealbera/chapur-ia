import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/domain/entities/cart.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';
import 'package:chapur_ia/domain/usecases/cart/get_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/add_item_to_cart_use_case.dart';
import 'package:chapur_ia/domain/usecases/cart/clear_cart_use_case.dart';

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
  const CartLoaded(this.cart);
  @override
  List<Object?> get props => [cart];
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

  CartBloc({
    required this.getCartUseCase,
    required this.addItemToCartUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<LoadCartRequested>(_onLoadCart);
    on<AddToCartRequested>(_onAddToCart);
    on<ClearCartRequested>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await getCartUseCase.execute();
    result.fold(
      (failure) => emit(CartFailure(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onAddToCart(AddToCartRequested event, Emitter<CartState> emit) async {
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

  Future<void> _onClearCart(ClearCartRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await clearCartUseCase.execute();
    result.fold(
      (failure) => emit(CartFailure(failure.message)),
      (_) => emit(const CartLoaded(Cart(items: [], totalAmount: 0.0))),
    );
  }
}
