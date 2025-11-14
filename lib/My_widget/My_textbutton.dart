import 'package:flutter/material.dart';

class MyTextbutton extends StatelessWidget {

  final String text;
  final VoidCallback? onpressed;

  const MyTextbutton({
    super.key,
    required this.text,
    required this.onpressed
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        child: Text(
          text,
          style: TextStyle(color: Color(0xFF388BBF),fontWeight: FontWeight.normal,height: 1),
        )
      ),
    );
  }
}