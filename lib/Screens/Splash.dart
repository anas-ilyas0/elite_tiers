import 'dart:async';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Screens/Dashboard.dart';
import 'package:elite_tiers/Screens/SignInUpAcc.dart';
import 'package:elite_tiers/utils/blured_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  static route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const Splash();
      },
    );
  }

  @override
  SplashScreen createState() => SplashScreen();
}

class SplashScreen extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoAnimation;

  bool from = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<Offset>(
      begin: const Offset(0, 5.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    startTime();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.primarytheme,
          ),
          Image.asset(
            'assets/images/doodle.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SlideTransition(
              position: _logoAnimation,
              child: const Image(
                height: 200,
                color: Colors.white,
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  Future<void> navigationPage() async {
    //String? token = await getPrefrence(AUTH_TOKEN);

    //if (token != null && token.isNotEmpty) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();
            return Dashboard(key: Dashboard.dashboardScreenKey);
          },
        ),
      );
    }
    //}
    //else if (token == null || token.isEmpty) {
    //   if (mounted) {
    //     Navigator.pushReplacement(
    //       context,
    //       CupertinoPageRoute(builder: (context) => const SignInUpAcc()),
    //     );
    //   }
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (from) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    }
    super.dispose();
  }
}
