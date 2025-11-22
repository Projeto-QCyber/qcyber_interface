// lib/widgets/dialogs/custom_date_range_picker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zeropoint/_core/my_colors.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  _CustomDateRangePickerState createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now().subtract(const Duration(days: 7));
    _endDate = widget.initialEndDate ?? DateTime.now();
    _updateTextControllers();
  }

  void _updateTextControllers() {
    final format = DateFormat('dd/MM/yyyy');
    _startDateController.text = format.format(_startDate);
    _endDateController.text = format.format(_endDate);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // Garante o calendário em Português
      builder: (context, child) {
        // Reutilizando o tema que já tínhamos para o DatePicker
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MyColors.primary_qcyber,
              onPrimary: MyColors.textOnPrimary_qcyber,
              surface: MyColors.card_qcyber,
              onSurface: MyColors.textPrimary_qcyber,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: MyColors.textOnPrimary_qcyber),
            ),
            dialogBackgroundColor: MyColors.card_qcyber,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
        _updateTextControllers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Period',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MyColors.textOnPrimary_qcyber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDateField('Start Date', _startDateController, () => _selectDate(context, true)),
            const SizedBox(height: 16),
            _buildDateField('End Date', _endDateController, () => _selectDate(context, false)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCELAR', style: TextStyle(color: MyColors.textSecondary_qcyber)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary_qcyber,
                    foregroundColor: MyColors.textOnPrimary_qcyber,
                  ),
                  onPressed: () {
                    // Retorna um DateTimeRange quando o usuário confirma
                    Navigator.of(context).pop(DateTimeRange(start: _startDate, end: _endDate));
                  },
                  child: const Text('APLICAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: const TextStyle(color: MyColors.textPrimary_qcyber),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: MyColors.textSecondary_qcyber),
        suffixIcon: const Icon(Icons.calendar_today, color: MyColors.textSecondary_qcyber, size: 20),
        filled: true,
        fillColor: MyColors.background_qcyber,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MyColors.border_qcyber),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MyColors.border_qcyber),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MyColors.primary_qcyber, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
