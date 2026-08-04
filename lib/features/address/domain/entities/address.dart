import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.line1,
    required this.city,
    required this.state,
    required this.pincode,
    required this.isDefault,
    this.line2,
  });

  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  String get formatted =>
      '$line1${line2 == null || line2!.isEmpty ? '' : ', $line2'}, $city, $state $pincode';

  @override
  List<Object?> get props => <Object?>[
        id,
        label,
        recipientName,
        phone,
        line1,
        line2,
        city,
        state,
        pincode,
        isDefault,
      ];
}
