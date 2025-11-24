import 'package:dartz/dartz.dart';
import '../../../../core/network/models/network_failure.dart';
import '../../data/models/earthquake_model.dart';

abstract class EarthquakeRepository {
  Future<Either<NetworkFailure, List<EarthquakeModel>>> getRecentEarthquakes();
  Future<Either<NetworkFailure, List<EarthquakeModel>>>
  getSignificantEarthquakes();
  Future<Either<NetworkFailure, List<EarthquakeModel>>>
  getAllMonthEarthquakes();
}
