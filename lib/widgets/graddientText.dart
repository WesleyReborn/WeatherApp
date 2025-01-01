import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/theme/app_colors.dart';

Widget graddientText(String text, double fontSize, FontWeight fontWeight) {
  return ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.black, AppColors.darkBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight)
        .createShader(bounds),
    child: Text(
      text,
      style: GoogleFonts.openSans(fontSize: fontSize, fontWeight: fontWeight),
    ),
  );
}
