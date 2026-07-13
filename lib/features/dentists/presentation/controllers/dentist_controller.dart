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

class DentistListController extends AsyncNotifier<List<DentistModel>> {
  String _searchQuery = '';
  String _specialization = '';

  @override
  Future<List<DentistModel>> build() => _fetch();

  Future<List<DentistModel>> _fetch() {
    return ref.read(dentistRepositoryProvider).getDentists(
          specialization: _specialization.isEmpty ? null : _specialization,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> filterBySpecialization(String specialization) async {
    _specialization = specialization;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull ?? [];
    try {
      final more = await ref.read(dentistRepositoryProvider).getDentists(
            specialization: _specialization.isEmpty ? null : _specialization,
            searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
            lastDentist: current.isNotEmpty ? current.last : null,
          );
      state = AsyncData([...current, ...more]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
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
