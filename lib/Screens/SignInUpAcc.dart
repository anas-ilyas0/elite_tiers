import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Screens/Dashboard.dart';
import 'package:elite_tiers/UI/widgets/AppBtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/routes.dart';

class SignInUpAcc extends StatefulWidget {
  const SignInUpAcc({super.key});

  @override
  _SignInUpAccState createState() => _SignInUpAccState();
}

class _SignInUpAccState extends State<SignInUpAcc>
    with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    super.initState();

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  _subLogo() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(top: 30.0),
        child: SvgPicture.asset(
          'assets/images/homelogo.svg',
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primarytheme, BlendMode.srcIn),
        ));
  }

  welcomeEshopTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Text(
        getTranslated(context, 'WELCOME_ESHOP')!,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold,
            fontSize: 22),
      ),
    );
  }

  eCommerceforBusinessTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 5.0,
      ),
      child: Text(
        getTranslated(context, 'ECOMMERCE_APP_FOR_ALL_BUSINESS')!,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.secondaryFontColor,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  signInyourAccTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 60.0,
      ),
      child: Text(
        getTranslated(context, 'SIGNIN_ACC_LBL')!,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  signInBtn() {
    return AppBtn(
      title: getTranslated(context, 'SIGNIN_LBL')!.toUpperCase(),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        Navigator.pushNamed(context, Routers.loginScreen,
            arguments: {"isPop": false});
      },
    );

    // CupertinoButton(
    //   child: Container(
    //       width: deviceWidth! * 0.8,
    //       height: 45,
    //       alignment: FractionalOffset.center,
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).colorScheme.primarytheme,
    //         borderRadius: const BorderRadius.all(Radius.circular(100.0)),
    //         boxShadow: [
    //           BoxShadow(
    //               blurRadius: 10,
    //               offset: const Offset(0, 8),
    //               color: Theme.of(context)
    //                   .colorScheme
    //                   .primarytheme
    //                   .withValues(0.4))
    //         ],
    //       ),
    //       child: Text(getTranslated(context, 'SIGNIN_LBL')!,
    //           textAlign: TextAlign.center,
    //           style: Theme.of(context).textTheme.titleMedium!.copyWith(
    //               color: colors.whiteTemp, fontWeight: FontWeight.normal))),
    //   onPressed: () {
    //     Navigator.pushNamed(context, Routers.loginScreen,
    //         arguments: {"isPop": false});
    //   },
    // );
  }

  createAccBtn() {
    return AppBtn(
      padding: const EdgeInsets.only(top: 0),
      title: getTranslated(context, 'CREATE_ACC_LBL')!.toUpperCase(),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        Navigator.pushNamed(context, Routers.sendOTPScreen,
            arguments: {"title": getTranslated(context, 'SEND_OTP_TITLE')});
      },
    );
    // return CupertinoButton(
    //   child: Container(
    //       width: deviceWidth! * 0.8,
    //       height: 45,
    //       alignment: FractionalOffset.center,
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).colorScheme.primarytheme,
    //         borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    //       ),
    //       child: Text(getTranslated(context, 'CREATE_ACC_LBL')!,
    //           textAlign: TextAlign.center,
    //           style: Theme.of(context).textTheme.titleMedium!.copyWith(
    //               color: colors.whiteTemp, fontWeight: FontWeight.normal))),
    //   onPressed: () {
    //     Navigator.pushNamed(context, Routers.sendOTPScreen,
    //         arguments: {"title": getTranslated(context, 'SEND_OTP_TITLE')});
    //   },
    // );
  }

  skipSignInBtn() {
    return AppBtn(
      padding: const EdgeInsets.only(top: 0),
      title: getTranslated(context, 'SKIP_SIGNIN_LBL')!.toUpperCase(),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();

        Navigator.pushReplacementNamed(
          context,
          Routers.dashboardScreen,
        );
      },
    );
    // return CupertinoButton(
    //   child: Container(
    //       width: deviceWidth! * 0.8,
    //       height: 45,
    //       alignment: FractionalOffset.center,
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).colorScheme.primarytheme,
    //         borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    //       ),
    //       child: Text(getTranslated(context, 'SKIP_SIGNIN_LBL')!,
    //           textAlign: TextAlign.center,
    //           style: Theme.of(context).textTheme.titleMedium!.copyWith(
    //               color: colors.whiteTemp, fontWeight: FontWeight.normal))),
    //   onPressed: () {
    //     Dashboard.dashboardScreenKey = GlobalKey<HomePageState>();

    //     Navigator.pushReplacementNamed(
    //       context,
    //       Routers.dashboardScreen,
    //     );
    //   },
    // );
  }

  // backBtn() {
  //   return Container(
  //     padding: const EdgeInsetsDirectional.only(top: 34.0, start: 5.0),
  //     alignment: Alignment.topLeft,
  //     width: 60,
  //     child: Material(
  //         color: Colors.transparent,
  //         child: Container(
  //           margin: const EdgeInsets.all(10),
  //           decoration: shadow(),
  //           child: Card(
  //             elevation: 0,
  //             child: InkWell(
  //               borderRadius: BorderRadius.circular(4),
  //               onTap: () => Navigator.of(context).pop(),
  //               child: const Center(
  //                 child: Icon(
  //                   Icons.keyboard_arrow_left,
  //                   color: Theme.of(context).colorScheme.primarytheme,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         )),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      body: Container(
        color: Theme.of(context).colorScheme.lightWhite,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _subLogo(),
                welcomeEshopTxt(),
                eCommerceforBusinessTxt(),
                signInyourAccTxt(),
                signInBtn(),
                createAccBtn(),
                skipSignInBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
