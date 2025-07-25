import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../Models/products_model.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/UI/widgets/product_item.dart';

class FilteredProductsScreen extends StatelessWidget {
  final List<ProductsCategories> allCategories;
  final List<AllProducts> filteredProducts;

  const FilteredProductsScreen({
    super.key,
    required this.allCategories,
    required this.filteredProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, 'filtered_products')!),
      ),
      body: filteredProducts.isEmpty
          ? Center(child: Text(getTranslated(context, 'no_product_found')!))
          : ListView.builder(
              itemCount: (filteredProducts.length / 2).ceil(),
              itemBuilder: (context, index) {
                int firstIndex = index * 2;
                int secondIndex = firstIndex + 1;
                final firstProduct = filteredProducts[firstIndex];
                final secondProduct = secondIndex < filteredProducts.length
                    ? filteredProducts[secondIndex]
                    : null;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child:
                              _productCard(context, firstProduct, firstIndex),
                        ),
                        if (secondProduct != null)
                          Expanded(
                            child: _productCard(
                                context, secondProduct, secondIndex),
                          )
                        else
                          Expanded(child: Container()),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _productCard(BuildContext context, AllProducts product, int index) {
    final category = allCategories.firstWhere(
      (cat) => cat.products.any((p) => p.id == product.id),
      orElse: () => ProductsCategories(
        id: 0,
        name: '',
        image: '',
        description: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        products: [],
      ),
    );

    final categoryName = category.name;
    Locale locale = Localizations.localeOf(context);
    final double? discountPriceValue = double.tryParse(
        product.discountPrice.isNotEmpty
            ? product.discountPrice
            : product.price);
    final double installment = (discountPriceValue ?? 0) / 4;

    return AnimationConfiguration.staggeredGrid(
      position: index,
      duration: const Duration(milliseconds: 200),
      columnCount: 2,
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: ProductItem(
            productImage: product.primaryImage,
            productTag: product.tag,
            productName: locale.languageCode == 'ar'
                ? product.frProductName
                : product.enProductName,
            productDiscountPrice: product.discountPrice,
            productPrice: product.price,
            productOrigin: product.origin,
            productYear: product.year,
            productId: product.id,
            productInstallment: installment,
            productCategoryName:
                categoryName == getTranslated(context, 'tires')!
                    ? 'الإطارات'
                    : categoryName,
            productPattern: product.pattern,
            productWidth: product.width,
            productRimSize: product.rimSize,
            productRatio: product.ratio,
            productDiameter: product.diameter,
            productDescription: locale.languageCode == 'ar'
                ? product.frDescription
                : product.enDescription,
          ),
        ),
      ),
    );
  }
}
