import 'package:equatable/equatable.dart';

import 'business_search_result.dart';
import 'business_website_data.dart';

/// Unified editable business data for Review & Edit screen and create-quick-bot.
class EditableBusinessData extends Equatable {
  final String businessName;
  final String? phoneNumber;
  final String? address;
  final String? summary;
  final List<String> services;
  final String? website;

  const EditableBusinessData({
    required this.businessName,
    this.phoneNumber,
    this.address,
    this.summary,
    this.services = const [],
    this.website,
  });

  factory EditableBusinessData.fromSearchResult(BusinessSearchResult r) {
    return EditableBusinessData(
      businessName: r.businessName,
      phoneNumber: r.phoneNumber,
      address: r.address,
      summary: r.summary,
      services: List.from(r.services),
      website: r.website,
    );
  }

  factory EditableBusinessData.fromWebsiteData(BusinessWebsiteData d) {
    return EditableBusinessData(
      businessName: d.businessName ?? '',
      phoneNumber: d.phoneNumber,
      address: d.addr,
      summary: d.summary,
      services: List.from(d.services),
      website: null,
    );
  }

  EditableBusinessData copyWith({
    String? businessName,
    String? phoneNumber,
    String? address,
    String? summary,
    List<String>? services,
    String? website,
  }) {
    return EditableBusinessData(
      businessName: businessName ?? this.businessName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      summary: summary ?? this.summary,
      services: services ?? List.from(this.services),
      website: website ?? this.website,
    );
  }

  @override
  List<Object?> get props => [businessName, phoneNumber, address, summary, services, website];
}
