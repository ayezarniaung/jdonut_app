import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jdonut_app/shared/theme/app_colors.dart';

Widget tncFooter() {
  return Text.rich(
    TextSpan(
      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted),
      children: const [
        TextSpan(
          text: 'By continuing, you acknowledge that you have read and agree to our ',
        ),
        TextSpan(
          text: 'Terms of Use',
          style: TextStyle(color: AppColors.pink),
        ),
        TextSpan(text: ' and '),
        TextSpan(
          text: 'Privacy Policy.',
          style: TextStyle(color: AppColors.pink),
        ),
      ],
    ),
    textAlign: TextAlign.center,
  );
}
