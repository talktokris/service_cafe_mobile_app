import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class FilterDropdownOption {
  const FilterDropdownOption({required this.value, required this.label});

  final String value;
  final String label;
}

class DateFilterBar extends StatelessWidget {
  const DateFilterBar({
    super.key,
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSearch,
    required this.onReset,
    this.textField,
    this.textFieldLabel,
    this.dropdownValue,
    this.dropdownLabel,
    this.dropdownOptions,
    this.onDropdownChanged,
    this.title = 'Filters',
    this.compact = false,
  });

  final DateTime? from;
  final DateTime? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSearch;
  final VoidCallback onReset;
  final TextEditingController? textField;
  final String? textFieldLabel;
  final String? dropdownValue;
  final String? dropdownLabel;
  final List<FilterDropdownOption>? dropdownOptions;
  final ValueChanged<String?>? onDropdownChanged;
  final String title;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yy');
    final pad = compact ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: AppDecorations.premiumCard(
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.filter_list_rounded, size: compact ? 16 : 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          if (textField != null) ...[
            TextField(
              controller: textField,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: textFieldLabel,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            SizedBox(height: compact ? 8 : 12),
          ],
          Row(
            children: [
              Expanded(
                child: _DatePill(
                  compact: compact,
                  label: 'From',
                  value: from != null ? dateFmt.format(from!) : 'Select',
                  onTap: onPickFrom,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted.withValues(alpha: 0.6)),
              ),
              Expanded(
                child: _DatePill(
                  compact: compact,
                  label: 'To',
                  value: to != null ? dateFmt.format(to!) : 'Select',
                  onTap: onPickTo,
                ),
              ),
            ],
          ),
          if (dropdownOptions != null && onDropdownChanged != null) ...[
            SizedBox(height: compact ? 8 : 12),
            DropdownButtonFormField<String>(
              initialValue: dropdownValue?.isEmpty == true ? '' : dropdownValue,
              isDense: true,
              decoration: InputDecoration(
                labelText: dropdownLabel ?? 'Type',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 12),
              ),
              items: dropdownOptions!
                  .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: onDropdownChanged,
            ),
          ],
          SizedBox(height: compact ? 10 : 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _GradientButton(label: 'Search', onTap: onSearch, compact: compact),
              ),
              SizedBox(width: compact ? 8 : 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text('Reset', style: TextStyle(fontSize: compact ? 13 : 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap, this.compact = false});

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: AppColors.gradient,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 10 : 12),
            child: Center(
              child: Text(
                label,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: compact ? 13 : 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.label,
    required this.value,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 8 : 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.calendar_today_rounded, size: compact ? 12 : 14, color: AppColors.accent),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: compact ? 9 : 10, color: AppColors.textMuted)),
                    Text(
                      value,
                      style: TextStyle(fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
