import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Models/cart_model.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Screens/Dashboard.dart';
import 'package:elite_tiers/Screens/cart/my_cart_payment_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MyCartScreen extends StatelessWidget {
  final bool fromBottom;
  const MyCartScreen({super.key, required this.fromBottom});

  final int num = 1;

  cartEmpty(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SvgPicture.asset(
            'assets/images/empty_cart.svg',
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primarytheme, BlendMode.srcIn),
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
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0)),
                    ),
                    child: Text(getTranslated(context, 'SHOP_NOW')!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.white,
                            fontWeight: FontWeight.normal))),
                onPressed: () {
                  Navigator.of(context)
                      .popUntil((Route route) => route.isFirst);
                  Dashboard.dashboardScreenKey.currentState
                      ?.changeTabPosition(0);
                }),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool isRtl(context) {
      Locale locale = Localizations.localeOf(context);
      return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
    }

    final cart = Provider.of<MyCartProvider>(context);
    List<CartItem> cartItems = Provider.of<MyCartProvider>(context).cartItems;
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      body: cartItems.isEmpty
          ? cartEmpty(context)
          : Padding(
              padding:
                  const EdgeInsets.only(right: 8, left: 8, bottom: 0, top: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        CartItem item = cartItems[index];
                        return Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            Colors.grey.withValues(alpha: 0.5)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5, 0, 0, 8),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 100,
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  item.image))),
                                                    ),
                                                    Positioned(
                                                      top: -2,
                                                      left: 1,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(2),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Center(
                                                            child: Text(
                                                              item.tag,
                                                              style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.title,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          item.discountedPrice !=
                                                                  0
                                                              ? item.actualPrice
                                                                  .toString()
                                                              : locale.languageCode ==
                                                                      'ar'
                                                                  ? '${item.actualPrice.toString()} ر.س'
                                                                  : 'SAR ${item.actualPrice.toString()}',
                                                          style: TextStyle(
                                                              color: item.discountedPrice !=
                                                                      0
                                                                  ? null
                                                                  : const Color(
                                                                      0xff22A4BE),
                                                              decoration: item
                                                                          .discountedPrice !=
                                                                      0
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : TextDecoration
                                                                      .none,
                                                              fontWeight: item
                                                                          .discountedPrice !=
                                                                      0
                                                                  ? FontWeight
                                                                      .normal
                                                                  : FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                item.discountedPrice !=
                                                                        0
                                                                    ? 5
                                                                    : 0),
                                                        if (item.discountedPrice !=
                                                            0)
                                                          Text(
                                                            item.discountedPrice
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: Color(
                                                                    0xff22A4BE),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        SizedBox(width: 5),
                                                        if (item.discountedPrice !=
                                                            0)
                                                          Text(
                                                            locale.languageCode ==
                                                                    'ar'
                                                                ? 'ر.س'
                                                                : 'SAR',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff22A4BE),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 24, left: 8),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  cart.decreaseQuantity(
                                                      item.id);
                                                },
                                                child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha:
                                                                        0.1)),
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.5)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 15,
                                                        color: textColor,
                                                      ),
                                                    )),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(item.quantity.toString()),
                                              const SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: () {
                                                  cart.increaseQuantity(
                                                      item.id);
                                                },
                                                child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha:
                                                                        0.1)),
                                                        color: Colors.grey
                                                            .withValues(
                                                                alpha: 0.5)),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 15,
                                                        color: textColor,
                                                      ),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: isRtl(context) ? 0 : null,
                                  right: isRtl(context) ? null : 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      Provider.of<MyCartProvider>(context,
                                              listen: false)
                                          .removeItem(item);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Consumer<MyCartProvider>(
                    builder: (context, cart, child) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                locale.languageCode == 'ar'
                                    ? '${cart.total} ر.س'
                                    : 'SAR ${cart.total}',
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 18),
                              ),
                              Text(
                                getTranslated(context, 'total')!,
                                style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        const Divider(color: Colors.grey),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MyCartPaymentScreen(
                                            subTotal: cart.total)));
                              },
                              child: Text(
                                getTranslated(context, 'check_out')!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                        const SizedBox(height: 67),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
