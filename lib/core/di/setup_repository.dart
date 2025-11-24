import 'package:get/get.dart';
import '../../features/earthquake/data/repositories/earthquake_repository_impl.dart';
import '../../features/earthquake/data/sources/earthquake_api.dart';
import '../../features/earthquake/domain/repositories/earthquake_repository.dart';

void setupRepository() {
  Get.lazyPut<ApiService>(() => ApiService());
  Get.lazyPut<EarthquakeRepository>(() => EarthquakeRepositoryImpl(Get.find()));
}
