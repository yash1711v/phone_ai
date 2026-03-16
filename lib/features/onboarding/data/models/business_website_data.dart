import 'package:equatable/equatable.dart';

/// Result from POST /business/website (AI analysis). Note: API returns "addr", not "address".
class BusinessWebsiteData extends Equatable {
  final String? businessName;
  final String? phoneNumber;
  final String? addr;
  final String? summary;
  final List<String> services;

  const BusinessWebsiteData({
    this.businessName,
    this.phoneNumber,
    this.addr,
    this.summary,
    this.services = const [],
  });

  factory BusinessWebsiteData.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'];
    final services = servicesRaw is List
        ? (servicesRaw).map((e) => e.toString()).toList()
        : <String>[];
    return BusinessWebsiteData(
      businessName: json['businessName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      addr: json['addr'] as String?,
      summary: json['summary'] as String?,
      services: services,
    );
  }

  @override
  List<Object?> get props => [businessName, phoneNumber, addr, summary, services];
}
