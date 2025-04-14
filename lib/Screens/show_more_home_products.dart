import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Models/brands_model.dart';
import 'package:elite_tiers/Models/cart_model.dart';
import 'package:elite_tiers/Models/products_model.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Screens/home_product_details.dart';
import 'package:elite_tiers/Screens/home_screen.dart';
import 'package:elite_tiers/UI/styles/DesignConfig.dart';
import 'package:elite_tiers/UI/widgets/SimpleAppBar.dart';
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
  List<String> diameters = [
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24'
  ];
  List<String> ratios = [
    '10',
    '15',
    '20',
    '25',
    '30',
    '35',
    '40',
    '45',
    '50',
    '55',
    '60',
    '65',
    '70',
    '75',
    '80',
    '85',
    '90',
    '95',
    '100',
  ];
  List<String> widths = [
    '125',
    '135',
    '145',
    '155',
    '165',
    '175',
    '185',
    '195',
    '205',
    '215',
    '225',
    '235',
    '245',
    '255',
    '265',
    '275',
    '285',
    '295',
    '305',
    '315',
    '325',
    '335',
    '345',
    '355',
    '365'
  ];
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
                                              widget.categoryName != 'الإطارات')
                                            const SizedBox(height: 10),
                                          if (widget.categoryName == 'إطار' ||
                                              widget.categoryName == 'الإطارات')
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
                                                                        'diameter')!,
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
                                                                        'ratio')!,
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
                                                                        'width')!,
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
                                              widget.categoryName == 'الإطارات')
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
                ),
              ],
            ),
    );
  }

  Widget _productCard(BuildContext context, AllProducts product) {
    Locale locale = Localizations.localeOf(context);
    final double? discountPriceValue = double.tryParse(
        product.discountPrice.isNotEmpty
            ? product.discountPrice
            : product.price);
    final double installment = (discountPriceValue ?? 0) / 4;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primarytheme,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HomeProductDetails(
                                      id: product.id,
                                      categoryName: widget.categoryName ==
                                              getTranslated(context, 'tires')!
                                          ? 'الإطارات'
                                          : widget.categoryName,
                                      productImage: product.primaryImage,
                                      tag: product.tag,
                                      productName: locale.languageCode == 'ar'
                                          ? product.frProductName
                                          : product.enProductName,
                                      actualPrice:
                                          double.tryParse(product.price)
                                                  ?.toInt() ??
                                              0,
                                      discountedPrice:
                                          product.discountPrice.isNotEmpty
                                              ? double.tryParse(
                                                          product.discountPrice)
                                                      ?.toInt() ??
                                                  0
                                              : 0,
                                      origin: product.origin,
                                      yearOfProduction: product.year,
                                      pattern: product.pattern,
                                      width: product.width,
                                      rimSize: product.rimSize,
                                      ratio: product.ratio,
                                      diameter: product.diameter,
                                      description: locale.languageCode == 'ar'
                                          ? product.frDescription
                                          : product.enDescription,
                                    )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(product.primaryImage),
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
                                        product.tag,
                                        style: const TextStyle(
                                            color: Colors.white),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    locale.languageCode == 'ar'
                                        ? product.frProductName
                                        : product.enProductName,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //     'SAR ${product.discountPrice.toString()}',
                                      //     style: TextStyle(
                                      //       fontSize: 12,
                                      //       color: Theme.of(context)
                                      //           .colorScheme
                                      //           .primarytheme,
                                      //     )),
                                      Text(
                                          locale.languageCode == 'ar'
                                              ? product.discountPrice.toString()
                                              : 'SAR ${product.discountPrice.toString()}',
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
                                              product.discountPrice.isNotEmpty
                                                  ? 5
                                                  : 0),
                                      Text(product.price.toString(),
                                          style: TextStyle(
                                              decoration: product
                                                      .discountPrice.isNotEmpty
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontSize: 12,
                                              color: product
                                                      .discountPrice.isNotEmpty
                                                  ? Colors.red
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primarytheme)),
                                    ],
                                  ),
                                ),
                              ],
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
                                        installment.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(width: 3),
                                      Text(locale.languageCode == 'ar'
                                          ? 'ر.س'
                                          : 'SAR'),
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
                            const SizedBox(height: 5),
                            Container(
                              height: 0.5,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 5),
                            if (widget.categoryName ==
                                    getTranslated(context, 'tires')! ||
                                widget.categoryName.toLowerCase() == 'الإطارات')
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
                                    Text('${product.origin} | ${product.year}')
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primarytheme,
                        ),
                        onPressed: () {
                          if (isDemoApp) {
                            setSnackbar(
                              getTranslated(context, 'SIGNIN_DETAILS')!,
                              context,
                            );
                          } else {
                            bool productAdded = Provider.of<MyCartProvider>(
                                    context,
                                    listen: false)
                                .addItem(CartItem(
                              id: product.id,
                              image: product.primaryImage,
                              tag: product.tag,
                              title: locale.languageCode == 'ar'
                                  ? product.frProductName
                                  : product.enProductName,
                              actualPrice:
                                  double.tryParse(product.price)?.toInt() ?? 0,
                              discountedPrice: product.discountPrice.isNotEmpty
                                  ? double.tryParse(product.discountPrice)
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
                        },
                        child: FittedBox(
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle, size: 18),
                              SizedBox(width: 5),
                              Text(
                                getTranslated(context, 'ADD_CART2')!,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
