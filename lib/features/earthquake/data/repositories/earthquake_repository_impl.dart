import 'package:dartz/dartz.dart';

import '../../../../core/network/models/network_failure.dart';
import '../../data/models/earthquake_model.dart';
import '../../data/sources/earthquake_api.dart';
import '../../domain/repositories/earthquake_repository.dart';

class EarthquakeRepositoryImpl implements EarthquakeRepository {
  final ApiService _apiService;

  EarthquakeRepositoryImpl(this._apiService);

  @override
  Future<Either<NetworkFailure, List<EarthquakeModel>>>
  getRecentEarthquakes() async {
    try {
      final result = await _apiService.getRecentEarthquakes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 0));
    }
  }

  @override
  Future<Either<NetworkFailure, List<EarthquakeModel>>>
  getSignificantEarthquakes() async {
    try {
      final result = await _apiService.getSignificantEarthquakes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 0));
    }
  }

  @override
  Future<Either<NetworkFailure, List<EarthquakeModel>>>
  getAllMonthEarthquakes() async {
    try {
      final result = await _apiService.getAllMonthEarthquakes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 0));
    }
  }
}
