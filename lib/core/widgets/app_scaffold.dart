import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  //final AppBar? appBar;
  final Widget? drawer;
  final bool removePadding;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    //this.appBar,
    this.drawer,
    required this.body,
    this.removePadding = false,
    this.floatingActionButton,
    this.appBar,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Color(0xFF3EB655),
      drawer: drawer,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: removePadding ? 0 : 18),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
