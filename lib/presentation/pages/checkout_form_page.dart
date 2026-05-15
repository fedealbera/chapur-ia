import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/cart/cart_bloc.dart';

class CheckoutFormPage extends StatefulWidget {
  const CheckoutFormPage({super.key});

  @override
  State<CheckoutFormPage> createState() => _CheckoutFormPageState();
}

class _CheckoutFormPageState extends State<CheckoutFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBloc>().add(FetchDeliveryDefaultsRequested());
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<OrderBloc>().add(
          SubmitOrderRequested(
            deliveryAddress: _addressCtrl.text.trim(),
            deliveryContact: _contactCtrl.text.trim(),
            deliveryPhone: _phoneCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderSuccess) {
          // Reload cart (it should be empty now server-side)
          context.read<CartBloc>().add(LoadCartRequested());
          _showSuccessDialog(state.confirmation.softlandId);
        } else if (state is OrderFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else if (state is DeliveryDefaultsLoaded) {
          final defaults = state.defaults;
          if (_addressCtrl.text.isEmpty) {
            String combinedAddress = defaults.deliveryAddress;
            if (defaults.deliveryPostalCode.isNotEmpty) {
              combinedAddress += '. CP ${defaults.deliveryPostalCode}.';
            }
            _addressCtrl.text = combinedAddress;
          }
          if (_contactCtrl.text.isEmpty && defaults.deliveryContact != null) {
            _contactCtrl.text = defaults.deliveryContact!;
          }
          if (_phoneCtrl.text.isEmpty && defaults.deliveryPhone != null) {
            _phoneCtrl.text = defaults.deliveryPhone!;
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF474747),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              String customerName = '';
              if (state is CartLoaded) {
                customerName = state.cart.customerName ?? '';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nuevo pedido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (customerName.isNotEmpty)
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATOS DE ENVIO',
                          style: TextStyle(
                            color: Color(0xFF818080),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Datos del cliente que se usaran para la entrega',
                                style: TextStyle(
                                  color: Color(0xFF474747),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFieldLabel('CONTACTO DE ENTREGA'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _contactCtrl,
                                hint: 'Nombre de contacto',
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildFieldLabel('DIRECCION DE ENTREGA'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _addressCtrl,
                                hint: 'Calle, Número, Ciudad',
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildFieldLabel('TELEFONO'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _phoneCtrl,
                                hint: 'Número de teléfono',
                                keyboardType: TextInputType.phone,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildFieldLabel('NOTAS ADICIONALES'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _notesCtrl,
                                hint: 'INTRUCCIONES ESPECIALES DE ENTREGA (OPCIONAL)',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // --- Submit Button ---
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  final isLoading = state is OrderLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD61D26),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirmar pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF121212),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD61D26), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  void _showSuccessDialog(String softlandId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF22C55E),
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Pedido confirmado!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tu pedido fue enviado correctamente.\nID: $softlandId',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontFamily: 'Inter'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context)
                    ..pop() // checkout
                    ..pop(); // cart
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD61D26),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    const Text('Volver al inicio', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
