import 'package:elite_tiers/UI/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/products_model.dart';
import '../Providers/home_provider.dart';
import 'package:elite_tiers/Helpers/Session.dart';

class SearchProductsScreen extends StatefulWidget {
  final List<ProductsCategories> allCategories;
  const SearchProductsScreen({super.key, required this.allCategories});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  late List<AllProducts> allProducts;
  List<AllProducts> filteredProducts = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<HomeProvider>(context, listen: false);
    allProducts = provider.allProducts;
    filteredProducts = List.from(allProducts);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  final _focusNode = FocusNode();

  void onSearchChanged(String query) {
    setState(() {
      filteredProducts = allProducts
          .where((p) =>
              p.enProductName.toLowerCase().contains(query.toLowerCase()) ||
              p.frProductName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _focusNode,
          controller: searchController,
          onChanged: onSearchChanged,
          cursorColor: Colors.white,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: getTranslated(context, 'searchHint')!,
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              onSearchChanged('');
              FocusScope.of(context).unfocus();
            },
          ),
        ],
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
                          child: _productCard(context, firstProduct),
                        ),
                        if (secondProduct != null)
                          Expanded(
                            child: _productCard(context, secondProduct),
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

  Widget _productCard(BuildContext context, AllProducts product) {
    final category = widget.allCategories.firstWhere(
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

    return ProductItem(
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
      productCategoryName: categoryName == getTranslated(context, 'tires')!
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
    );
  }
}
