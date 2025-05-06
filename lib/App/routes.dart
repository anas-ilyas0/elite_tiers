import 'dart:developer';
import 'package:elite_tiers/Screens/Dashboard.dart';
import 'package:elite_tiers/Screens/Intro_Slider.dart';
import 'package:elite_tiers/Screens/Login.dart';
import 'package:elite_tiers/Screens/SendOtp.dart';
import 'package:elite_tiers/Screens/SignInUpAcc.dart';
import 'package:elite_tiers/Screens/SignUp.dart';
import 'package:elite_tiers/Screens/Splash.dart';
import 'package:elite_tiers/utils/blured_router.dart';
import 'package:flutter/material.dart';

class Routers {
  Routers._(); //priv cons

  static const String splash = "/";
  static const String signInUpAcc = '/signInUpAcc';
  static const String dashboardScreen = "/dashboard";
  static const String introSliderScreen = "/introSliderScreen";
  static const String notificationListScreen = "/notificationListScreen";
  static const String loginScreen = "/loginScreen";
  static const String sendOTPScreen = "/sendOTPScreen";
  static const String productDetails = "/productDetailsScreen";
  static const String saleSectionScreen = "/saleSectionScreen";
  static const String sectionListScreen = "/sectionListScreen";
  static const String setPassScreen = "/setPassScreen";
  static const String signupScreen = "/signupScreen";
  static const String faqProductScreen = "/faqProduct";
  static const String productListScreen = "/productListScreen";
  static const String subCategoryScreen = "/subCategoryScreen";
  static const String searchScreen = "/searchScreen";
  static const String myOrderScreen = "/myOrderScreen";
  static const String transactionHistoryScreen = "/transactionHistoryScreen";
  static const String myWalletScreen = "/myWalletScreen";
  static const String promoCodeScreen = "/promoCodeScreen";
  static const String manageAddressScreen = "/manageAddressScreen";
  static const String paymentScreen = "/paymentScreen";
  static const String orderSuccessScreen = "/orderSuccessScreen";
  static const String favoriteScreen = "/favoriteScreen";
  static const String verifyOTPScreen = "/verifyOTPScreen";
  static const String privacyPolicyScreen = "/privacyPolicyScreen";

  ///
  static String currentRoute = splash;
  static String previousCustomerRoute = splash;
  static Route? onGenerateRouted(RouteSettings routeSettings) {
    previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? "";
    log("CURRENT ROUTE $currentRoute");

    switch (routeSettings.name) {
      case splash:
        return Splash.route(routeSettings);

      case dashboardScreen:
        return Dashboard.route(routeSettings);
      // case notificationListScreen:
      //   return NotificationList.route(routeSettings);
      case loginScreen:
        return LoginScreen.route(routeSettings);
      case sendOTPScreen:
        return SendOtp.route(routeSettings);

      // case productDetails:
      //   return ProductDetail.route(routeSettings);

      // case saleSectionScreen:
      //   return SaleSectionScreen.route(routeSettings);
      // case sectionListScreen:
      //   return SectionListScreen.route(routeSettings);
      // case setPassScreen:
      //   return SetPass.route(routeSettings);
      case signupScreen:
        return SignUp.route(routeSettings);
      // case faqProductScreen:
      //   return FaqsProduct.route(routeSettings);
      // case productListScreen:
      //   return ProductListScreen.route(routeSettings);
      // case subCategoryScreen:
      //   return SubCategoryScreen.route(routeSettings);
      // case searchScreen:
      //   return SearchScreen.route(routeSettings);
      // case myOrderScreen:
      //   return MyOrder.route(routeSettings);
      // case transactionHistoryScreen:
      //   return TransactionHistory.route(routeSettings);
      // case myWalletScreen:
      //   return MyWalletScreen.route(routeSettings);
      // case promoCodeScreen:
      //   return PromoCodeScreen.route(routeSettings);
      // case manageAddressScreen:
      //   return ManageAddress.route(routeSettings);
      // case paymentScreen:
      //   return Payment.route(routeSettings);
      // case orderSuccessScreen:
      //   return OrderSuccess.route(routeSettings);
      // case favoriteScreen:
      //   return Favorite.route(routeSettings);
      // case verifyOTPScreen:
      //   return VerifyOtp.route(routeSettings);

      case signInUpAcc:
        return SignInUpAcc.route(routeSettings);
      case introSliderScreen:
        return IntroSlider.route(routeSettings);

      ///default
      default:
        return BlurredRouter(
          builder: (context) {
            return const Scaffold(
              body: Center(
                child: Text("No page found"),
              ),
            );
          },
        );
      // case splash:
      //   return BlurredRouter(builder: ((context) => const SplashScreen()));
    }
  }
}
