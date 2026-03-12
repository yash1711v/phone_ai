import 'package:equatable/equatable.dart';

/// API v3 account response (createAccount, login)
class AccountModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? firebaseUid;
  final bool verifiedPhoneNumber;
  final bool isDisable;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AccountInOrganizationModel> accountInOrganization;

  const AccountModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.firebaseUid,
    this.verifiedPhoneNumber = false,
    this.isDisable = false,
    this.createdAt,
    this.updatedAt,
    this.accountInOrganization = const [],
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      firebaseUid: json['firebaseUid'] as String?,
      verifiedPhoneNumber: json['verifiedPhoneNumber'] as bool? ?? false,
      isDisable: json['isDisable'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      accountInOrganization: (json['accountInOrganization'] as List<dynamic>?)
              ?.map((e) => AccountInOrganizationModel.fromJson(
                    e as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'firebaseUid': firebaseUid,
      'verifiedPhoneNumber': verifiedPhoneNumber,
      'isDisable': isDisable,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'accountInOrganization':
          accountInOrganization.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phoneNumber,
        firebaseUid,
        verifiedPhoneNumber,
        isDisable,
        createdAt,
        updatedAt,
        accountInOrganization,
      ];
}

class AccountInOrganizationModel extends Equatable {
  final int organizationId;

  const AccountInOrganizationModel({required this.organizationId});

  factory AccountInOrganizationModel.fromJson(Map<String, dynamic> json) {
    return AccountInOrganizationModel(
      organizationId: json['organizationId'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'organizationId': organizationId};

  @override
  List<Object?> get props => [organizationId];
}
