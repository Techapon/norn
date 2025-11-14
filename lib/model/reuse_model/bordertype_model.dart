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

