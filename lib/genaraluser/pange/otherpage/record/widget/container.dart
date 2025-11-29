

import 'package:flutter/material.dart';

class RecordContainer extends StatelessWidget {
  const RecordContainer({super.key, required this.icon, required this.title, required this.subtitle, required this.size,required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final double size;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    List<Color> textandbg = [Color.fromARGB(255, 84, 141, 172),Color.fromARGB(255, 138, 190, 218)];
    return Flexible(
        flex: 1,
        child: FilledButton(
          onPressed: () {
            onTap();
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(textandbg[1]),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 50)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            minimumSize: WidgetStateProperty.all(Size(double.infinity, 0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                child: Icon(icon,color: textandbg[0],size: size),
              ),
              Text(title,style: TextStyle(color: textandbg[0],fontSize: 30 ,fontWeight: FontWeight.bold),),
              Text(subtitle,style: TextStyle(color: textandbg[0],fontSize: 22,fontWeight: FontWeight.w600),),
            ],
          ),
        ),
      );
  }
}