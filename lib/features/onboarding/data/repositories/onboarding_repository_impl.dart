import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/editable_business_entity.dart';
import '../../domain/entities/voice_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_datasource.dart';
import '../models/business_search_result.dart';
import '../models/business_website_data.dart';
import '../models/editable_business_data.dart';

/// Maps [EditableBusinessData] to [EditableBusinessEntity].
EditableBusinessEntity _toEntity(EditableBusinessData d) {
  return EditableBusinessEntity(
    businessName: d.businessName,
    phoneNumber: d.phoneNumber,
    address: d.address,
    summary: d.summary,
    services: List.from(d.services),
    website: d.website,
  );
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._remote);

  final OnboardingRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<EditableBusinessEntity>>> searchBusiness({
    required String textQuery,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final list = await _remote.searchBusiness(
        textQuery: textQuery,
        latitude: latitude,
        longitude: longitude,
      );
      final entities = list
          .map((r) => _toEntity(EditableBusinessData.fromSearchResult(r)))
          .toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EditableBusinessEntity>> analyzeWebsite(
    String websiteUrl,
  ) async {
    try {
      final BusinessWebsiteData data =
          await _remote.analyzeWebsite(websiteUrl);
      final entity =
          _toEntity(EditableBusinessData.fromWebsiteData(data));
      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createQuickBot({
    required EditableBusinessEntity business,
    required VoiceEntity voice,
  }) async {
    try {
      final result = await _remote.createQuickBot(
        businessName: business.businessName,
        voiceProvider: voice.provider,
        voice: voice.id,
        voiceModel: voice.voiceModel,
        phoneNumber: business.phoneNumber,
        address: business.address,
        summary: business.summary,
        services: business.services.isEmpty ? null : business.services,
        website: business.website,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
