import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Models/cart_model.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:elite_tiers/UI/widgets/SimpleAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

class HomeProductDetails extends StatelessWidget {
  final int id, actualPrice, discountedPrice;
  final String? categoryName;
  final String productImage,
      tag,
      productName,
      origin,
      yearOfProduction,
      pattern,
      width,
      rimSize,
      ratio,
      diameter,
      description;

  const HomeProductDetails(
      {super.key,
      required this.id,
      this.categoryName,
      required this.productImage,
      required this.tag,
      required this.productName,
      required this.actualPrice,
      required this.discountedPrice,
      required this.origin,
      required this.yearOfProduction,
      required this.pattern,
      required this.width,
      required this.rimSize,
      required this.ratio,
      required this.diameter,
      required this.description});

  Widget row(String firstText, String secText, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, firstText)!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(secText),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    bool isRtl(context) {
      return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
    }

    return Scaffold(
      appBar: getSimpleAppBar(productName, context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(productImage)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: isRtl(context) ? 8 : null,
                          left: isRtl(context) ? null : 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Text(
                                  tag,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      row('origin', origin, context),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      row('year_of_production', yearOfProduction, context),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'pattern')!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(child: Text(pattern)),
                          ],
                        ),
                      ),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      row('width', width, context),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      row('rim_size', rimSize, context),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      row('ratio', ratio, context),
                    if (categoryName!.toLowerCase() == 'الإطارات')
                      row('diameter', diameter, context),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                                        id: id,
                                        image: productImage,
                                        tag: tag,
                                        title: productName,
                                        actualPrice: actualPrice,
                                        discountedPrice: discountedPrice));
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_circle, size: 18),
                              const SizedBox(width: 5),
                              Text(getTranslated(context, 'ADD_CART2')!)
                            ],
                          )),
                    ),
                    Text(
                      getTranslated(context, 'desc')!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    HtmlWidget(description.isNotEmpty ? description : 'N/A')
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
