import 'dart:io';
import 'package:elite_tiers/App/languages.dart';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Providers/HomeProvider.dart';
import 'package:elite_tiers/Providers/SettingProvider.dart';
import 'package:elite_tiers/Providers/Theme.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Providers/user_provider.dart';
import 'package:elite_tiers/UI/styles/themedata.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app_Localization.dart';
import 'app/routes.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initMyFatoorahSDK();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (BuildContext context) {
            if (disableDarkTheme == false) {
              String? theme = prefs.getString(APP_THEME);

              if (theme == DARK) {
                ISDARK = "true";
              } else if (theme == LIGHT) {
                ISDARK = "false";
              }

              if (theme == null || theme == "" || theme == DEFAULT_SYSTEM) {
                prefs.setString(APP_THEME, DEFAULT_SYSTEM);
                var brightness = SchedulerBinding
                    .instance.platformDispatcher.platformBrightness;
                ISDARK = (brightness == Brightness.dark).toString();

                return ThemeNotifier(ThemeMode.system);
              }
              return ThemeNotifier(
                theme == LIGHT ? ThemeMode.light : ThemeMode.dark,
              );
            } else {
              return ThemeNotifier(ThemeMode.light);
            }
          },
        ),
        Provider<SettingProvider>(
          create: (context) => SettingProvider(prefs),
        ),
        ChangeNotifierProvider<MyCartProvider>(
            create: (context) => MyCartProvider()),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
        ChangeNotifierProvider<HomeProvider>(
            create: (context) => HomeProvider()),
      ],
      child: MyApp(sharedPreferences: prefs),
    ),
  );
}

void initMyFatoorahSDK() {
  MFSDK.init(
      fatoorahToken,
      MFCountry.SAUDIARABIA,
      MFEnvironment.TEST); // "Live" in production
  MFSDK.setUpActionBar(
    toolBarTitle: "EliteTiers Payment",
    toolBarTitleColor: "#FFFFFF",
    toolBarBackgroundColor: "#22A4BE",
    isShowToolBar: true,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      if (mounted) {
        setState(() {
          _locale = locale;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  setLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (_locale == null) {
      return Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primarytheme,
            valueColor: AlwaysStoppedAnimation<Color?>(
                Theme.of(context).colorScheme.primarytheme)),
      );
    } else {
      return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MaterialApp(
          locale: _locale,
          supportedLocales: [...Languages().codes()],
          onGenerateRoute: Routers.onGenerateRouted,
          initialRoute: Routers.splash,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          navigatorKey: navigatorKey,
          title: appName,
          theme: lightTheme,
          debugShowCheckedModeBanner: false,
          //darkTheme: darkTheme,
          themeMode: themeNotifier.getThemeMode(),
        ),
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
