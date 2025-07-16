import 'dart:async';
import 'package:bottom_bar/bottom_bar.dart';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Providers/home_provider.dart';
import 'package:elite_tiers/Providers/settings_provider.dart';
import 'package:elite_tiers/Providers/user_provider.dart';
import 'package:elite_tiers/Screens/cart/my_cart_screen.dart';
import 'package:elite_tiers/Screens/homeWidgets/MyProfile.dart';
import 'package:elite_tiers/Screens/home_screen.dart';
import 'package:elite_tiers/utils/blured_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../ui/styles/DesignConfig.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static GlobalKey<HomePageState> dashboardScreenKey =
      GlobalKey<HomePageState>();
  static route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return Dashboard(
          key: dashboardScreenKey,
        );
      },
    );
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Dashboard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selBottom = 0;

  final PageController _pageController = PageController();
  late AnimationController navigationContainerAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  StreamSubscription<Uri>? _linkSubscription;

  @override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _linkSubscription?.cancel();
  _pageController.dispose();
  navigationContainerAnimationController.dispose();
  super.dispose();
}

  void loadData() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final userId = await settingsProvider.getPrefrence(ID) ?? '';

    if (!mounted) return;

    context.read<UserProvider>().setUserId(userId);
    context
        .read<HomeProvider>()
        .setAnimationController(navigationContainerAnimationController);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, loadData);
  }

  changeTabPosition(int index) {
    Future.delayed(Duration.zero, () {
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selBottom == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          if (_selBottom != 0) {
            _pageController.animateToPage(0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut);
          }
        }
      },
      child: SafeArea(
          top: false,
          bottom: true,
          child: Consumer<UserProvider>(builder: (context, data, child) {
            return Scaffold(
              extendBody: true,
              backgroundColor: Theme.of(context).colorScheme.lightWhite,
              appBar: _getAppBar(),
              body: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  HomeScreen(),
                  const MyCartScreen(fromBottom: true),
                  const MyProfile()
                ],
                onPageChanged: (index) {
                  setState(() {
                    if (!context
                        .read<HomeProvider>()
                        .animationController
                        .isAnimating) {
                      context
                          .read<HomeProvider>()
                          .animationController
                          .reverse();
                      context.read<HomeProvider>().showBars(true);
                    }
                    _selBottom = index;
                    if (index == 2) {
                      cartTotalClear();
                    }
                  });
                },
              ),
              bottomNavigationBar: _getBottomBar(),
            );
          })),
    );
  }

  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1) {
      title = getTranslated(context, 'MYBAG');
    } else if (_selBottom == 2) {
      title = getTranslated(context, 'PROFILE');
    }

    return AppBar(
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: _selBottom == 0
          ? Image(
              height: 90,
              image: const AssetImage('assets/images/logo.png'),
              color: Theme.of(context).colorScheme.primarytheme,
            )
          : Text(
              title!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primarytheme,
                  fontWeight: FontWeight.normal),
            ),
      actions: <Widget>[
        IconButton(
          icon: SvgPicture.asset(
            "${imagePath}desel_notification.svg",
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.blackInverseInDarkTheme,
                BlendMode.srcIn),
          ),
          onPressed: () {},
        ),
        IconButton(
          padding: const EdgeInsets.all(0),
          icon: SvgPicture.asset(
            "${imagePath}desel_fav.svg",
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.blackInverseInDarkTheme,
                BlendMode.srcIn),
          ),
          onPressed: () {
            // Navigator.pushNamed(
            //   context,
            //   Routers.favoriteScreen,
            // );
          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
    );
  }

  Widget _getBottomBar() {
    Locale locale = Localizations.localeOf(context);
    return FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
            parent: navigationContainerAnimationController,
            curve: Curves.easeInOut)),
        child: SlideTransition(
          position:
              Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0))
                  .animate(CurvedAnimation(
                      parent: navigationContainerAnimationController,
                      curve: Curves.easeInOut)),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: BottomBar(
              height: 60,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              selectedIndex: _selBottom,
              onTap: (int index) {
                _pageController.jumpToPage(index);
                setState(() => _selBottom = index);
              },
              items: <BottomBarItem>[
                BottomBarItem(
                  icon: _selBottom == 0
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: locale.languageCode == 'ar' ? 14 : 0),
                          child: SvgPicture.asset(
                            "${imagePath}sel_home.svg",
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.primarytheme,
                                BlendMode.srcIn),
                            width: 18,
                            height: 20,
                          ),
                        )
                      : SvgPicture.asset(
                          "${imagePath}desel_home.svg",
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.primarytheme,
                              BlendMode.srcIn),
                          width: 18,
                          height: 20,
                        ),
                  title: FittedBox(
                    child: Text(
                        getTranslated(
                          context,
                          'HOME_LBL',
                        )!,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true),
                  ),
                  activeColor: Theme.of(context).colorScheme.primarytheme,
                ),
                // BottomBarItem(
                //     icon: _selBottom == 1
                //         ? SvgPicture.asset(
                //             "${imagePath}category01.svg",
                //             colorFilter: ColorFilter.mode(
                //                 Theme.of(context).colorScheme.primarytheme,
                //                 BlendMode.srcIn),
                //             width: 18,
                //             height: 18,
                //           )
                //         : SvgPicture.asset(
                //             "${imagePath}category.svg",
                //             colorFilter: ColorFilter.mode(
                //                 Theme.of(context).colorScheme.primarytheme,
                //                 BlendMode.srcIn),
                //             width: 18,
                //             height: 18,
                //           ),
                //     title: Text(getTranslated(context, 'category')!,
                //         overflow: TextOverflow.ellipsis, softWrap: true),
                //     activeColor: Theme.of(context).colorScheme.primarytheme),
                // BottomBarItem(
                //   icon: _selBottom == 2
                //       ? SvgPicture.asset(
                //           "${imagePath}sale02.svg",
                //           colorFilter: ColorFilter.mode(
                //               Theme.of(context).colorScheme.primarytheme,
                //               BlendMode.srcIn),
                //           width: 18,
                //           height: 20,
                //         )
                //       : SvgPicture.asset(
                //           "${imagePath}sale.svg",
                //           colorFilter: ColorFilter.mode(
                //               Theme.of(context).colorScheme.primarytheme,
                //               BlendMode.srcIn),
                //           width: 18,
                //           height: 20,
                //         ),
                //   title: Text(getTranslated(context, 'SALE')!,
                //       overflow: TextOverflow.ellipsis, softWrap: true),
                //   activeColor: Theme.of(context).colorScheme.primarytheme,
                // ),
                BottomBarItem(
                  icon: Selector<UserProvider, String>(
                    builder: (context, data, child) {
                      return Consumer<MyCartProvider>(
                        builder: (context, cart, child) {
                          return Stack(
                            children: [
                              _selBottom == 1
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          right: locale.languageCode == 'ar'
                                              ? 14
                                              : 0),
                                      child: Row(
                                        children: [
                                          FittedBox(
                                            child: Text(
                                              cart.cartItems.length.toString(),
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primarytheme),
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          SvgPicture.asset(
                                            "${imagePath}cart01.svg",
                                            colorFilter: ColorFilter.mode(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primarytheme,
                                                BlendMode.srcIn),
                                            width: 18,
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            cart.cartItems.length.toString(),
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primarytheme),
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        SvgPicture.asset(
                                          "${imagePath}cart.svg",
                                          colorFilter: ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primarytheme,
                                              BlendMode.srcIn),
                                          width: 18,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                              (data.isNotEmpty && data != "0")
                                  ? Positioned.directional(
                                      end: 0,
                                      textDirection: Directionality.of(context),
                                      top: 0,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primarytheme),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Text(
                                                data,
                                                style: TextStyle(
                                                    fontSize: 7,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .white),
                                              ),
                                            ),
                                          )),
                                    )
                                  : const SizedBox.shrink()
                            ],
                          );
                        },
                      );
                    },
                    selector: (_, homeProvider) => homeProvider.curCartCount,
                  ),
                  title: FittedBox(
                    child: Text(getTranslated(context, 'CART')!,
                        overflow: TextOverflow.ellipsis, softWrap: true),
                  ),
                  activeColor: Theme.of(context).colorScheme.primarytheme,
                ),
                BottomBarItem(
                  icon: _selBottom == 2
                      ? Padding(
                          padding: EdgeInsets.only(
                              right: locale.languageCode == 'ar' ? 14 : 0),
                          child: SvgPicture.asset(
                            "${imagePath}profile01.svg",
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.primarytheme,
                                BlendMode.srcIn),
                            width: 18,
                            height: 20,
                          ),
                        )
                      : SvgPicture.asset(
                          "${imagePath}profile.svg",
                          width: 18,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.primarytheme,
                              BlendMode.srcIn),
                        ),
                  title: FittedBox(
                    child: Text(getTranslated(context, 'PROFILE')!,
                        overflow: TextOverflow.ellipsis, softWrap: true),
                  ),
                  activeColor: Theme.of(context).colorScheme.primarytheme,
                ),
              ],
            ),
          ),
        ));
  }
}
