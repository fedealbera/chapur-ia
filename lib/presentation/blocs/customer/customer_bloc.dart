import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/customers/customer_use_cases.dart';

// --- Events ---
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class SearchCustomersRequested extends CustomerEvent {
  final String term;
  final bool reset;

  const SearchCustomersRequested({
    required this.term,
    this.reset = false,
  });

  @override
  List<Object?> get props => [term, reset];
}

class SelectCustomerRequested extends CustomerEvent {
  final String accountNumber;
  const SelectCustomerRequested(this.accountNumber);
  @override
  List<Object?> get props => [accountNumber];
}

// --- States ---
abstract class CustomerState extends Equatable {
  const CustomerState();
  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerListLoaded extends CustomerState {
  final List<Customer> customers;
  final bool hasReachedMax;

  const CustomerListLoaded({
    required this.customers,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [customers, hasReachedMax];
}

class CustomerSelected extends CustomerState {
  final Customer customer;
  const CustomerSelected(this.customer);
  @override
  List<Object?> get props => [customer];
}

class CustomerFailure extends CustomerState {
  final String message;
  const CustomerFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final SearchCustomersUseCase searchCustomersUseCase;
  final GetCustomerDetailUseCase getCustomerDetailUseCase;

  int _currentPage = 1;
  static const int _pageSize = 15;

  CustomerBloc({
    required this.searchCustomersUseCase,
    required this.getCustomerDetailUseCase,
  }) : super(CustomerInitial()) {
    on<SearchCustomersRequested>(_onSearchCustomers);
    on<SelectCustomerRequested>(_onSelectCustomer);
  }

  Future<void> _onSearchCustomers(
    SearchCustomersRequested event,
    Emitter<CustomerState> emit,
  ) async {
    if (event.term.length < 2) return;

    if (event.reset) {
      _currentPage = 1;
      emit(CustomerLoading());
    }

    final currentState = state;
    List<Customer> oldCustomers = [];
    if (currentState is CustomerListLoaded && !event.reset) {
      oldCustomers = currentState.customers;
    }

    final result = await searchCustomersUseCase.execute(
      term: event.term,
      page: _currentPage,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) => emit(CustomerFailure(failure.message)),
      (newCustomers) {
        _currentPage++;
        emit(CustomerListLoaded(
          customers: oldCustomers + newCustomers,
          hasReachedMax: newCustomers.length < _pageSize,
        ));
      },
    );
  }

  Future<void> _onSelectCustomer(
    SelectCustomerRequested event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await getCustomerDetailUseCase.execute(event.accountNumber);

    result.fold(
      (failure) => emit(CustomerFailure(failure.message)),
      (customer) => emit(CustomerSelected(customer)),
    );
  }
}
