import 'package:flutter/material.dart';

class LoadingBackdrop extends StatelessWidget {
  const LoadingBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: const Color.fromARGB(125, 65, 65, 65),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
