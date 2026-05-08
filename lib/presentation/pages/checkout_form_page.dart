import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

  DateTime? _estimatedDeliveryDate;

  static const _primary = Color(0xFF6366F1);
  static const _bgColor = Color(0xFFF8F9FF);

  @override
  void dispose() {
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimatedDeliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _estimatedDeliveryDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dateStr = _estimatedDeliveryDate != null
        ? DateFormat('yyyy-MM-dd').format(_estimatedDeliveryDate!)
        : null;

    context.read<OrderBloc>().add(
          SubmitOrderRequested(
            deliveryAddress: _addressCtrl.text.trim(),
            deliveryContact: _contactCtrl.text.trim(),
            deliveryPhone: _phoneCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            estimatedDeliveryDate: dateStr,
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
          _showSuccessDialog(state.orderId);
        } else if (state is OrderFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Datos de Entrega',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ─── Progress indicator ────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    const _StepIndicator(number: '1', label: 'Carrito', done: true),
                    _StepDivider(),
                    const _StepIndicator(number: '2', label: 'Entrega', active: true),
                    _StepDivider(),
                    const _StepIndicator(number: '3', label: 'Confirmación'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // ─── Form ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Dirección de Entrega'),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _addressCtrl,
                          label: 'Dirección completa',
                          hint: 'Ej: Av. Corrientes 1234, CABA',
                          icon: Icons.location_on_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'La dirección es obligatoria'
                              : null,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        const _SectionTitle('Contacto'),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _contactCtrl,
                          label: 'Persona de contacto',
                          hint: 'Nombre y apellido',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'El contacto es obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _phoneCtrl,
                          label: 'Teléfono',
                          hint: '+54 11 4555-1234',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'El teléfono es obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        const _SectionTitle('Información Adicional'),
                        const SizedBox(height: 12),
                        // Date picker
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                              readOnly: true,
                              decoration: _inputDecoration(
                                label: 'Fecha estimada de entrega',
                                hint: 'Seleccionar fecha (opcional)',
                                icon: Icons.calendar_today_outlined,
                              ).copyWith(
                                suffixIcon: _estimatedDeliveryDate != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () => setState(
                                          () => _estimatedDeliveryDate = null,
                                        ),
                                      )
                                    : null,
                              ),
                              controller: TextEditingController(
                                text: _estimatedDeliveryDate != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_estimatedDeliveryDate!)
                                    : '',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _notesCtrl,
                          label: 'Observaciones',
                          hint: 'Instrucciones especiales, horarios, etc. (opcional)',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 100), // space for FAB
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ─── Submit button ───────────────────────────────────────────────
        bottomNavigationBar: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            final isLoading = state is OrderLoading;
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'CONFIRMAR PEDIDO',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _primary.withValues(alpha: 0.7), size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    );
  }

  void _showSuccessDialog(String orderId) {
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tu pedido fue enviado correctamente.\nID: $orderId',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Close dialog, pop checkout, pop cart → back to catalog
                  Navigator.of(ctx).pop();
                  Navigator.of(context)
                    ..pop() // checkout
                    ..pop(); // cart
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Volver al inicio', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF6366F1),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String number;
  final String label;
  final bool active;
  final bool done;

  const _StepIndicator({
    required this.number,
    required this.label,
    this.active = false,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6366F1);
    final bg = done || active ? primary : Colors.grey.shade200;
    final fg = done || active ? Colors.white : Colors.grey.shade400;
    final labelColor = done || active ? Colors.black87 : Colors.grey.shade400;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    number,
                    style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: Colors.grey.shade200,
      ),
    );
  }
}
