import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/services_remote_datasource.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/models/service_model.dart';
import '../../domain/repositories/services_repository.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl(ServicesRemoteDatasource());
});

final servicesProvider =
    AsyncNotifierProvider<ServicesController, List<ServiceModel>>(
        ServicesController.new);

class ServicesController extends AsyncNotifier<List<ServiceModel>> {
  @override
  Future<List<ServiceModel>> build() {
    return ref.read(servicesRepositoryProvider).getServices();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(servicesRepositoryProvider).getServices());
  }

  Future<void> addService(ServiceModel service) async {
    await ref.read(servicesRepositoryProvider).addService(service);
    await refresh();
  }

  Future<void> updateService(ServiceModel service) async {
    await ref.read(servicesRepositoryProvider).updateService(service);
    await refresh();
  }

  Future<void> deleteService(String id) async {
    await ref.read(servicesRepositoryProvider).deleteService(id);
    await refresh();
  }
}
