import 'package:flutter/material.dart';
import '../feedback/offline_banner.dart';

/// Thin wrapper around [Scaffold] that always mounts [OfflineBanner]
/// above the body. Use this instead of raw `Scaffold` for any
/// full-screen route so offline handling is automatic rather than
/// something each screen has to remember to add.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: <Widget>[
          const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
    );
  }
}
