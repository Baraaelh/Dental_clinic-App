import '../../domain/models/service_model.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl(this._datasource);
  final ServicesRemoteDatasource _datasource;

  @override
  Future<List<ServiceModel>> getServices() => _datasource.getServices();

  @override
  Future<ServiceModel> getServiceById(String id) => _datasource.getServiceById(id);

  @override
  Future<String> addService(ServiceModel service) => _datasource.addService(service);

  @override
  Future<void> updateService(ServiceModel service) => _datasource.updateService(service);

  @override
  Future<void> deleteService(String id) => _datasource.deleteService(id);
}
