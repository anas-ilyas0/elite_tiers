import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Models/brands_model.dart';
import 'package:elite_tiers/Models/products_model.dart';
import 'package:elite_tiers/Providers/home_provider.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:elite_tiers/UI/widgets/SimpleAppBar.dart';
import 'package:elite_tiers/UI/widgets/product_item.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShowMoreHomeProducts extends StatefulWidget {
  final String categoryName;
  final List<AllProducts> productsList;
  final List<Brands> brandsList;

  const ShowMoreHomeProducts({
    required this.categoryName,
    required this.productsList,
    required this.brandsList,
    super.key,
  });

  @override
  State<ShowMoreHomeProducts> createState() => _ShowMoreHomeProductsState();
}

class _ShowMoreHomeProductsState extends State<ShowMoreHomeProducts> {
  String? selectedFrontDiameter;
  String? selectedFrontRatio;
  String? selectedFrontWidth;
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  late List<AllProducts> _filteredProducts;
  String? selectedBrandName;

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.productsList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      final minPrice =
          double.tryParse(_minPriceController.text) ?? double.negativeInfinity;
      final maxPrice =
          double.tryParse(_maxPriceController.text) ?? double.infinity;
      _filteredProducts = widget.productsList.where((product) {
        final productPrice = double.tryParse(product.discountPrice.isNotEmpty
                ? product.discountPrice
                : product.price) ??
            0.0;
        final matchesName = _searchController.text.isEmpty ||
            product.enProductName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            product.frProductName
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesDiameter = selectedFrontDiameter == null ||
            product.diameter == selectedFrontDiameter;
        final matchesRatio =
            selectedFrontRatio == null || product.ratio == selectedFrontRatio;
        final matchesWidth =
            selectedFrontWidth == null || product.width == selectedFrontWidth;
        final matchesPrice =
            productPrice >= minPrice && productPrice <= maxPrice;
        final matchesBrand =
            selectedBrandName == null || product.enBrand == selectedBrandName;
        return matchesName &&
            matchesDiameter &&
            matchesRatio &&
            matchesWidth &&
            matchesPrice &&
            matchesBrand;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    var provider = Provider.of<HomeProvider>(context);
    final allProducts = provider.allProducts;
    List<String> diameters = allProducts
        .map((product) => product.diameter)
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();

    List<String> ratios = allProducts
        .map((product) => product.ratio)
        .where((r) => r.isNotEmpty)
        .toSet()
        .toList();

    List<String> widths = allProducts
        .map((product) => product.width)
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();
    return Scaffold(
      appBar: getSimpleAppBar(widget.categoryName, context),
      body: widget.productsList.isEmpty
          ? Center(
              child: Text(getTranslated(context, 'no_product_found')!),
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _filterProducts(),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(
                                  15.0, 5.0, 8.0, 5.0),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50.0)),
                              ),
                              isDense: true,
                              hintText: getTranslated(context, 'searchHint')!,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                  ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  'assets/images/search.svg',
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context)
                                          .colorScheme
                                          .primarytheme,
                                      BlendMode.srcIn),
                                ),
                              ),
                              fillColor:
                                  Theme.of(context).colorScheme.lightWhite,
                              filled: true,
                            ),
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) {
                            String? tempSelectedDiameter =
                                selectedFrontDiameter;
                            String? tempSelectedRatio = selectedFrontRatio;
                            String? tempSelectedWidth = selectedFrontWidth;
                            return Dialog(
                              insetPadding: const EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setDialogState) {
                                  return SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'apply_filter')!,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          if (widget.categoryName != 'إطار' ||
                                              widget.categoryName !=
                                                  'الإطارات' ||
                                              widget.categoryName != 'Tire' ||
                                              widget.categoryName != 'Tires')
                                            const SizedBox(height: 10),
                                          if (widget.categoryName == 'إطار' ||
                                              widget.categoryName ==
                                                  'الإطارات' ||
                                              widget.categoryName == 'Tire' ||
                                              widget.categoryName == 'Tires')
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                        context, 'dimensions')!,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? Colors.black
                                                              .withValues(
                                                                  alpha: 0.1)
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .lightWhite,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  isExpanded:
                                                                      true,
                                                                  hint: Text(
                                                                    getTranslated(
                                                                        context,
                                                                        'rim_size')!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  value:
                                                                      tempSelectedDiameter,
                                                                  items: diameters.map<
                                                                      DropdownMenuItem<
                                                                          String>>((String
                                                                      value) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child:
                                                                          Text(
                                                                        value,
                                                                        style:
                                                                            TextStyle(
                                                                          color: Theme.of(context).brightness == Brightness.dark
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          newValue) {
                                                                    setDialogState(
                                                                        () {
                                                                      tempSelectedDiameter =
                                                                          newValue;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Expanded(
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  isExpanded:
                                                                      true,
                                                                  hint: Text(
                                                                    getTranslated(
                                                                        context,
                                                                        'height')!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  value:
                                                                      tempSelectedRatio,
                                                                  items: ratios.map<
                                                                      DropdownMenuItem<
                                                                          String>>((String
                                                                      value) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child:
                                                                          Text(
                                                                        value,
                                                                        style:
                                                                            TextStyle(
                                                                          color: Theme.of(context).brightness == Brightness.dark
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          newValue) {
                                                                    setDialogState(
                                                                        () {
                                                                      tempSelectedRatio =
                                                                          newValue;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Expanded(
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  isExpanded:
                                                                      true,
                                                                  hint: Text(
                                                                    getTranslated(
                                                                        context,
                                                                        'offer')!,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  value:
                                                                      tempSelectedWidth,
                                                                  items: widths.map<
                                                                      DropdownMenuItem<
                                                                          String>>((String
                                                                      value) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          value,
                                                                      child:
                                                                          Text(
                                                                        value,
                                                                        style:
                                                                            TextStyle(
                                                                          color: Theme.of(context).brightness == Brightness.dark
                                                                              ? Colors.white
                                                                              : Colors.black,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (String?
                                                                          newValue) {
                                                                    setDialogState(
                                                                        () {
                                                                      tempSelectedWidth =
                                                                          newValue;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (widget.categoryName == 'إطار' ||
                                              widget.categoryName ==
                                                  'الإطارات' ||
                                              widget.categoryName == 'Tire' ||
                                              widget.categoryName == 'Tires')
                                            const SizedBox(height: 20),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getTranslated(context,
                                                            'min_price')!,
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        height: 44,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .transparent)),
                                                        child: TextField(
                                                          controller:
                                                              _minPriceController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    15.0,
                                                                    5.0,
                                                                    8.0,
                                                                    5.0),
                                                            border:
                                                                const OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          50.0)),
                                                            ),
                                                            isDense: true,
                                                            hintText: getTranslated(
                                                                context,
                                                                'enter_min_price')!,
                                                            hintStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                ),
                                                          ),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getTranslated(context,
                                                            'max_price')!,
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        height: 44,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .transparent)),
                                                        child: TextField(
                                                          controller:
                                                              _maxPriceController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    15.0,
                                                                    5.0,
                                                                    8.0,
                                                                    5.0),
                                                            border:
                                                                const OutlineInputBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          50.0)),
                                                            ),
                                                            isDense: true,
                                                            hintText: getTranslated(
                                                                context,
                                                                'enter_max_price')!,
                                                            hintStyle: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall!
                                                                .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                ),
                                                          ),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getTranslated(
                                                      context, 'sel_brand')!,
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 120,
                                                  child: ListView.builder(
                                                    itemCount: widget
                                                        .brandsList.length,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (context, index) {
                                                      final brand = widget
                                                          .brandsList[index];
                                                      final brandName =
                                                          locale.languageCode ==
                                                                  'ar'
                                                              ? brand
                                                                  .frBrandName
                                                              : brand
                                                                  .enBrandName;
                                                      return GestureDetector(
                                                        onTap: () {
                                                          setDialogState(() {
                                                            if (selectedBrandName ==
                                                                brandName) {
                                                              selectedBrandName =
                                                                  null;
                                                            } else {
                                                              selectedBrandName =
                                                                  brandName;
                                                            }
                                                          });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .only(
                                                                  end: 17),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .only(
                                                                      bottom:
                                                                          5.0,
                                                                      top: 8.0),
                                                                  child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Theme.of(context).brightness ==
                                                                                Brightness.dark
                                                                            ? Colors.white
                                                                            : Colors.grey.withValues(alpha: 0.2),
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Theme.of(context).colorScheme.fontColor.withValues(alpha: 0.048),
                                                                            spreadRadius:
                                                                                2,
                                                                            blurRadius:
                                                                                13,
                                                                            offset:
                                                                                const Offset(0, 0),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: CircleAvatar(
                                                                          radius: 32.0,
                                                                          backgroundColor: selectedBrandName == brandName ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                                                          child: ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(32),
                                                                            child: networkImageCommon(
                                                                                widget.brandsList[index].brandImage,
                                                                                60,
                                                                                width: double.maxFinite,
                                                                                height: double.maxFinite,
                                                                                false),
                                                                          )))),
                                                              Text(
                                                                locale.languageCode ==
                                                                        'ar'
                                                                    ? capitalize(widget
                                                                        .brandsList[
                                                                            index]
                                                                        .frBrandName
                                                                        .toLowerCase())
                                                                    : capitalize(widget
                                                                        .brandsList[
                                                                            index]
                                                                        .enBrandName
                                                                        .toLowerCase()),
                                                                maxLines: 2,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .fontColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            12),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    selectedFrontDiameter =
                                                        tempSelectedDiameter;
                                                    selectedFrontRatio =
                                                        tempSelectedRatio;
                                                    selectedFrontWidth =
                                                        tempSelectedWidth;
                                                    _filterProducts();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text(getTranslated(
                                                    context, 'search')!),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        child: const Icon(Icons.tune_outlined, size: 30),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: (_filteredProducts.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      int firstIndex = index * 2;
                      int secondIndex = firstIndex + 1;
                      final firstProduct = _filteredProducts[firstIndex];
                      final secondProduct =
                          secondIndex < _filteredProducts.length
                              ? _filteredProducts[secondIndex]
                              : null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _productCard(
                                    context, firstProduct, firstIndex),
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
                ),
              ],
            ),
    );
  }

  Widget _productCard(BuildContext context, AllProducts product, int index) {
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
                widget.categoryName == getTranslated(context, 'tires')!
                    ? 'الإطارات'
                    : widget.categoryName,
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
