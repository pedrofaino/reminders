import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), 
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          SvgPicture.asset(
            'assets/google_logo.svg',
            height: 24.0, 
            width: 24.0, 
          ),
          const SizedBox(width: 12.0),
          const Text(
            'Iniciar sesión con Google',
            style: TextStyle(
              fontSize: 16.0, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}