import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/utils/page_transition.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  canvasColor: ThemeData().colorScheme.lightWhite,
  cardColor: colors.cardColor,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeThroughPageTransitionsBuilder(),
    },
  ),
  dialogBackgroundColor: ThemeData().colorScheme.white,
  iconTheme: ThemeData().iconTheme.copyWith(color: colors.primary),
  primarySwatch: colors.primary_app,
  primaryColor: ThemeData().colorScheme.lightWhite,
  fontFamily: 'OpenSans',
  colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
      .copyWith(secondary: colors.primary, brightness: Brightness.light),
  appBarTheme: AppBarTheme(scrolledUnderElevation: 0),
  textTheme: TextTheme(
          titleLarge: TextStyle(
            color: ThemeData().colorScheme.fontColor,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
              color: ThemeData().colorScheme.fontColor,
              fontWeight: FontWeight.bold))
      .apply(bodyColor: ThemeData().colorScheme.fontColor),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  canvasColor: colors.darkColor,
  cardColor: colors.darkColor2,
  dialogBackgroundColor: colors.darkColor2,
  primaryColor: colors.darkColor,
  textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.darkIcon,
      selectionColor: colors.darkIcon,
      selectionHandleColor: colors.darkIcon),
  fontFamily: 'OpenSans',
  //brightness: Brightness.dark,
  iconTheme: ThemeData().iconTheme.copyWith(color: colors.darkprimary),
  textTheme: TextTheme(
          titleLarge: TextStyle(
            color: ThemeData().colorScheme.fontColor,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
              color: ThemeData().colorScheme.fontColor,
              fontWeight: FontWeight.bold))
      .apply(bodyColor: ThemeData().colorScheme.fontColor),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: colors.dark_primary_app)
      .copyWith(secondary: colors.darkIcon, brightness: Brightness.dark),
  checkboxTheme: CheckboxThemeData(
    fillColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return colors.darkprimary;
      }
      return null;
    }),
    //     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
    //   if (states.contains(MaterialState.disabled)) {
    //     return null;
    //   }
    //   if (states.contains(MaterialState.selected)) {
    //     return colors.darkprimary;
    //   }
    //   return null;
    // }),
  ),
  radioTheme: RadioThemeData(
    fillColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return colors.darkprimary;
      }
      return null;
    }),
    //     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
    //   if (states.contains(MaterialState.disabled)) {
    //     return null;
    //   }
    //   if (states.contains(MaterialState.selected)) {
    //     return colors.darkprimary;
    //   }
    //   return null;
    // }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return colors.darkprimary;
      }
      return null;
    }),
    //     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
    //   if (states.contains(MaterialState.disabled)) {
    //     return null;
    //   }
    //   if (states.contains(MaterialState.selected)) {
    //     return colors.darkprimary;
    //   }
    //   return null;
    // }),
    trackColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return null;
      }
      if (states.contains(WidgetState.selected)) {
        return colors.darkprimary;
      }
      return null;
    }),
    //     MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
    //   if (states.contains(MaterialState.disabled)) {
    //     return null;
    //   }
    //   if (states.contains(MaterialState.selected)) {
    //     return colors.darkprimary;
    //   }
    //   return null;
    // }),
  ),
);
