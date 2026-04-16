import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/account/account_use_cases.dart';

// --- Events ---
abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object?> get props => [];
}

class FetchAccountSummaryRequested extends AccountEvent {
  final String accountNumber;
  final DateTime fechaDesde;
  final DateTime fechaHasta;
  final int soloPendientes;

  const FetchAccountSummaryRequested({
    required this.accountNumber,
    required this.fechaDesde,
    required this.fechaHasta,
    this.soloPendientes = 0,
  });

  @override
  List<Object?> get props => [accountNumber, fechaDesde, fechaHasta, soloPendientes];
}

class FetchDocumentDetailRequested extends AccountEvent {
  final String documentCode;
  final int documentNumber;

  const FetchDocumentDetailRequested({
    required this.documentCode,
    required this.documentNumber,
  });

  @override
  List<Object?> get props => [documentCode, documentNumber];
}

// --- States ---
abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountSummaryLoaded extends AccountState {
  final Map<String, dynamic> summary;
  const AccountSummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class DocumentDetailLoaded extends AccountState {
  final Map<String, dynamic> detail;
  const DocumentDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class AccountFailure extends AccountState {
  final String message;
  const AccountFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountSummaryUseCase getAccountSummaryUseCase;
  final GetDocumentDetailUseCase getDocumentDetailUseCase;

  AccountBloc({
    required this.getAccountSummaryUseCase,
    required this.getDocumentDetailUseCase,
  }) : super(AccountInitial()) {
    on<FetchAccountSummaryRequested>(_onFetchSummary);
    on<FetchDocumentDetailRequested>(_onFetchDetail);
  }

  Future<void> _onFetchSummary(
    FetchAccountSummaryRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await getAccountSummaryUseCase.execute(
      accountNumber: event.accountNumber,
      fechaDesde: event.fechaDesde,
      fechaHasta: event.fechaHasta,
      soloPendientes: event.soloPendientes,
    );

    result.fold(
      (failure) => emit(AccountFailure(failure.message)),
      (summary) => emit(AccountSummaryLoaded(summary)),
    );
  }

  Future<void> _onFetchDetail(
    FetchDocumentDetailRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());
    final result = await getDocumentDetailUseCase.execute(
      documentCode: event.documentCode,
      documentNumber: event.documentNumber,
    );

    result.fold(
      (failure) => emit(AccountFailure(failure.message)),
      (detail) => emit(DocumentDetailLoaded(detail)),
    );
  }
}
