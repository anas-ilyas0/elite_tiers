import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Models/cart_model.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Screens/home_product_details.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentOptions {
  static const Map<String, String> images = {
    'tabby': 'assets/images/tabby.png',
    'tamara': 'assets/images/tamara.png',
  };
}

class ProductItem extends StatelessWidget {
  final String productImage,
      productTag,
      productName,
      productDiscountPrice,
      productPrice,
      productOrigin,
      productYear,
      productCategoryName,
      productPattern,
      productWidth,
      productRimSize,
      productRatio,
      productDiameter,
      productDescription;
  final int productId;
  final double productInstallment;
  const ProductItem(
      {this.productImage = '',
      this.productTag = '',
      this.productName = '',
      this.productDiscountPrice = '',
      this.productPrice = '',
      this.productOrigin = '',
      this.productYear = '',
      this.productCategoryName = '',
      this.productPattern = '',
      this.productWidth = '',
      this.productRimSize = '',
      this.productRatio = '',
      this.productDiameter = '',
      this.productDescription = '',
      this.productId = 0,
      this.productInstallment = 0,
      super.key});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => HomeProductDetails(
                        id: productId,
                        categoryName: productCategoryName.toString(),
                        productImage: productImage,
                        tag: productTag,
                        productName: productName,
                        actualPrice:
                            double.tryParse(productPrice)?.toInt() ?? 0,
                        discountedPrice: productDiscountPrice.isNotEmpty
                            ? double.tryParse(productDiscountPrice)?.toInt() ??
                                0
                            : 0,
                        origin: productOrigin,
                        yearOfProduction: productYear,
                        pattern: productPattern,
                        width: productWidth,
                        rimSize: productRimSize,
                        ratio: productRatio,
                        diameter: productDiameter,
                        description: productDescription,
                      )));
        },
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primarytheme,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: NetworkImage(productImage),
                                ),
                              ),
                            ),
                            Container(
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FittedBox(
                                child: Center(
                                  child: Text(
                                    productTag,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 0.5,
                          color: Colors.grey,
                        ),
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        FittedBox(
                          child: Row(
                            children: [
                              Text(
                                  locale.languageCode == 'ar'
                                      ? productDiscountPrice.toString()
                                      : 'SAR ${productDiscountPrice.toString()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primarytheme,
                                  )),
                              if (locale.languageCode == 'ar')
                                SizedBox(width: 3),
                              if (locale.languageCode == 'ar')
                                Text('ر.س',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primarytheme,
                                    )),
                              SizedBox(
                                  width:
                                      productDiscountPrice.isNotEmpty ? 5 : 0),
                              Text(productPrice.toString(),
                                  style: TextStyle(
                                      decoration:
                                          productDiscountPrice.isNotEmpty
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                      fontSize: 12,
                                      color: productDiscountPrice.isNotEmpty
                                          ? Colors.red
                                          : Theme.of(context)
                                              .colorScheme
                                              .primarytheme)),
                            ],
                          ),
                        ),
                        Text(getTranslated(context, 'tax_included')!,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primarytheme)),
                        const SizedBox(height: 5),
                        Container(
                          height: 0.5,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 5),
                        FittedBox(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, 'monthly')!,
                                  ),
                                  Text(
                                    productInstallment.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 3),
                                  Text(locale.languageCode == 'ar'
                                      ? 'ر.س'
                                      : 'SAR')
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, 'in')!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 3),
                                  const Text(
                                    '4',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    getTranslated(context, 'installments')!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: PaymentOptions.images.entries
                              .map((entry) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.asset(
                                        entry.value,
                                        height: 30,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        Container(
                          height: 0.5,
                          color: Colors.grey,
                        ),
                        if (productCategoryName == 'إطار' ||
                            productCategoryName == 'الإطارات')
                          FittedBox(
                            child: Row(
                              children: [
                                Image(
                                  height: 20,
                                  width: 30,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  image: const AssetImage(
                                      'assets/images/smallcar.png'),
                                ),
                                SizedBox(width: 10),
                                Text('$productOrigin | $productYear')
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primarytheme,
                      ),
                      onPressed: () async {
                        String? token = await getPrefrence(AUTH_TOKEN);
                        if (token == null || token.isEmpty) {
                          if (context.mounted) {
                            setSnackbar(
                              getTranslated(context, 'SIGNIN_DETAILS')!,
                              context,
                            );
                          }
                        } else {
                          if (context.mounted) {
                            bool productAdded = Provider.of<MyCartProvider>(
                                    context,
                                    listen: false)
                                .addItem(CartItem(
                              id: productId,
                              image: productImage,
                              tag: productTag,
                              title: productName,
                              actualPrice:
                                  double.tryParse(productPrice)?.toInt() ?? 0,
                              discountedPrice: productDiscountPrice.isNotEmpty
                                  ? double.tryParse(productDiscountPrice)
                                          ?.toInt() ??
                                      0
                                  : 0,
                            ));
                            if (productAdded) {
                              setSnackbar(
                                  getTranslated(
                                      context, 'product_added_to_cart')!,
                                  context);
                            } else {
                              setSnackbar(
                                  getTranslated(
                                      context, 'product_already_in_cart')!,
                                  context);
                            }
                          }
                        }
                      },
                      child: FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.add_circle, size: 18),
                            SizedBox(width: 5),
                            Text(
                              getTranslated(context, 'ADD_CART2')!,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
