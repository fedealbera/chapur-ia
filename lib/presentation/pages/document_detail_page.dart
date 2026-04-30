import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/account/account_bloc.dart';

class DocumentDetailPage extends StatefulWidget {
  final String documentCode;
  final int documentNumber;

  const DocumentDetailPage({
    super.key,
    required this.documentCode,
    required this.documentNumber,
  });

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(FetchDocumentDetailRequested(
          documentCode: widget.documentCode,
          documentNumber: widget.documentNumber,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text('Comprobante ${widget.documentCode}'),
        backgroundColor: const Color(0xFF1A1F2C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              context.read<AccountBloc>().add(DownloadDocumentPdfRequested(
                    documentCode: widget.documentCode,
                    documentNumber: widget.documentNumber,
                  ));
            },
          ),
        ],
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DocumentDetailLoaded) {
            return _buildVoucher(state.detail);
          } else if (state is AccountFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AccountBloc>().add(FetchDocumentDetailRequested(
                            documentCode: widget.documentCode,
                            documentNumber: widget.documentNumber,
                          ));
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildVoucher(Map<String, dynamic> detail) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    final inputDateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final outputDateFormat = DateFormat("dd/MM/yyyy");

    DateTime? moveDate;
    try {
      moveDate = inputDateFormat.parse(detail['movementDate'] ?? '');
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ARCA Style
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail['companyName'] ?? 'CHAPUR S.A.',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(detail['companyAddress'] ?? '', style: const TextStyle(fontSize: 10)),
                        Text('CUIT: ${detail['companyCuit'] ?? ''}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                    ),
                    child: Text(
                      detail['fiscalLetter'] ?? (detail['documentCode'] == 'RC' ? 'X' : 'A'),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getDocumentName(detail['documentCode']),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Nº ${detail['branchCode'] ?? '0001'}-${detail['documentNumber']?.toString().padLeft(8, '0') ?? ''}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Fecha: ${moveDate != null ? outputDateFormat.format(moveDate) : (detail['movementDate']?.toString().split('T').first ?? '')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 2, height: 40),
              
              // Customer section
              _buildSectionTitle('DATOS DEL CLIENTE'),
              const SizedBox(height: 8),
              _buildInfoRow('Razón Social', detail['customerName']),
              _buildInfoRow('CUIT', detail['customerCuit']),
              _buildInfoRow('Domicilio', detail['customerAddress']),
              _buildInfoRow('Cond. IVA', detail['customerTaxCondition']),
              if (detail['paymentCondition'] != null)
                _buildInfoRow('Cond. Vta.', detail['paymentCondition']),
              
              const SizedBox(height: 24),
              
              // Items Table
              _buildSectionTitle('DETALLE'),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(flex: 3, child: Text('Concepto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(child: Text('Importe', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                ],
              ),
              const Divider(),
              ...(detail['items'] as List? ?? []).map((item) {
                final String desc = item['displayDescription'] ?? 
                                   item['productDescription'] ?? 
                                   item['articleDescription'] ?? 
                                   item['resolvedDescription'] ??
                                   item['conceptCode'] ?? 
                                   'Sin descripción';
                final double amount = (item['amountNational'] ?? 0).toDouble();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(desc, style: const TextStyle(fontSize: 12))),
                      Expanded(
                        child: Text(
                          currencyFormat.format(amount),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 32),
              
              // Totals
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal', (detail['subtotal'] ?? 0).toDouble(), currencyFormat),
                      _buildTotalRow('IVA', (detail['ivaAmount'] ?? 0).toDouble(), currencyFormat),
                      const Divider(),
                      _buildTotalRow('TOTAL', (detail['total'] ?? detail['totalAmount'] ?? 0).toDouble(), currencyFormat, isBold: true),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // CAE Section
              if (detail['caeNumber'] != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.qr_code_2, size: 70),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('CAE Nº: ${detail['caeNumber']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('Vto. CAE: ${detail['caeExpiration']}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                const Center(
                  child: Text(
                    'DOCUMENTO NO FISCAL',
                    style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Vendedor: ${detail['sellerName'] ?? 'No asignado'} (${detail['sellerCode'] ?? ''})',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDocumentName(String? code) {
    switch (code) {
      case 'FA': return 'FACTURA';
      case 'RC': return 'RECIBO';
      case 'NC': return 'NOTA DE CRÉDITO';
      case 'ND': return 'NOTA DE DÉBITO';
      default: return 'COMPROBANTE';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: Colors.grey.shade100,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value?.toString() ?? '---', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, NumberFormat format, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            format.format(value),
            style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
