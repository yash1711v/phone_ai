import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/editable_business_data.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/custom_tab_bar.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Debounce duration for search-as-you-type.
const _kSearchDebounceMs = 400;

/// Onboarding step 1: Google Business or Website tab; search/analyze then continue.
class BusinessProfileStep extends StatefulWidget {
  const BusinessProfileStep({
    super.key,
    required this.progressLabel,
    required this.onBack,
  });

  final String progressLabel;
  final VoidCallback onBack;

  @override
  State<BusinessProfileStep> createState() => _BusinessProfileStepState();
}

class _BusinessProfileStepState extends State<BusinessProfileStep> {
  final _businessNameController = TextEditingController();
  final _websiteController = TextEditingController();
  int _tabIndex = 0;
  Timer? _debounceTimer;
  /// Index of the result card that is expanded (View more). Null if none.
  int? _expandedResultIndex;

  @override
  void initState() {
    super.initState();
    _businessNameController.addListener(_onBusinessNameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _businessNameController.removeListener(_onBusinessNameChanged);
    _businessNameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _onBusinessNameChanged() {
    _debounceTimer?.cancel();
    final query = _businessNameController.text.trim();
    if (query.isEmpty) {
      context.read<OnboardingCubit>().clearSearchResults();
      return;
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: _kSearchDebounceMs),
      () {
        if (!mounted) return;
        context.read<OnboardingCubit>().searchBusiness(textQuery: query);
      },
    );
  }

  void _onContinue() {
    final cubit = context.read<OnboardingCubit>();
    if (_tabIndex == 0) {
      final query = _businessNameController.text.trim();
      if (query.isEmpty) return;
      cubit.searchBusiness(textQuery: query);
      // No auto-redirect; user must tap a result to go to next step.
    } else {
      cubit.analyzeWebsite(_websiteController.text.trim());
    }
  }

  void _onSelectResult(int index) {
    setState(() => _expandedResultIndex = null);
    context.read<OnboardingCubit>().selectSearchResult(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onboardingPrimary = Color(0xFF1A365D);

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        final searchResults = state.searchResults;
        final hasResults = searchResults.isNotEmpty;

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
                    const SizedBox(height: 8),
                    Text(
                      "Welcome - let's setup our agent. It takes 2 minutes",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onboardingPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We answer your calls and handle messages, so you can focus on your business.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTabBar(
                      tabs: const ['Google Business', 'Website'],
                      initialIndex: _tabIndex,
                      selectedColor: Colors.white,
                      selectedBackgroundColor: onboardingPrimary,
                      unselectedColor: Colors.grey.shade700,
                      backgroundColor: Colors.grey.shade200,
                      onTabChanged: (i) {
                        setState(() {
                          _tabIndex = i;
                          _expandedResultIndex = null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_tabIndex == 0) ...[
                      Text(
                        'Google Business Profile',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _businessNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter business name',
                          border: const OutlineInputBorder(),
                          suffixIcon: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _onContinue(),
                      ),
                      if (hasResults) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Select your business',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...searchResults.asMap().entries.map((e) {
                          final i = e.key;
                          final b = e.value;
                          final isExpanded = _expandedResultIndex == i;
                          return _BusinessResultCard(
                            business: b,
                            isExpanded: isExpanded,
                            onTapViewMore: () {
                              setState(() {
                                _expandedResultIndex =
                                    isExpanded ? null : i;
                              });
                            },
                            onSelect: () => _onSelectResult(i),
                            theme: theme,
                            onboardingPrimary: onboardingPrimary,
                          );
                        }),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        "Why we need this? We only use the details from your Google Business Profile once to learn about your hours, services, website, and other key information. Don't worry - this won't affect your profile in any way.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Website Address',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. greentechplumbing.com',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => _onContinue(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Why we need this? We only use the details from your Google Business Profile once to learn about your hours, services, website, and other key information. Don't worry - this won't affect your profile in any way.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                text: 'Continue',
                onPressed: isLoading ? null : _onContinue,
                isLoading: isLoading,
                backgroundColor: onboardingPrimary,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Single search result card with optional expanded "View more" details.
class _BusinessResultCard extends StatelessWidget {
  const _BusinessResultCard({
    required this.business,
    required this.isExpanded,
    required this.onTapViewMore,
    required this.onSelect,
    required this.theme,
    required this.onboardingPrimary,
  });

  final EditableBusinessData business;
  final bool isExpanded;
  final VoidCallback onTapViewMore;
  final VoidCallback onSelect;
  final ThemeData theme;
  final Color onboardingPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  business.businessName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (business.address != null &&
                                    business.address!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    business.address!,
                                    maxLines: isExpanded ? null : 1,
                                    overflow: isExpanded
                                        ? null
                                        : TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (!isExpanded)
                            TextButton(
                              onPressed: onSelect,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: onboardingPrimary,
                              ),
                              child: const Text('Select'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: onTapViewMore,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: onboardingPrimary,
                        ),
                        child: Text(
                          isExpanded ? 'View less' : 'View more',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        _DetailRow(
                          label: 'Phone',
                          value: business.phoneNumber,
                          theme: theme,
                        ),
                        _DetailRow(
                          label: 'Address',
                          value: business.address,
                          theme: theme,
                        ),
                        if (business.website != null &&
                            business.website!.isNotEmpty)
                          _DetailRow(
                            label: 'Website',
                            value: business.website,
                            theme: theme,
                          ),
                        if (business.summary != null &&
                            business.summary!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Summary',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            business.summary!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        if (business.services.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Services',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: business.services
                                .map((s) => Chip(
                                      label: Text(
                                        s,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 0,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onSelect,
                            style: FilledButton.styleFrom(
                              backgroundColor: onboardingPrimary,
                            ),
                            child: const Text('Select this business'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String? value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
