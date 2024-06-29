import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String text;
  final double width;

  const HeaderText({Key? key, required this.text, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.left, softWrap: false),
          ],
        ),
      ),
    );
  }
}
