import 'package:equatable/equatable.dart';

/// Single business result from POST /business/search (Google Places).
class BusinessSearchResult extends Equatable {
  final String id;
  final String businessName;
  final String? address;
  final String? phoneNumber;
  final String? website;
  final String? summary;
  final List<String> services;
  final String? businessNameAddress;
  final double? rating;
  final int? userRatingCount;
  final String? priceLevel;
  final String? businessStatus;

  const BusinessSearchResult({
    required this.id,
    required this.businessName,
    this.address,
    this.phoneNumber,
    this.website,
    this.summary,
    this.services = const [],
    this.businessNameAddress,
    this.rating,
    this.userRatingCount,
    this.priceLevel,
    this.businessStatus,
  });

  factory BusinessSearchResult.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'];
    final services = servicesRaw is List
        ? (servicesRaw).map((e) => e.toString()).toList()
        : <String>[];
    return BusinessSearchResult(
      id: json['id'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      address: json['address'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      summary: json['summary'] as String?,
      services: services,
      businessNameAddress: json['businessNameAddress'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['userRatingCount'] as int?,
      priceLevel: json['priceLevel'] as String?,
      businessStatus: json['businessStatus'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessName,
        address,
        phoneNumber,
        website,
        summary,
        services,
      ];
}
