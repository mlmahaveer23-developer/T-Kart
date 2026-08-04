import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/address.dart';
import '../controllers/address_controller.dart';

const List<String> _addressLabels = <String>['Home', 'Work', 'Other'];

class AddressFormScreen extends ConsumerStatefulWidget {
  const AddressFormScreen({super.key, this.existing});

  /// Null when adding a new address; populated when editing one.
  final Address? existing;

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late String _label;
  late bool _isDefault;
  bool _isSaving = false;

  final Map<String, String?> _errors = <String, String?>{};

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final Address? existing = widget.existing;
    _name = TextEditingController(text: existing?.recipientName ?? '');
    _phone = TextEditingController(text: existing?.phone ?? '');
    _line1 = TextEditingController(text: existing?.line1 ?? '');
    _line2 = TextEditingController(text: existing?.line2 ?? '');
    _city = TextEditingController(text: existing?.city ?? '');
    _state = TextEditingController(text: existing?.state ?? '');
    _pincode = TextEditingController(text: existing?.pincode ?? '');
    _label = existing?.label ?? _addressLabels.first;
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final TextEditingController c
        in <TextEditingController>[_name, _phone, _line1, _line2, _city, _state, _pincode]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _errors
        ..clear()
        ..addAll(<String, String?>{
          'name': Validators.notEmpty(_name.text, field: 'Name'),
          'phone': Validators.indianPhone(_phone.text),
          'line1': Validators.notEmpty(_line1.text, field: 'Address line'),
          'city': Validators.notEmpty(_city.text, field: 'City'),
          'state': Validators.notEmpty(_state.text, field: 'State'),
          'pincode': Validators.pincode(_pincode.text),
        });
    });
    return _errors.values.every((String? e) => e == null);
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSaving = true);

    final Address address = Address(
      id: widget.existing?.id ?? '',
      label: _label,
      recipientName: _name.text.trim(),
      phone: _phone.text.trim(),
      line1: _line1.text.trim(),
      line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      pincode: _pincode.text.trim(),
      isDefault: _isDefault,
    );

    final AddressController controller = ref.read(addressControllerProvider.notifier);
    final bool success = _isEditing
        ? await controller.updateAddress(address)
        : await controller.addAddress(address);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.pop();
    } else {
      final Object? error = ref.read(addressControllerProvider).error;
      AppSnackbar.error(
        context,
        error is Failure ? error.message : 'Could not save address.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Address' : 'Add Address')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.sm,
              children: _addressLabels
                  .map((String label) => ChoiceChip(
                        label: Text(label),
                        selected: _label == label,
                        onSelected: (_) => setState(() => _label = label),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Recipient name',
              controller: _name,
              errorText: _errors['name'],
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Phone number',
              controller: _phone,
              errorText: _errors['phone'],
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_android_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Address line 1',
              controller: _line1,
              errorText: _errors['line1'],
              hintText: 'House no., street, area',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Address line 2 (optional)',
              controller: _line2,
              hintText: 'Landmark, apartment, etc.',
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: 'City',
                    controller: _city,
                    errorText: _errors['city'],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'State',
                    controller: _state,
                    errorText: _errors['state'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Pincode',
              controller: _pincode,
              errorText: _errors['pincode'],
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Set as default address'),
              value: _isDefault,
              onChanged: (bool value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _isEditing ? 'Save Changes' : 'Add Address',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
