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
      // Since ApiService currently throws exceptions or returns List, we need to adapt it.
      // Ideally ApiService should return Either, but for now we wrap it.
      // Wait, I refactored ApiService to use ApiClient which returns Either?
      // Let's check ApiService again.
      return Right(result);
    } catch (e) {
      // If ApiService throws, catch it.
      // But wait, my previous refactor of ApiService might have changed it to return List directly
      // by unwrapping Either inside ApiService.
      // Let's check ApiService content in next step to be sure.
      return Left(ServerFailure(message: e.toString(), statusCode: e.hashCode));
    }
  }

  @override
  Future<Either<NetworkFailure, List<EarthquakeModel>>>
  getSignificantEarthquakes() async {
    try {
      final result = await _apiService.getSignificantEarthquakes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: e.hashCode));
    }
  }
}
