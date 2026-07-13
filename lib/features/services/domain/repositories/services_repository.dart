import '../models/service_model.dart';

abstract class ServicesRepository {
  Future<List<ServiceModel>> getServices();
  Future<ServiceModel> getServiceById(String id);
  Future<String> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String id);
}
