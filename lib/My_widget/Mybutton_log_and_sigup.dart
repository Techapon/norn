import 'package:flutter/material.dart';

class LogAndSignButton extends StatelessWidget {

  final String text;
  final VoidCallback? onpressed;
  
  const LogAndSignButton({
    super.key,
    required this.text,
    required this.onpressed
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Color(0xFF4E87C8),
              overlayColor: Color(0xFF386393),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(20)
              )
            ),
            onPressed: onpressed,
            child: Text(
              text,
              style: TextStyle(fontSize: 23,fontWeight: FontWeight.normal,height: 2.3),
            )
          ),
        ),
      ],
    );
  }
}