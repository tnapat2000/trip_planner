import 'package:flutter/material.dart';


class BaseCard extends StatelessWidget {
  BaseCard({required this.cardColor, required this.cardChild, this.cardOnTapFunc, this.key});

  final Color cardColor;
  final Widget cardChild;
  final VoidCallback? cardOnTapFunc;
  final Key? key;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cardOnTapFunc,
      child: Container(
        child: cardChild,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
