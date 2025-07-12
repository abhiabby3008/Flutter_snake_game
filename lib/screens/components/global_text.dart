import 'package:flutter/material.dart';
import 'package:flutter_snake/constans/theme_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final double? height;
  final String? fontFamily; // New parameter for dynamic font family

  const GlobalText({
    super.key,
    required this.fontSize,
    required this.text,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.height,
    this.fontFamily, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: fontFamily != null
          ? GoogleFonts.getFont(
              fontFamily!,
              fontSize: fontSize,
              color: color ?? ThemeConstants.textColorBlack,
              fontWeight: fontWeight ?? FontWeight.normal,
              decoration: decoration,
              height: height,
            )
          : GoogleFonts.poppins(
              fontSize: fontSize,
              color: color ?? ThemeConstants.textColorBlack,
              fontWeight: fontWeight ?? FontWeight.normal,
              decoration: decoration,
              height: height,
            ),
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
