import 'package:equatable/equatable.dart';

/// Domain entity for business info used in review and create-quick-bot.
class EditableBusinessEntity extends Equatable {
  final String businessName;
  final String? phoneNumber;
  final String? address;
  final String? summary;
  final List<String> services;
  final String? website;

  const EditableBusinessEntity({
    required this.businessName,
    this.phoneNumber,
    this.address,
    this.summary,
    this.services = const [],
    this.website,
  });

  @override
  List<Object?> get props =>
      [businessName, phoneNumber, address, summary, services, website];
}
