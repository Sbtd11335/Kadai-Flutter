import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationCard extends StatelessWidget {

  final double? width;
  final Widget label;
  final Widget child;
  final List<Widget>? actions;

  const NavigationCard({
    super.key,
    this.width,
    required this.label,
    required this.child,
    this.actions
  });

  @override
  Widget build(BuildContext context) {
    final width = this.width ?? MediaQuery.of(context).size.width;
    final textStyle = TextStyle(color: Theme.of(context).colorScheme.onSurface);

    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (builder) {
            return Scaffold(
              appBar: AppBar(
                title: label,
                actions: actions,
              ),
              body: child,
            );
          })
        );
      },
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            label,
            const Spacer(),
            Text(">", style: textStyle)
          ]
        )
      )
    );
  }
}