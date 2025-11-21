import 'package:flutter/material.dart';

enum BorderRauisType {
  single(
    border: BorderRadius.all(Radius.circular(10)),
  ),
  top(
    border: BorderRadius.vertical(top: Radius.circular(10)),
  ),
  center(
    border: BorderRadius.zero
  ),
  bottom(
    border: BorderRadius.vertical(bottom: Radius.circular(10)),
  );

  const BorderRauisType({required this.border});
  final BorderRadius border;
}

enum BorderRauishorizonyal {
  left(
    border: BorderRadius.only(topLeft: Radius.circular(30),bottomLeft: Radius.circular(30)),
  ),
  center(
    border: BorderRadius.zero,
  ),
  right(
    border: BorderRadius.only(topRight: Radius.circular(30),bottomRight: Radius.circular(30)),
  );

  const BorderRauishorizonyal({required this.border});
  final BorderRadius border;
}


