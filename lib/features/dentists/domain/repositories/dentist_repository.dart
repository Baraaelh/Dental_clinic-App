import '../models/dentist_model.dart';

abstract class DentistRepository {
  Future<List<DentistModel>> getDentists({
    int limit = 10,
    DentistModel? lastDentist,
    String? specialization,
    String? searchQuery,
  });

  Future<DentistModel> getDentistById(String id);

  Future<List<DentistModel>> getFeaturedDentists(int count);

  Future<List<String>> getSpecializations();

  Future<String> addDentist(DentistModel dentist);

  Future<void> updateDentist(DentistModel dentist);

  Future<void> deleteDentist(String id);

  Future<void> updateDentistRating(String id, double rating, int totalReviews);
}
