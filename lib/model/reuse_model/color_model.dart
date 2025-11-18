import 'package:flutter/material.dart';

enum BgColor{
  Bg1(
    color_code : Color(0xFFD9F8FF)
  ),
  Bg2(
    // color_code : Color.fromARGB(255, 0, 24, 42)
    color_code : Color(0xFF122125)
  ),
  Bg2Gradient(
    color_code : Color.fromARGB(255, 46, 93, 107)
  ),
  BottomNav_bg(
    color_code : Color(0xFF002844)
  ),
  Bg1_dark(
    color_code : Color.fromARGB(255, 197, 244, 255)
  ),
  Bg1_dark2(
    color_code : Color.fromARGB(255, 122, 231, 255)
  );

  const BgColor({required this.color_code});
  final Color color_code;
}
