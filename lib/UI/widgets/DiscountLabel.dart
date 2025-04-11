import 'package:elite_tiers/Helpers/Color.dart';
import 'package:flutter/material.dart';

Widget getDiscountLabel(String discount) => Container(
  decoration: BoxDecoration(
      color: colors.red, borderRadius: BorderRadius.circular(1)),
  margin: const EdgeInsets.only(left: 5),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
    child: Text(
      "$discount%",
      style: const TextStyle(
          color: colors.whiteTemp,
          fontWeight: FontWeight.bold,
          fontSize: 10),
    ),
  ),
);