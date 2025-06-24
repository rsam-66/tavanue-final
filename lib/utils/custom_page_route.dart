import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          // Set the transition duration
          transitionDuration:
              const Duration(milliseconds: 500), // Adjust duration as needed
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              // Use FadeTransition
              FadeTransition(
            opacity: animation, // Drive the opacity with the animation
            child: child,
          ),
        );
}
