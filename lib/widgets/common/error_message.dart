import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class CustomErrorMessage extends StatelessWidget {
  CustomErrorMessage({super.key, required this.message});

  String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: Text(
          '$message\ntap to retry',
          textAlign: TextAlign.center,
        ),
        onPressed: () {},
      ),
    );
  }
}
