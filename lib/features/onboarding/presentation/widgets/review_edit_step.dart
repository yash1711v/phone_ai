import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/editable_business_data.dart';
import '../../../../shared/widgets/app_button.dart';
import '../cubit/onboarding_cubit.dart';

/// Onboarding step 2: Review and edit business info; editable fields and services (add/remove).
class ReviewEditStep extends StatefulWidget {
  const ReviewEditStep({
    super.key,
    required this.businessData,
    required this.progressLabel,
    required this.onBack,
  });

  final EditableBusinessData businessData;
  final String progressLabel;
  final VoidCallback onBack;

  @override
  State<ReviewEditStep> createState() => _ReviewEditStepState();
}

class _ReviewEditStepState extends State<ReviewEditStep> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _summaryController;
  late List<String> _services;

  @override
  void initState() {
    super.initState();
    final d = widget.businessData;
    _nameController = TextEditingController(text: d.businessName);
    _phoneController = TextEditingController(text: d.phoneNumber ?? '');
    _addressController = TextEditingController(text: d.address ?? '');
    _summaryController = TextEditingController(text: d.summary ?? '');
    _services = List.from(d.services);
  }

  @override
  void didUpdateWidget(ReviewEditStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.businessData != widget.businessData) {
      final d = widget.businessData;
      _nameController.text = d.businessName;
      _phoneController.text = d.phoneNumber ?? '';
      _addressController.text = d.address ?? '';
      _summaryController.text = d.summary ?? '';
      _services = List.from(d.services);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _syncToCubit() {
    context.read<OnboardingCubit>().updateBusiness(
          EditableBusinessData(
            businessName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            summary: _summaryController.text.trim().isEmpty
                ? null
                : _summaryController.text.trim(),
            services: List.from(_services),
            website: context.read<OnboardingCubit>().state.businessData?.website,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onboardingPrimary = Color(0xFF1A365D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: widget.onBack,
              ),
              const Spacer(),
              Text(
                widget.progressLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Review and edit your business info',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onboardingPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps us by providing accurate information to your callers.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                _labeledField(
                  theme: theme,
                  label: 'Business Name',
                  controller: _nameController,
                  onChanged: (_) => _syncToCubit(),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  theme: theme,
                  label: 'Phone Number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _syncToCubit(),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  theme: theme,
                  label: 'Address',
                  controller: _addressController,
                  onChanged: (_) => _syncToCubit(),
                ),
                const SizedBox(height: 16),
                _labeledField(
                  theme: theme,
                  label: 'Summary',
                  controller: _summaryController,
                  maxLines: 4,
                  onChanged: (_) => _syncToCubit(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Core Services',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._services.asMap().entries.map((e) {
                      final i = e.key;
                      final s = e.value;
                      return Chip(
                        label: Text(
                          s.length > 40 ? '${s.substring(0, 40)}...' : s,
                          overflow: TextOverflow.ellipsis,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _services.removeAt(i);
                            _syncToCubit();
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                      );
                    }),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add another'),
                      onPressed: () => _showAddServiceDialog(context, theme),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: AppButton(
            text: 'Continue',
            backgroundColor: onboardingPrimary,
            onPressed: () {
              _syncToCubit();
              context.read<OnboardingCubit>().goToChooseVoice();
            },
          ),
        ),
      ],
    );
  }

  Widget _labeledField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showAddServiceDialog(BuildContext context, ThemeData theme) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add service'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. Emergency plumbing repairs',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _services.add(text);
                  _syncToCubit();
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
