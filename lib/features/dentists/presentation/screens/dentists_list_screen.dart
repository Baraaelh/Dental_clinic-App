import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../controllers/dentist_controller.dart';
import '../widgets/dentist_card.dart';
import '../widgets/specialization_filter.dart';
import '../../../../core/errors/error_messages.dart';

class DentistsListScreen extends ConsumerStatefulWidget {
  const DentistsListScreen({super.key});

  @override
  ConsumerState<DentistsListScreen> createState() => _DentistsListScreenState();
}

class _DentistsListScreenState extends ConsumerState<DentistsListScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedSpecialization = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dentistsAsync = ref.watch(dentistListProvider);
    final specializationsAsync = ref.watch(specializationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dentists)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              label: '',
              hint: l10n.searchDentists,
              controller: _searchCtrl,
              prefixIcon: const Icon(Icons.search),
              onChanged: (query) {
                ref.read(dentistListProvider.notifier).search(query);
              },
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref.read(dentistListProvider.notifier).search('');
                      },
                    )
                  : null,
            ),
          ),
          specializationsAsync.when(
            data: (specs) => SpecializationFilter(
              specializations: specs,
              selected: _selectedSpecialization,
              onSelected: (spec) {
                setState(() => _selectedSpecialization = spec);
                ref
                    .read(dentistListProvider.notifier)
                    .filterBySpecialization(spec);
              },
            ),
            loading: () => const SizedBox(height: 44),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(dentistListProvider.notifier).refresh(),
              child: dentistsAsync.when(
                data: (dentists) {
                  if (dentists.isEmpty) {
                    return EmptyStateWidget(
                      message: _selectedSpecialization.isEmpty
                          ? l10n.noDentists
                          : l10n.noDentistsForFilter,
                      icon: Icons.people_outline,
                    );
                  }
                  return ListView.builder(
                    itemCount: dentists.length,
                    itemBuilder: (context, index) =>
                        DentistCard(dentist: dentists[index]),
                  );
                },
                loading: () => ListView.builder(
                  itemCount: 6,
                  itemBuilder: (_, __) => const ShimmerDentistCard(),
                ),
                error: (e, _) => AppErrorWidget(
                  message: context.errorMessage(e),
                  onRetry: () =>
                      ref.read(dentistListProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
