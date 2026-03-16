import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/editable_business_entity.dart';
import '../entities/voice_entity.dart';

/// Repository for onboarding: business search, website analysis, create bot.
abstract class OnboardingRepository {
  /// Search businesses by text query, optionally with location bias.
  Future<Either<Failure, List<EditableBusinessEntity>>> searchBusiness({
    required String textQuery,
    double? latitude,
    double? longitude,
  });

  /// Analyze website URL and return business info.
  Future<Either<Failure, EditableBusinessEntity>> analyzeWebsite(
    String websiteUrl,
  );

  /// Create quick bot with business info and voice. Returns created bot payload.
  Future<Either<Failure, Map<String, dynamic>>> createQuickBot({
    required EditableBusinessEntity business,
    required VoiceEntity voice,
  });
}
