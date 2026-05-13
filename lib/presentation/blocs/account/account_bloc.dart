import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/account_summary.dart';
import '../../../domain/usecases/account/account_use_cases.dart';

// --- Events ---
abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object?> get props => [];
}

class FetchAccountSummaryRequested extends AccountEvent {
  final String accountNumber;
  final DateTime startDate;
  final DateTime endDate;
  final int soloPendientes;

  const FetchAccountSummaryRequested({
    required this.accountNumber,
    required this.startDate,
    required this.endDate,
    this.soloPendientes = 0,
  });

  @override
  List<Object?> get props => [accountNumber, startDate, endDate, soloPendientes];
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

class DownloadDocumentPdfRequested extends AccountEvent {
  final String documentCode;
  final int documentNumber;

  const DownloadDocumentPdfRequested({
    required this.documentCode,
    required this.documentNumber,
  });

  @override
  List<Object?> get props => [documentCode, documentNumber];
}

// --- States ---
abstract class AccountState extends Equatable {
  final AccountSummary? summary;
  const AccountState({this.summary});
  
  @override
  List<Object?> get props => [summary];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {
  const AccountLoading({super.summary});
}

class AccountSummaryLoaded extends AccountState {
  const AccountSummaryLoaded(AccountSummary summary) : super(summary: summary);
  
  @override
  List<Object?> get props => [summary];
}

class DocumentDetailLoaded extends AccountState {
  final Map<String, dynamic> detail;
  const DocumentDetailLoaded(this.detail, {super.summary});
  
  @override
  List<Object?> get props => [detail, summary];
}

class DocumentPdfLoaded extends AccountState {
  final String filePath;
  const DocumentPdfLoaded(this.filePath, {super.summary});
  
  @override
  List<Object?> get props => [filePath, summary];
}

class AccountFailure extends AccountState {
  final String message;
  const AccountFailure(this.message, {super.summary});
  
  @override
  List<Object?> get props => [message, summary];
}

// --- BLoC ---
class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountSummaryUseCase getAccountSummaryUseCase;
  final GetDocumentDetailUseCase getDocumentDetailUseCase;
  final GetDocumentPdfUseCase getDocumentPdfUseCase;

  AccountBloc({
    required this.getAccountSummaryUseCase,
    required this.getDocumentDetailUseCase,
    required this.getDocumentPdfUseCase,
  }) : super(AccountInitial()) {
    on<FetchAccountSummaryRequested>(_onFetchSummary);
    on<FetchDocumentDetailRequested>(_onFetchDetail);
    on<DownloadDocumentPdfRequested>(_onDownloadPdf);
  }

  Future<void> _onFetchSummary(
    FetchAccountSummaryRequested event,
    Emitter<AccountState> emit,
  ) async {
    // Para el resumen, si ya tenemos uno, lo mantenemos mientras carga el nuevo
    emit(AccountLoading(summary: state.summary));
    final result = await getAccountSummaryUseCase.execute(
      accountNumber: event.accountNumber,
      startDate: event.startDate,
      endDate: event.endDate,
      soloPendientes: event.soloPendientes,
    );

    result.fold(
      (failure) => emit(AccountFailure(failure.message, summary: state.summary)),
      (summary) => emit(AccountSummaryLoaded(summary)),
    );
  }

  Future<void> _onFetchDetail(
    FetchDocumentDetailRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading(summary: state.summary));
    final result = await getDocumentDetailUseCase.execute(
      documentCode: event.documentCode,
      documentNumber: event.documentNumber,
    );

    result.fold(
      (failure) => emit(AccountFailure(failure.message, summary: state.summary)),
      (detail) => emit(DocumentDetailLoaded(detail, summary: state.summary)),
    );
  }

  Future<void> _onDownloadPdf(
    DownloadDocumentPdfRequested event,
    Emitter<AccountState> emit,
  ) async {
    // No queremos que la lista desaparezca al descargar, así que pasamos el summary actual
    emit(AccountLoading(summary: state.summary));
    final result = await getDocumentPdfUseCase.execute(
      documentCode: event.documentCode,
      documentNumber: event.documentNumber,
    );

    result.fold(
      (failure) => emit(AccountFailure(failure.message, summary: state.summary)),
      (path) => emit(DocumentPdfLoaded(path, summary: state.summary)),
    );
  }
}
