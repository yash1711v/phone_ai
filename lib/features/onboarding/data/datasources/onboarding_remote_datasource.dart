import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/business_search_result.dart';
import '../models/business_website_data.dart';

/// Remote data source for onboarding: business search, website analysis, create-quick-bot.
abstract class OnboardingRemoteDataSource {
  /// Search businesses via Google Places. Returns up to 5 results.
  Future<List<BusinessSearchResult>> searchBusiness({
    required String textQuery,
    double? latitude,
    double? longitude,
  });

  /// Analyze a website URL and return structured business info.
  Future<BusinessWebsiteData> analyzeWebsite(String websiteUrl);

  /// Create voice bot from business info and voice config.
  Future<Map<String, dynamic>> createQuickBot({
    required String businessName,
    required String voiceProvider,
    required String voice,
    required String voiceModel,
    String? phoneNumber,
    String? address,
    String? summary,
    List<String>? services,
    String? website,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<BusinessSearchResult>> searchBusiness({
    required String textQuery,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'textQuery': textQuery.trim(),
    };
    if (latitude != null && longitude != null) {
      body['location'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    final response = await _apiClient.post<List<BusinessSearchResult>>(
      ApiConstants.businessSearch,
      data: body,
      fromJson: (d) {
        if (d == null) return <BusinessSearchResult>[];
        final list = d is List ? d : (d as Map)['data'] as List? ?? [];
        return list
            .map((e) =>
                BusinessSearchResult.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (!response.success || response.data == null) {
      throw ServerException(
        response.message ?? 'Failed to search businesses',
      );
    }
    return response.data!;
  }

  @override
  Future<BusinessWebsiteData> analyzeWebsite(String websiteUrl) async {
    final url = websiteUrl.trim();
    final normalizedUrl = url.startsWith('http') ? url : 'https://$url';
    final response = await _apiClient.post<BusinessWebsiteData>(
      ApiConstants.businessWebsite,
      data: {'websiteUrl': normalizedUrl},
      fromJson: (d) => BusinessWebsiteData.fromJson(d as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ServerException(
        response.message ?? 'Failed to analyze website',
      );
    }
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> createQuickBot({
    required String businessName,
    required String voiceProvider,
    required String voice,
    required String voiceModel,
    String? phoneNumber,
    String? address,
    String? summary,
    List<String>? services,
    String? website,
  }) async {
    final body = <String, dynamic>{
      'businessName': businessName.trim(),
      'voiceProvider': voiceProvider,
      'voice': voice,
      'voiceModel': voiceModel,
    };
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }
    if (address != null && address.isNotEmpty) {
      body['address'] = address;
    }
    if (summary != null && summary.isNotEmpty) {
      body['summary'] = summary;
    }
    if (services != null) {
      body['services'] = services;
    }
    if (website != null && website.isNotEmpty) {
      body['website'] = website;
    }
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.botCreateQuickBot,
      data: body,
      fromJson: (d) => d as Map<String, dynamic>? ?? {},
    );
    if (!response.success) {
      throw ServerException(
        response.message ?? 'Failed to create bot',
      );
    }
    return response.data ?? {};
  }
}
