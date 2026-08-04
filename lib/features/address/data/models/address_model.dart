import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.label,
    required super.recipientName,
    required super.phone,
    required super.line1,
    required super.city,
    required super.state,
    required super.pincode,
    required super.isDefault,
    super.line2,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: (json['label'] as String?) ?? 'Home',
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      isDefault: (json['is_default'] as bool?) ?? false,
    );
  }

  factory AddressModel.fromEntity(Address address) {
    return AddressModel(
      id: address.id,
      label: address.label,
      recipientName: address.recipientName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      isDefault: address.isDefault,
    );
  }

  /// Excludes `id` — used for inserts, where Supabase generates the id.
  Map<String, dynamic> toInsertJson(String userId) => <String, dynamic>{
        'user_id': userId,
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      };

  Map<String, dynamic> toUpdateJson() => <String, dynamic>{
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      };
}
