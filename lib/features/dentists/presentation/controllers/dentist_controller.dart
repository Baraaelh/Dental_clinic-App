import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/dentist_remote_datasource.dart';
import '../../data/repositories/dentist_repository_impl.dart';
import '../../domain/models/dentist_model.dart';
import '../../domain/repositories/dentist_repository.dart';

final dentistRepositoryProvider = Provider<DentistRepository>((ref) {
  return DentistRepositoryImpl(DentistRemoteDatasource());
});

final dentistListProvider =
    AsyncNotifierProvider<DentistListController, List<DentistModel>>(
        DentistListController.new);

/// Loads every dentist once, then searches and filters in memory.
/// A clinic has a small number of dentists, so this avoids a Firestore
/// query per keystroke and makes search cover all of them (the old
/// version only searched the first page of 10).
class DentistListController extends AsyncNotifier<List<DentistModel>> {
  static const _maxDentists = 200;

  List<DentistModel> _all = const [];
  String _searchQuery = '';
  String _specialization = '';

  @override
  Future<List<DentistModel>> build() async {
    _all = await ref
        .read(dentistRepositoryProvider)
        .getDentists(limit: _maxDentists);
    return _applyFilters();
  }

  List<DentistModel> _applyFilters() {
    final q = _searchQuery.trim().toLowerCase();
    return _all.where((d) {
      if (_specialization.isNotEmpty && d.specialization != _specialization) {
        return false;
      }
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) ||
          d.specialization.toLowerCase().contains(q);
    }).toList();
  }

  void search(String query) {
    _searchQuery = query;
    if (state.hasValue) state = AsyncData(_applyFilters());
  }

  void filterBySpecialization(String specialization) {
    _specialization = specialization;
    if (state.hasValue) state = AsyncData(_applyFilters());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final dentistDetailProvider = AsyncNotifierProviderFamily<DentistDetailController,
    DentistModel, String>(DentistDetailController.new);

class DentistDetailController
    extends FamilyAsyncNotifier<DentistModel, String> {
  @override
  Future<DentistModel> build(String arg) {
    return ref.read(dentistRepositoryProvider).getDentistById(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
        ref.read(dentistRepositoryProvider).getDentistById(arg));
  }
}

final featuredDentistsProvider = FutureProvider<List<DentistModel>>((ref) {
  return ref
      .read(dentistRepositoryProvider)
      .getFeaturedDentists(AppConstants.featuredDentistsCount);
});

final specializationsProvider = FutureProvider<List<String>>((ref) {
  return ref.read(dentistRepositoryProvider).getSpecializations();
});
