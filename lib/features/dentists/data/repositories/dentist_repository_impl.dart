import '../../domain/models/dentist_model.dart';
import '../../domain/repositories/dentist_repository.dart';
import '../datasources/dentist_remote_datasource.dart';

class DentistRepositoryImpl implements DentistRepository {
  DentistRepositoryImpl(this._datasource);

  final DentistRemoteDatasource _datasource;

  @override
  Future<List<DentistModel>> getDentists({
    int limit = 10,
    DentistModel? lastDentist,
    String? specialization,
    String? searchQuery,
  }) =>
      _datasource.getDentists(
        limit: limit,
        specialization: specialization,
        searchQuery: searchQuery,
      );

  @override
  Future<DentistModel> getDentistById(String id) => _datasource.getDentistById(id);

  @override
  Future<List<DentistModel>> getFeaturedDentists(int count) =>
      _datasource.getFeaturedDentists(count);

  @override
  Future<List<String>> getSpecializations() => _datasource.getSpecializations();

  @override
  Future<String> addDentist(DentistModel dentist) => _datasource.addDentist(dentist);

  @override
  Future<void> updateDentist(DentistModel dentist) => _datasource.updateDentist(dentist);

  @override
  Future<void> deleteDentist(String id) => _datasource.deleteDentist(id);

  @override
  Future<void> updateDentistRating(String id, double rating, int totalReviews) =>
      _datasource.updateDentistRating(id, rating, totalReviews);
}
