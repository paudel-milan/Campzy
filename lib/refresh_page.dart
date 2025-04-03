import 'package:flutter/material.dart';

class RefreshPage extends StatefulWidget {
  final Widget child; // The page content
  final Future<void> Function() onRefresh; // Function to refresh data

  const RefreshPage({Key? key, required this.child, required this.onRefresh})
      : super(key: key);

  @override
  _RefreshPageState createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}
