import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/address.dart';
import '../controllers/address_controller.dart';
import '../widgets/address_card.dart';

/// Manage-addresses screen (Profile → Addresses). Selecting an address
/// for checkout happens on [CheckoutScreen] itself via the same
/// `addressControllerProvider` state, not here.
class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Address>> addressesAsync =
        ref.watch(addressControllerProvider);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Your Addresses'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add address',
            onPressed: () => context.push(RouteNames.addressForm),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: addressesAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) => const SkeletonListTile(),
        ),
        error: (Object error, StackTrace stackTrace) => ErrorStateWidget(
          failure: error is Failure ? error : const UnexpectedFailure(),
          onRetry: () => ref.invalidate(addressControllerProvider),
        ),
        data: (List<Address> addresses) {
          if (addresses.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.location_on_outlined,
              title: 'No saved addresses',
              message: 'Add an address to speed up checkout.',
              actionLabel: 'Add address',
              onAction: () => context.push(RouteNames.addressForm),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final Address address = addresses[index];
              return AddressCard(
                address: address,
                selected: address.isDefault,
                onTap: () => context.push(RouteNames.addressForm, extra: address),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (String action) async {
                    final AddressController controller =
                        ref.read(addressControllerProvider.notifier);
                    switch (action) {
                      case 'default':
                        await controller.setDefault(address.id);
                      case 'edit':
                        if (context.mounted) {
                          context.push(RouteNames.addressForm, extra: address);
                        }
                      case 'delete':
                        await controller.deleteAddress(address.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    if (!address.isDefault)
                      const PopupMenuItem<String>(
                        value: 'default',
                        child: Text('Set as default'),
                      ),
                    const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
