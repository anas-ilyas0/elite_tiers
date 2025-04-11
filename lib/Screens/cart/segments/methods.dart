import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Screens/Dashboard.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:elite_tiers/UI/widgets/AppBtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget noInternet(BuildContext context,
    {required Animation? buttonSqueezeanimation,
    required AnimationController? buttonController,
    required Widget onNetworkNavigationWidget,
    required Function(bool internetAvailable) onButtonClicked}) {
  return SingleChildScrollView(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      noIntImage(),
      noIntText(context),
      noIntDec(context),
      AppBtn(
        title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          try {
            await buttonController?.forward();
          } on TickerCanceled {}

          Future.delayed(const Duration(seconds: 2)).then((_) async {
            bool _isNetworkAvail = await isNetworkAvailable();
            if (_isNetworkAvail) {
            } else {
              await buttonController?.reverse();
            }
            onButtonClicked.call(_isNetworkAvail);
          });
        },
      )
    ]),
  );
}

cartEmpty(BuildContext context) {
  return Center(
    child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SvgPicture.asset(
          'assets/images/empty_cart.svg',
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primarytheme, BlendMode.srcIn),
          // color: Theme.of(context).colorScheme.primarytheme,
        ),
        Text(getTranslated(context, 'NO_CART')!,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.primarytheme,
                fontWeight: FontWeight.normal)),
        Container(
          padding: const EdgeInsetsDirectional.only(
              top: 30.0, start: 30.0, end: 30.0),
          child: Text(getTranslated(context, 'CART_DESC')!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack2,
                    fontWeight: FontWeight.normal,
                  )),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 28.0),
          child: CupertinoButton(
            child: Container(
                width: deviceWidth! * 0.7,
                height: 45,
                alignment: FractionalOffset.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primarytheme,
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                ),
                child: Text(getTranslated(context, 'SHOP_NOW')!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.white,
                        fontWeight: FontWeight.normal))),
            onPressed: () {
              Dashboard.dashboardScreenKey.currentState?.changeTabPosition(0);
            },
          ),
        )
      ]),
    ),
  );
}
