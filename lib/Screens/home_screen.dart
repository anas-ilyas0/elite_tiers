import 'dart:async';
import 'package:elite_tiers/Helpers/ApiBaseHelper.dart';
import 'package:elite_tiers/Helpers/Color.dart';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Helpers/Session.dart';
import 'package:elite_tiers/Helpers/String.dart';
import 'package:elite_tiers/Models/cart_model.dart';
import 'package:elite_tiers/Models/category_model.dart';
import 'package:elite_tiers/Models/products_model.dart';
import 'package:elite_tiers/Providers/HomeProvider.dart';
import 'package:elite_tiers/Providers/cart_provider.dart';
import 'package:elite_tiers/Screens/home_product_details.dart';
import 'package:elite_tiers/Screens/show_more_home_products.dart';
import 'package:elite_tiers/UI/widgets/AppBtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../ui/styles/DesignConfig.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class PaymentOptions {
  static const Map<String, String> images = {
    'tabby': 'assets/images/tabby.png',
    'tamara': 'assets/images/tamara.png',
  };
}

ApiBaseHelper apiBaseHelper = ApiBaseHelper();

String? _selectedCategoryName;
String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('MMM dd, yyyy');
  return formatter.format(date);
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final productsSearchController = TextEditingController();

  final ScrollController _scrollBottomBarController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  double beginAnim = 0.0;
  double endAnim = 1.0;
  String? selectedFrontDiameter;
  String? selectedFrontRatio;
  String? selectedFrontWidth;
  String? selectedRearDiameter;
  String? selectedRearRatio;
  String? selectedRearWidth;
  List<String> diameters = [
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
    '90'
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
  bool isChecked = false;
  List<AllProducts> productsList = [];
  late List<AllProducts> _filteredProducts;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _filteredProducts = productsList;
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    _controller.dispose();
    buttonController.dispose();
    super.dispose();
  }

  void filteredProducts() {
    setState(() {
      _filteredProducts = productsList.where((product) {
        final matchesName = productsSearchController.text.isEmpty ||
            product.enProductName
                .toLowerCase()
                .contains(productsSearchController.text.toLowerCase()) ||
            product.frProductName
                .toLowerCase()
                .contains(productsSearchController.text.toLowerCase());
        return matchesName;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<HomeProvider>(context);
    final dynamicCategories = provider.categories; // List<ProductsCategories>
    List<CategoryData> categories = provider.catList;

    List<DropdownMenuItem<String>> dropdownItems = dynamicCategories
        .map((dCategory) => DropdownMenuItem<String>(
              value: dCategory.name,
              child: Text(
                dCategory.name,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontSize: 12),
              ),
            ))
        .toList();

    super.build(context);
    hideAppbarAndBottomBarOnScroll(_scrollBottomBarController, context);
    if (_selectedCategoryName == null && categories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedCategoryName = categories.first.frCategoryName;
        });
      });
    }
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        body: _isNetworkAvail
            ? RefreshIndicator(
                color: Theme.of(context).colorScheme.primarytheme,
                key: _refreshIndicatorKey,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: _scrollBottomBarController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _getSearchBar(),
                      _brandsList(context),
                      _slider(),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          getTranslated(context, 'frame_size')!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xff22A4BE)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                getTranslated(context, 'size_difference')!,
                              ),
                            ),
                            Checkbox(
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isChecked = newValue!;
                                });
                              },
                              activeColor: const Color(0xff22A4BE),
                              checkColor: Colors.white,
                              tristate: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black.withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.lightWhite,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    getTranslated(context, 'front_tire_size')!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          getTranslated(context, 'diameter')!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        value: selectedFrontDiameter,
                                        items: diameters
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedFrontDiameter = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          getTranslated(context, 'ratio')!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        value: selectedFrontRatio,
                                        items: ratios
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                )),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedFrontRatio = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          getTranslated(context, 'width')!,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        value: selectedFrontWidth,
                                        items: widths
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                )),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedFrontWidth = newValue;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                if (isChecked)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      getTranslated(context, 'rear_tire_size')!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                if (isChecked)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            getTranslated(context, 'diameter')!,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          value: selectedRearDiameter,
                                          items: diameters
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedRearDiameter = newValue;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            getTranslated(context, 'ratio')!,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          value: selectedRearRatio,
                                          items: ratios
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  )),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedRearRatio = newValue;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            getTranslated(context, 'width')!,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          value: selectedRearWidth,
                                          items: widths
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  )),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedRearWidth = newValue;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ElevatedButton(
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, 'search')!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 10),
                                SvgPicture.asset(
                                  'assets/images/search.svg',
                                  colorFilter: ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                )
                              ],
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          getTranslated(context, 'categories')!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      _catList(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                getTranslated(context, 'featured_categories')!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  borderRadius: BorderRadius.circular(7)),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                  child: DropdownButton<String>(
                                    underline: Container(),
                                    isDense: true,
                                    value: _selectedCategoryName,
                                    hint: Text(
                                      getTranslated(
                                          context,
                                          provider.catLoading
                                              ? 'loading'
                                              : 'sel_category')!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    items: dropdownItems,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCategoryName = newValue;
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      _featuredBrands(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, 'deal_of_day')!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            _productDeal(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'tires')!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                final allProducts = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .tiresList
                                    .expand((category) => category.products)
                                    .toList();
                                final brandsList = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .brandsList;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ShowMoreHomeProducts(
                                              categoryName: getTranslated(
                                                  context, 'tires')!,
                                              productsList: allProducts,
                                              brandsList: brandsList,
                                            )));
                              },
                              child: Text(
                                getTranslated(context, 'show_more')!,
                                style:
                                    const TextStyle(color: Color(0xff22A4BE)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _tiresList(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'oil')!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                final allProducts = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .oilList
                                    .expand((category) => category.products)
                                    .toList();
                                final brandsList = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .brandsList;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ShowMoreHomeProducts(
                                              categoryName: getTranslated(
                                                  context, 'oil')!,
                                              productsList: allProducts,
                                              brandsList: brandsList,
                                            )));
                              },
                              child: Text(
                                getTranslated(context, 'show_more')!,
                                style:
                                    const TextStyle(color: Color(0xff22A4BE)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _oilList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'cleaners')!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                final allProducts = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .cleanersList
                                    .expand((category) => category.products)
                                    .toList();
                                final brandsList = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .brandsList;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ShowMoreHomeProducts(
                                            categoryName: getTranslated(
                                                context, 'cleaners')!,
                                            productsList: allProducts,
                                            brandsList: brandsList)));
                              },
                              child: Text(
                                getTranslated(context, 'show_more')!,
                                style:
                                    const TextStyle(color: Color(0xff22A4BE)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _cleanersList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, 'batteries')!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                final allProducts = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .batteriesList
                                    .expand((category) => category.products)
                                    .toList();
                                final brandsList = Provider.of<HomeProvider>(
                                        context,
                                        listen: false)
                                    .brandsList;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ShowMoreHomeProducts(
                                            categoryName: getTranslated(
                                                context, 'batteries')!,
                                            productsList: allProducts,
                                            brandsList: brandsList)));
                              },
                              child: Text(
                                getTranslated(context, 'show_more')!,
                                style:
                                    const TextStyle(color: Color(0xff22A4BE)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _batteriesList(),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 12, vertical: 5),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         getTranslated(context, 'latest_news')!,
                      //         style: const TextStyle(
                      //             fontWeight: FontWeight.bold, fontSize: 16),
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           final allBlogs = Provider.of<HomeProvider>(
                      //                   context,
                      //                   listen: false)
                      //               .blogsList;
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (_) => ShowMoreBlogs(
                      //                       name: getTranslated(
                      //                           context, 'blogs')!,
                      //                       blogsList: allBlogs)));
                      //         },
                      //         child: Text(
                      //           getTranslated(context, 'show_more')!,
                      //           style:
                      //               const TextStyle(color: Color(0xff22A4BE)),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // _blogsList(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ))
            : noInternet(context));
  }

  _slider() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    height: 133,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/sliderCar.png'))),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      getTranslated(context, 'motto')!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )),
                const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  _brandsList(context) {
    Locale locale = Localizations.localeOf(context);
    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.brandsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()),
          );
        } else {
          final brands =
              Provider.of<HomeProvider>(context, listen: false).brandsList;
          return Container(
            height: 120,
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: ListView.builder(
              itemCount: brands.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 17),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsetsDirectional.only(
                              bottom: 5.0, top: 8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.grey.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withValues(alpha: 0.048),
                                    spreadRadius: 2,
                                    blurRadius: 13,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                  radius: 32.0,
                                  backgroundColor: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: networkImageCommon(
                                        brands[index].brandImage,
                                        60,
                                        width: double.maxFinite,
                                        height: double.maxFinite,
                                        false),
                                  )))),
                      Expanded(
                        child: Text(
                          locale.languageCode == 'ar'
                              ? capitalize(
                                  brands[index].frBrandName.toLowerCase())
                              : capitalize(
                                  brands[index].enBrandName.toLowerCase()),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  _catList(context) {
    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.isProductsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()),
          );
        } else {
          final categories =
              Provider.of<HomeProvider>(context, listen: false).categoriesList;
          final brandsList =
              Provider.of<HomeProvider>(context, listen: false).brandsList;
          return Container(
            height: 120,
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: ListView.builder(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 17),
                  child: GestureDetector(
                    onTap: () {
                      final selectedCategoryName = categories[index]['name']!;
                      final selectedProducts =
                          (categories[index]['products'] as List)
                              .map((product) => AllProducts(
                                    id: product['id']!,
                                    enProductName: product['en_Product_Name']!,
                                    frProductName: product['fr_Product_Name']!,
                                    price: product['price']!,
                                    primaryImage: product['primary_image']!,
                                    enBrand: product['en_brand']!,
                                    frBrand: product['fr_brand']!,
                                    //sku: product['sku']!,
                                    discountPrice: product['discount_price']!,
                                    tag: product['tag']!,
                                    origin: product['origin']!,
                                    year: product['year']!,
                                    width: product['width']!,
                                    ratio: product['ratio']!,
                                    pattern: product['pattern']!,
                                    rimSize: product['rim_size']!,
                                    enDescription: product['en_Description']!,
                                    frDescription: product['fr_Description']!,
                                    diameter: product['diameter']!,
                                    createdAt: product['created_at'],
                                    updatedAt: product['updated_at'],
                                  ))
                              .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowMoreHomeProducts(
                            categoryName: selectedCategoryName.toString(),
                            productsList: selectedProducts,
                            brandsList: brandsList,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsetsDirectional.only(
                                bottom: 5.0, top: 8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withValues(alpha: 0.048),
                                      spreadRadius: 2,
                                      blurRadius: 13,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                    radius: 32.0,
                                    backgroundColor: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(32),
                                      child: networkImageCommon(
                                          categories[index]['image']! as String,
                                          60,
                                          width: double.maxFinite,
                                          height: double.maxFinite,
                                          false),
                                    )))),
                        Expanded(
                          child: Text(
                            capitalize(categories[index]['name']! as String),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  List<AllProducts> getProductsList(
      BuildContext context, String? selectedCategoryName) {
    final categories =
        Provider.of<HomeProvider>(context, listen: false).categories;
    if (selectedCategoryName == null) return [];
    final category = categories.firstWhere(
      (cat) => cat.name == selectedCategoryName,
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
    return category.products;
  }

  Widget _productCard(
      BuildContext context, AllProducts product, String categoryName) {
    Locale locale = Localizations.localeOf(context);
    double? discountPriceValue = double.tryParse(
        product.discountPrice.isNotEmpty
            ? product.discountPrice
            : product.price);
    double installment = (discountPriceValue ?? 0) / 4;
    final discountPrice = product.discountPrice.toString();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 150,
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
                              categoryName: categoryName,
                              productImage: product.primaryImage,
                              tag: product.tag,
                              productName: locale.languageCode == 'ar'
                                  ? product.frProductName
                                  : product.enProductName,
                              actualPrice:
                                  double.tryParse(product.price)?.toInt() ?? 0,
                              discountedPrice: product.discountPrice.isNotEmpty
                                  ? double.tryParse(product.discountPrice)
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
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: product.primaryImage.isNotEmpty
                                  ? NetworkImage(product.primaryImage)
                                  : AssetImage('assets/images/noimage.png'),
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
                                fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FittedBox(
                          child: Row(
                            children: [
                              Text(
                                  locale.languageCode == 'ar'
                                      ? discountPrice
                                      : 'SAR $discountPrice',
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
                                      product.discountPrice.isNotEmpty ? 5 : 0),
                              Text(product.price.toString(),
                                  style: TextStyle(
                                      decoration:
                                          product.discountPrice.isNotEmpty
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                      fontSize: 12,
                                      color: product.discountPrice.isNotEmpty
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
                            color: Theme.of(context).colorScheme.primarytheme)),
                    const SizedBox(height: 5),
                    Container(
                      height: 0.5,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        FittedBox(
                          child: Row(
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
                              Text(
                                locale.languageCode == 'ar' ? 'ر.س' : 'SAR',
                                style: const TextStyle(fontSize: 12),
                              )
                            ],
                          ),
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
                    const SizedBox(height: 5),
                    if (_selectedCategoryName == 'الإطارات')
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
                            SizedBox(width: 20),
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
                  backgroundColor: Theme.of(context).colorScheme.primarytheme,
                ),
                onPressed: () {
                  if (isDemoApp) {
                    setSnackbar(
                      getTranslated(context, 'SIGNIN_DETAILS')!,
                      context,
                    );
                  } else {
                    bool productAdded =
                        Provider.of<MyCartProvider>(context, listen: false)
                            .addItem(CartItem(
                      id: product.id,
                      image: product.primaryImage,
                      tag: product.tag,
                      title: locale.languageCode == 'ar'
                          ? product.frProductName
                          : product.enProductName,
                      actualPrice: double.tryParse(product.price)?.toInt() ?? 0,
                      discountedPrice: product.discountPrice.isNotEmpty
                          ? double.tryParse(product.discountPrice)?.toInt() ?? 0
                          : 0,
                    ));
                    if (productAdded) {
                      setSnackbar(
                          getTranslated(context, 'product_added_to_cart')!,
                          context);
                    } else {
                      setSnackbar(
                          getTranslated(context, 'product_already_in_cart')!,
                          context);
                    }
                  }
                },
                child: FittedBox(
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, size: 18),
                      SizedBox(width: 10),
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
    );
  }

  Widget _featuredBrands() {
    var categoryName = _selectedCategoryName;

    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.productsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: catLoading(),
            ),
          );
        } else {
          List<AllProducts> productsList =
              getProductsList(context, categoryName);
          if (productsList.isEmpty) {
            return Center(
                child: Text(getTranslated(context, 'no_product_found')!));
          }
          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    productsList.length > 3 ? 3 : productsList.length,
                    (index) {
                      return _productCard(
                        context,
                        productsList[index],
                        categoryName ?? '',
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  _productDeal() {
    Locale locale = Localizations.localeOf(context);
    bool isRtl(context) {
      return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
    }

    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.dealLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: catLoading(),
            ),
          );
        } else {
          final dealList =
              Provider.of<HomeProvider>(context, listen: false).dealList;
          var categoryName =
              dealList.map((productDeal) => productDeal.category).join(', ');
          return IntrinsicHeight(
            child: Column(
              children: List.generate(dealList.length, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HomeProductDetails(
                              categoryName: categoryName.toString(),
                              id: dealList[index].id,
                              productImage: dealList[index].primaryImage,
                              tag: dealList[index].tag,
                              productName: locale.languageCode == 'ar'
                                  ? dealList[index].frProductName
                                  : dealList[index].enProductName,
                              actualPrice:
                                  double.tryParse(dealList[index].price)
                                          ?.toInt() ??
                                      0,
                              discountedPrice:
                                  double.tryParse(dealList[index].discountPrice)
                                          ?.toInt() ??
                                      0,
                              origin: dealList[index].origin,
                              yearOfProduction: dealList[index].year,
                              pattern: dealList[index].pattern,
                              width: dealList[index].width,
                              rimSize: dealList[index].rimSize,
                              ratio: dealList[index].ratio,
                              diameter: dealList[index].diameter,
                              description: locale.languageCode == 'ar'
                                  ? dealList[index].frDescription
                                  : dealList[index].enDescription)),
                    );
                  },
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
                        Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Container(
                                              height: 170,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: dealList[index]
                                                          .primaryImage
                                                          .isNotEmpty
                                                      ? NetworkImage(
                                                          dealList[index]
                                                              .primaryImage)
                                                      : AssetImage(
                                                          'assets/images/noimage.png'),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: isRtl(context) ? null : 5,
                                            right: isRtl(context) ? 5 : null,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(1.0),
                                                child: FittedBox(
                                                  child: Center(
                                                    child: Text(
                                                      dealList[index].tag,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 7),
                                            RatingBar.builder(
                                              glow: true,
                                              initialRating: 3,
                                              minRating: 1,
                                              itemSize: 20,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                size: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              onRatingUpdate: (rating) {},
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                locale.languageCode == 'ar'
                                                    ? dealList[index]
                                                        .frProductName
                                                    : dealList[index]
                                                        .enProductName,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            FittedBox(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    dealList[index]
                                                            .discountPrice
                                                            .isNotEmpty
                                                        ? locale.languageCode ==
                                                                'ar'
                                                            ? '${dealList[index].discountPrice} ر.س'
                                                            : 'SAR ${dealList[index].discountPrice}'
                                                        : locale.languageCode ==
                                                                'ar'
                                                            ? '${dealList[index].price} ر.س'
                                                            : 'SAR ${dealList[index].price}',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xff22A4BE),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                      width: dealList[index]
                                                              .discountPrice
                                                              .isNotEmpty
                                                          ? 7
                                                          : 0),
                                                  if (dealList[index]
                                                      .discountPrice
                                                      .isNotEmpty)
                                                    Text(
                                                      dealList[index].price,
                                                      style: TextStyle(
                                                          decoration: dealList[
                                                                      index]
                                                                  .discountPrice
                                                                  .isNotEmpty
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                          color: dealList[index]
                                                                  .discountPrice
                                                                  .isNotEmpty
                                                              ? Colors.grey
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              getTranslated(
                                                  context, 'tax_included')!,
                                              style: const TextStyle(
                                                  color: Color(0xff22A4BE),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: locale.languageCode ==
                                                          'ar'
                                                      ? 0
                                                      : 33,
                                                  left: locale.languageCode ==
                                                          'ar'
                                                      ? 33
                                                      : 0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (isDemoApp) {
                                                    setSnackbar(
                                                      getTranslated(context,
                                                          'SIGNIN_DETAILS')!,
                                                      context,
                                                    );
                                                  } else {
                                                    bool productAdded = Provider
                                                            .of<MyCartProvider>(
                                                                context,
                                                                listen: false)
                                                        .addItem(CartItem(
                                                      id: dealList[index].id,
                                                      image: dealList[index]
                                                          .primaryImage,
                                                      tag: dealList[index].tag,
                                                      title:
                                                          locale.languageCode ==
                                                                  'ar'
                                                              ? dealList[index]
                                                                  .frProductName
                                                              : dealList[index]
                                                                  .enProductName,
                                                      actualPrice: double.tryParse(
                                                                  dealList[
                                                                          index]
                                                                      .price)
                                                              ?.toInt() ??
                                                          0,
                                                      discountedPrice: dealList[
                                                                  index]
                                                              .discountPrice
                                                              .isNotEmpty
                                                          ? double.tryParse(dealList[
                                                                          index]
                                                                      .discountPrice)
                                                                  ?.toInt() ??
                                                              0
                                                          : 0,
                                                    ));
                                                    if (productAdded) {
                                                      setSnackbar(
                                                          getTranslated(context,
                                                              'product_added_to_cart')!,
                                                          context);
                                                    } else {
                                                      setSnackbar(
                                                          getTranslated(context,
                                                              'product_already_in_cart')!,
                                                          context);
                                                    }
                                                  }
                                                },
                                                child: FittedBox(
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.add_circle,
                                                          size: 18),
                                                      const SizedBox(width: 5),
                                                      Text(getTranslated(
                                                          context,
                                                          'ADD_CART2')!)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            FittedBox(
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getTranslated(context,
                                                            'units_sold')!,
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                      Text(
                                                        getTranslated(context,
                                                            'available')!,
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 28),
                                                  const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('10'),
                                                      Text('334'),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 2,
                              left: isRtl(context) ? 6 : null,
                              right: isRtl(context) ? null : 6,
                              child: Row(
                                children: [
                                  Text(getTranslated(context, 'sec')!),
                                  const SizedBox(width: 5),
                                  Text(getTranslated(context, 'mins')!),
                                  const SizedBox(width: 5),
                                  Text(getTranslated(context, 'hours')!),
                                  const SizedBox(width: 5),
                                  Text(getTranslated(context, 'days')!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }
      },
    );
  }

  // _blogsList() {
  //   Locale locale = Localizations.localeOf(context);
  //   bool isRtl(context) {
  //     return ['ar', 'he', 'fa', 'ur'].contains(locale.languageCode);
  //   }

  //   return Selector<HomeProvider, bool>(
  //       selector: (_, provider) => provider.blogsLoading,
  //       builder: (context, isLoading, child) {
  //         if (isLoading) {
  //           return SizedBox(
  //             width: double.infinity,
  //             child: Shimmer.fromColors(
  //                 baseColor: Theme.of(context).colorScheme.simmerBase,
  //                 highlightColor: Theme.of(context).colorScheme.simmerHigh,
  //                 child: catLoading()),
  //           );
  //         } else {
  //           final blogsList =
  //               Provider.of<HomeProvider>(context, listen: false).blogsList;
  //           return SizedBox(
  //             width: double.infinity,
  //             child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: IntrinsicHeight(
  //                 child: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: List.generate(
  //                         blogsList.length > 3 ? 3 : blogsList.length, (index) {
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12),
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                             color: Theme.of(context).brightness ==
  //                                     Brightness.dark
  //                                 ? null
  //                                 : Colors.blueGrey.withValues(alpha: 0.2),
  //                             borderRadius: BorderRadius.circular(10),
  //                           ),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Stack(
  //                                 children: [
  //                                   GestureDetector(
  //                                     onTap: () {
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                             builder: (_) => BlogDetails(
  //                                                   name: locale.languageCode ==
  //                                                           'ar'
  //                                                       ? blogsList[index]
  //                                                           .frTitle
  //                                                       : blogsList[index]
  //                                                           .enTitle,
  //                                                   tag: 'Hot Collection',
  //                                                   image: blogsList[index]
  //                                                       .smallImage,
  //                                                   date: formatDate(
  //                                                       blogsList[index]
  //                                                           .createdAt),
  //                                                   title: capitalize(
  //                                                     locale.languageCode ==
  //                                                             'ar'
  //                                                         ? blogsList[index]
  //                                                             .frTitle
  //                                                         : blogsList[index]
  //                                                             .enTitle,
  //                                                   ),
  //                                                   shortDesc: capitalize(
  //                                                     locale.languageCode ==
  //                                                             'ar'
  //                                                         ? capitalize(blogsList[
  //                                                                 index]
  //                                                             .frDescriptionOne
  //                                                             .toLowerCase())
  //                                                         : blogsList[index]
  //                                                             .enDescriptionOne
  //                                                             .toLowerCase(),
  //                                                   ),
  //                                                   longDesc: capitalize(
  //                                                     locale.languageCode ==
  //                                                             'ar'
  //                                                         ? capitalize(blogsList[
  //                                                                 index]
  //                                                             .frDescriptionTwo
  //                                                             .toLowerCase())
  //                                                         : blogsList[index]
  //                                                             .enDescriptionTwo
  //                                                             .toLowerCase(),
  //                                                   ),
  //                                                 )),
  //                                       );
  //                                     },
  //                                     child: Container(
  //                                       height: 200,
  //                                       width: 340,
  //                                       decoration: BoxDecoration(
  //                                         image: DecorationImage(
  //                                             fit: BoxFit.fill,
  //                                             image: NetworkImage(
  //                                                 blogsList[index].smallImage)),
  //                                         borderRadius: const BorderRadius.only(
  //                                           topLeft: Radius.circular(10),
  //                                           topRight: Radius.circular(10),
  //                                           bottomLeft: Radius.zero,
  //                                           bottomRight: Radius.zero,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Positioned(
  //                                     top: 5,
  //                                     right: isRtl(context) ? 5 : null,
  //                                     left: isRtl(context) ? null : 5,
  //                                     child: Container(
  //                                       decoration: BoxDecoration(
  //                                         color: Theme.of(context)
  //                                             .colorScheme
  //                                             .primary,
  //                                         borderRadius:
  //                                             BorderRadius.circular(6),
  //                                       ),
  //                                       child: const Padding(
  //                                         padding: EdgeInsets.all(4.0),
  //                                         child: Center(
  //                                           child: Text(
  //                                             'Hot Collection',
  //                                             style: TextStyle(
  //                                                 color: Colors.white),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                               Padding(
  //                                 padding: const EdgeInsets.all(7),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(formatDate(
  //                                         blogsList[index].createdAt)),
  //                                     const SizedBox(height: 5),
  //                                     Text(capitalize(
  //                                         locale.languageCode == 'ar'
  //                                             ? blogsList[index].frTitle
  //                                             : blogsList[index].enTitle)),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     })),
  //               ),
  //             ),
  //           );
  //         }
  //       });
  // }

  _tiresList() {
    Locale locale = Localizations.localeOf(context);
    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.productsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: catLoading(),
            ),
          );
        } else {
          final searchQuery =
              Provider.of<HomeProvider>(context, listen: false).searchQuery;
          final tiresList =
              Provider.of<HomeProvider>(context, listen: false).tiresList;
          final filteredProducts = tiresList
              .expand((tires) => tires.products)
              .where((product) => product.enProductName
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();
          if (filteredProducts.isEmpty) {
            return Center(
              child: Text(
                getTranslated(context, 'no_product_found')!,
              ),
            );
          } else {
            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      filteredProducts.length > 3 ? 3 : filteredProducts.length,
                      (index) {
                        var product = filteredProducts[index];
                        var categoryName = tiresList
                            .map((category) => category.name)
                            .join(", ");
                        double? discountPriceValue = double.tryParse(
                            product.discountPrice.isNotEmpty
                                ? product.discountPrice
                                : product.price);
                        double installment = (discountPriceValue ?? 0) / 4;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.primarytheme,
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
                                                  categoryName:
                                                      categoryName.toString(),
                                                  productImage:
                                                      product.primaryImage,
                                                  tag: product.tag,
                                                  productName: locale
                                                              .languageCode ==
                                                          'ar'
                                                      ? product.frProductName
                                                      : product.enProductName,
                                                  actualPrice: double.tryParse(
                                                              product.price)
                                                          ?.toInt() ??
                                                      0,
                                                  discountedPrice: product
                                                          .discountPrice
                                                          .isNotEmpty
                                                      ? double.tryParse(product
                                                                  .discountPrice)
                                                              ?.toInt() ??
                                                          0
                                                      : 0,
                                                  origin: product.origin,
                                                  yearOfProduction:
                                                      product.year,
                                                  pattern: product.pattern,
                                                  width: product.width,
                                                  rimSize: product.rimSize,
                                                  ratio: product.ratio,
                                                  diameter: product.diameter,
                                                  description: locale
                                                              .languageCode ==
                                                          'ar'
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
                                                  image: NetworkImage(
                                                      product.primaryImage),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(2),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                locale.languageCode == 'ar'
                                                    ? product.frProductName
                                                    : product.enProductName,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            FittedBox(
                                              child: Row(
                                                children: [
                                                  Text(
                                                      locale.languageCode ==
                                                              'ar'
                                                          ? product
                                                              .discountPrice
                                                              .toString()
                                                          : 'SAR ${product.discountPrice.toString()}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primarytheme,
                                                      )),
                                                  if (locale.languageCode ==
                                                      'ar')
                                                    SizedBox(width: 3),
                                                  if (locale.languageCode ==
                                                      'ar')
                                                    Text('ر.س',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primarytheme,
                                                        )),
                                                  SizedBox(
                                                      width: product
                                                              .discountPrice
                                                              .isNotEmpty
                                                          ? 5
                                                          : 0),
                                                  Text(product.price.toString(),
                                                      style: TextStyle(
                                                          decoration: product
                                                                  .discountPrice
                                                                  .isNotEmpty
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                          fontSize: 12,
                                                          color: product
                                                                  .discountPrice
                                                                  .isNotEmpty
                                                              ? Colors.red
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primarytheme)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                            getTranslated(
                                                context, 'tax_included')!,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                        context, 'monthly')!,
                                                  ),
                                                  Text(
                                                    installment
                                                        .toStringAsFixed(1),
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(locale.languageCode ==
                                                          'ar'
                                                      ? 'ر.س'
                                                      : 'SAR')
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                        context, 'in')!,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  const Text(
                                                    '4',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    getTranslated(context,
                                                        'installments')!,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: PaymentOptions
                                              .images.entries
                                              .map((entry) => Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
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
                                        FittedBox(
                                          child: Row(
                                            children: [
                                              Image(
                                                height: 20,
                                                width: 30,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                                image: const AssetImage(
                                                    'assets/images/smallcar.png'),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                  '${product.origin} | ${product.year}')
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primarytheme,
                                    ),
                                    onPressed: () {
                                      if (isDemoApp) {
                                        setSnackbar(
                                          getTranslated(
                                              context, 'SIGNIN_DETAILS')!,
                                          context,
                                        );
                                      } else {
                                        bool productAdded =
                                            Provider.of<MyCartProvider>(context,
                                                    listen: false)
                                                .addItem(CartItem(
                                          id: product.id,
                                          image: product.primaryImage,
                                          tag: product.tag,
                                          title: locale.languageCode == 'ar'
                                              ? product.frProductName
                                              : product.enProductName,
                                          actualPrice:
                                              double.tryParse(product.price)
                                                      ?.toInt() ??
                                                  0,
                                          discountedPrice: product
                                                  .discountPrice.isNotEmpty
                                              ? double.tryParse(
                                                          product.discountPrice)
                                                      ?.toInt() ??
                                                  0
                                              : 0,
                                        ));
                                        if (productAdded) {
                                          setSnackbar(
                                              getTranslated(context,
                                                  'product_added_to_cart')!,
                                              context);
                                        } else {
                                          setSnackbar(
                                              getTranslated(context,
                                                  'product_already_in_cart')!,
                                              context);
                                        }
                                      }
                                    },
                                    child: FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.add_circle,
                                              size: 18),
                                          SizedBox(width: 5),
                                          Text(
                                            getTranslated(
                                                context, 'ADD_CART2')!,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  _oilList() {
    Locale locale = Localizations.localeOf(context);
    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.productsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: catLoading(),
            ),
          );
        } else {
          final oilList =
              Provider.of<HomeProvider>(context, listen: false).oilList;
          if (oilList.isEmpty ||
              oilList.every((category) => category.products.isEmpty)) {
            return Center(
              child: Text(
                getTranslated(context, 'no_product_found')!,
              ),
            );
          }
          var allProducts =
              oilList.expand((category) => category.products).toList();
          var categoryName = oilList.map((oil) => oil.name).join(", ");
          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    allProducts.length > 3 ? 3 : allProducts.length,
                    (index) {
                      var product = allProducts[index];
                      double? discountPriceValue = double.tryParse(
                          product.discountPrice.isNotEmpty
                              ? product.discountPrice
                              : product.price);
                      double installment = (discountPriceValue ?? 0) / 4;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 150,
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
                                                categoryName:
                                                    categoryName.toString(),
                                                productImage:
                                                    product.primaryImage,
                                                tag: product.tag,
                                                productName:
                                                    locale.languageCode == 'ar'
                                                        ? product.frProductName
                                                        : product.enProductName,
                                                actualPrice: double.tryParse(
                                                            product.price)
                                                        ?.toInt() ??
                                                    0,
                                                discountedPrice: product
                                                        .discountPrice
                                                        .isNotEmpty
                                                    ? double.tryParse(product
                                                                .discountPrice)
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
                                                description:
                                                    locale.languageCode == 'ar'
                                                        ? product.frDescription
                                                        : product.enDescription,
                                              )));
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 6, 8, 2),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 100,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    product.primaryImage),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(2),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            locale.languageCode == 'ar'
                                                ? product.frProductName
                                                : product.enProductName,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          FittedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    locale.languageCode == 'ar'
                                                        ? product.discountPrice
                                                            .toString()
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
                                                    width: product.discountPrice
                                                            .isNotEmpty
                                                        ? 5
                                                        : 0),
                                                Text(product.price.toString(),
                                                    style: TextStyle(
                                                        decoration: product
                                                                .discountPrice
                                                                .isNotEmpty
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                        fontSize: 12,
                                                        color: product
                                                                .discountPrice
                                                                .isNotEmpty
                                                            ? Colors.red
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .primarytheme)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                          getTranslated(
                                              context, 'tax_included')!,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  getTranslated(
                                                      context, 'monthly')!,
                                                ),
                                                Text(
                                                  installment
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                SizedBox(width: 3),
                                                Text(locale.languageCode == 'ar'
                                                    ? 'ر.س'
                                                    : 'SAR')
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  getTranslated(context, 'in')!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 3),
                                                const Text(
                                                  '4',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  getTranslated(
                                                      context, 'installments')!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
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
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primarytheme,
                                  ),
                                  onPressed: () {
                                    if (isDemoApp) {
                                      setSnackbar(
                                        getTranslated(
                                            context, 'SIGNIN_DETAILS')!,
                                        context,
                                      );
                                    } else {
                                      bool productAdded =
                                          Provider.of<MyCartProvider>(context,
                                                  listen: false)
                                              .addItem(CartItem(
                                        id: product.id,
                                        image: product.primaryImage,
                                        tag: product.tag,
                                        title: locale.languageCode == 'ar'
                                            ? product.frProductName
                                            : product.enProductName,
                                        actualPrice:
                                            double.tryParse(product.price)
                                                    ?.toInt() ??
                                                0,
                                        discountedPrice: product
                                                .discountPrice.isNotEmpty
                                            ? double.tryParse(
                                                        product.discountPrice)
                                                    ?.toInt() ??
                                                0
                                            : 0,
                                      ));
                                      if (productAdded) {
                                        setSnackbar(
                                            getTranslated(context,
                                                'product_added_to_cart')!,
                                            context);
                                      } else {
                                        setSnackbar(
                                            getTranslated(context,
                                                'product_already_in_cart')!,
                                            context);
                                      }
                                    }
                                  },
                                  child: FittedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  _cleanersList() {
    Locale locale = Localizations.localeOf(context);
    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.productsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: catLoading(),
            ),
          );
        } else {
          final cleanersList =
              Provider.of<HomeProvider>(context, listen: false).cleanersList;
          if (cleanersList.isEmpty ||
              cleanersList.every((category) => category.products.isEmpty)) {
            return Center(
              child: Text(
                getTranslated(context, 'no_product_found')!,
              ),
            );
          } else {
            var allProducts =
                cleanersList.expand((category) => category.products).toList();
            var categoryName =
                cleanersList.map((category) => category.name).join(", ");
            return SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    children: List.generate(
                      allProducts.length > 3 ? 3 : allProducts.length,
                      (index) {
                        var product = allProducts[index];
                        double? discountPriceValue = double.tryParse(
                            product.discountPrice.isNotEmpty
                                ? product.discountPrice
                                : product.price);
                        double installment = (discountPriceValue ?? 0) / 4;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.primarytheme,
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
                                                  categoryName:
                                                      categoryName.toString(),
                                                  productImage:
                                                      product.primaryImage,
                                                  tag: product.tag,
                                                  productName: locale
                                                              .languageCode ==
                                                          'ar'
                                                      ? product.frProductName
                                                      : product.enProductName,
                                                  actualPrice: double.tryParse(
                                                              product.price)
                                                          ?.toInt() ??
                                                      0,
                                                  discountedPrice: product
                                                          .discountPrice
                                                          .isNotEmpty
                                                      ? double.tryParse(product
                                                                  .discountPrice)
                                                              ?.toInt() ??
                                                          0
                                                      : 0,
                                                  origin: product.origin,
                                                  yearOfProduction:
                                                      product.year,
                                                  pattern: product.pattern,
                                                  width: product.width,
                                                  rimSize: product.rimSize,
                                                  ratio: product.ratio,
                                                  diameter: product.diameter,
                                                  description: locale
                                                              .languageCode ==
                                                          'ar'
                                                      ? product.frDescription
                                                      : product.enDescription,
                                                )));
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 6, 8, 2),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 100,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      product.primaryImage),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(2),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              locale.languageCode == 'ar'
                                                  ? product.frProductName
                                                  : product.enProductName,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            FittedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      locale.languageCode ==
                                                              'ar'
                                                          ? product
                                                              .discountPrice
                                                              .toString()
                                                          : 'SAR ${product.discountPrice.toString()}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primarytheme,
                                                      )),
                                                  if (locale.languageCode ==
                                                      'ar')
                                                    SizedBox(width: 3),
                                                  if (locale.languageCode ==
                                                      'ar')
                                                    Text('ر.س',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primarytheme,
                                                        )),
                                                  SizedBox(
                                                      width: product
                                                              .discountPrice
                                                              .isNotEmpty
                                                          ? 5
                                                          : 0),
                                                  Text(product.price.toString(),
                                                      style: TextStyle(
                                                          decoration: product
                                                                  .discountPrice
                                                                  .isNotEmpty
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                          fontSize: 12,
                                                          color: product
                                                                  .discountPrice
                                                                  .isNotEmpty
                                                              ? Colors.red
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primarytheme)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                            getTranslated(
                                                context, 'tax_included')!,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                        context, 'monthly')!,
                                                  ),
                                                  Text(
                                                    installment
                                                        .toStringAsFixed(1),
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(locale.languageCode ==
                                                          'ar'
                                                      ? 'ر.س'
                                                      : 'SAR')
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    getTranslated(
                                                        context, 'in')!,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  const Text(
                                                    '4',
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    getTranslated(context,
                                                        'installments')!,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: PaymentOptions
                                              .images.entries
                                              .map((entry) => Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
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
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primarytheme,
                                    ),
                                    onPressed: () {
                                      if (isDemoApp) {
                                        setSnackbar(
                                          getTranslated(
                                              context, 'SIGNIN_DETAILS')!,
                                          context,
                                        );
                                      } else {
                                        bool productAdded =
                                            Provider.of<MyCartProvider>(context,
                                                    listen: false)
                                                .addItem(CartItem(
                                          id: product.id,
                                          image: product.primaryImage,
                                          tag: product.tag,
                                          title: locale.languageCode == 'ar'
                                              ? product.frProductName
                                              : product.enProductName,
                                          actualPrice:
                                              double.tryParse(product.price)
                                                      ?.toInt() ??
                                                  0,
                                          discountedPrice: product
                                                  .discountPrice.isNotEmpty
                                              ? double.tryParse(
                                                          product.discountPrice)
                                                      ?.toInt() ??
                                                  0
                                              : 0,
                                        ));
                                        if (productAdded) {
                                          setSnackbar(
                                              getTranslated(context,
                                                  'product_added_to_cart')!,
                                              context);
                                        } else {
                                          setSnackbar(
                                              getTranslated(context,
                                                  'product_already_in_cart')!,
                                              context);
                                        }
                                      }
                                    },
                                    child: FittedBox(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add_circle,
                                              size: 18),
                                          SizedBox(width: 5),
                                          Text(
                                            getTranslated(
                                                context, 'ADD_CART2')!,
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  _batteriesList() {
    Locale locale = Localizations.localeOf(context);
    return Selector<HomeProvider, bool>(
      selector: (_, provider) => provider.productsLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return SizedBox(
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.simmerBase,
              highlightColor: Theme.of(context).colorScheme.simmerHigh,
              child: catLoading(),
            ),
          );
        } else {
          final batteriesList =
              Provider.of<HomeProvider>(context, listen: false).batteriesList;
          if (batteriesList.isEmpty ||
              batteriesList.every((batteries) => batteries.products.isEmpty)) {
            return Center(
              child: Text(
                getTranslated(context, 'no_product_found')!,
              ),
            );
          }
          var allProducts =
              batteriesList.expand((category) => category.products).toList();
          var categoryName =
              batteriesList.map((category) => category.name).join(", ");
          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    allProducts.length > 3 ? 3 : allProducts.length,
                    (index) {
                      var product = allProducts[index];
                      double? discountPriceValue = double.tryParse(
                          product.discountPrice.isNotEmpty
                              ? product.discountPrice
                              : product.price);
                      double installment = (discountPriceValue ?? 0) / 4;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 150,
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
                                                categoryName:
                                                    categoryName.toString(),
                                                productImage:
                                                    product.primaryImage,
                                                tag: product.tag,
                                                productName:
                                                    locale.languageCode == 'ar'
                                                        ? product.frProductName
                                                        : product.enProductName,
                                                actualPrice: double.tryParse(
                                                            product.price)
                                                        ?.toInt() ??
                                                    0,
                                                discountedPrice: product
                                                        .discountPrice
                                                        .isNotEmpty
                                                    ? double.tryParse(product
                                                                .discountPrice)
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
                                                description:
                                                    locale.languageCode == 'ar'
                                                        ? product.frDescription
                                                        : product.enDescription,
                                              )));
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 6, 8, 2),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 100,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    product.primaryImage),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(2),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            locale.languageCode == 'ar'
                                                ? product.frProductName
                                                : product.enProductName,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          FittedBox(
                                            child: Row(
                                              children: [
                                                Text(
                                                    locale.languageCode == 'ar'
                                                        ? product.discountPrice
                                                            .toString()
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
                                                    width: product.discountPrice
                                                            .isNotEmpty
                                                        ? 5
                                                        : 0),
                                                Text(product.price.toString(),
                                                    style: TextStyle(
                                                        decoration: product
                                                                .discountPrice
                                                                .isNotEmpty
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : TextDecoration
                                                                .none,
                                                        fontSize: 12,
                                                        color: product
                                                                .discountPrice
                                                                .isNotEmpty
                                                            ? Colors.red
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .primarytheme)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                          getTranslated(
                                              context, 'tax_included')!,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  getTranslated(
                                                      context, 'monthly')!,
                                                ),
                                                Text(
                                                  installment
                                                      .toStringAsFixed(1),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                SizedBox(width: 3),
                                                Text(locale.languageCode == 'ar'
                                                    ? 'ر.س'
                                                    : 'SAR')
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  getTranslated(context, 'in')!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 3),
                                                const Text(
                                                  '4',
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  getTranslated(
                                                      context, 'installments')!,
                                                  style: const TextStyle(
                                                      fontSize: 12),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
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
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primarytheme,
                                  ),
                                  onPressed: () {
                                    if (isDemoApp) {
                                      setSnackbar(
                                        getTranslated(
                                            context, 'SIGNIN_DETAILS')!,
                                        context,
                                      );
                                    } else {
                                      bool productAdded =
                                          Provider.of<MyCartProvider>(context,
                                                  listen: false)
                                              .addItem(CartItem(
                                        id: product.id,
                                        image: product.primaryImage,
                                        tag: product.tag,
                                        title: locale.languageCode == 'ar'
                                            ? product.frProductName
                                            : product.enProductName,
                                        actualPrice:
                                            double.tryParse(product.price)
                                                    ?.toInt() ??
                                                0,
                                        discountedPrice: product
                                                .discountPrice.isNotEmpty
                                            ? double.tryParse(
                                                        product.discountPrice)
                                                    ?.toInt() ??
                                                0
                                            : 0,
                                      ));
                                      if (productAdded) {
                                        setSnackbar(
                                            getTranslated(context,
                                                'product_added_to_cart')!,
                                            context);
                                      } else {
                                        setSnackbar(
                                            getTranslated(context,
                                                'product_already_in_cart')!,
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
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _refresh() async {
    await checkNetworkAndSetState();
    if (!_isNetworkAvail) return;
    await context.read<HomeProvider>().refreshAPIs();
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Future<bool> checkNetwork(BuildContext context) async {
    bool isAvailable = await isNetworkAvailable();
    if (context.mounted) {
      setState(() {
        _isNetworkAvail = isAvailable;
      });
    }
    return isAvailable;
  }

  Future<void> checkNetworkAndSetState() async {
    bool isAvailable = await isNetworkAvailable();
    if (mounted) {
      setState(() {
        _isNetworkAvail = isAvailable;
      });
    }
  }

  Widget noInternet(BuildContext context) {
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
            context.read<HomeProvider>().setCatLoading(true);
            _playAnimation();
            Future.delayed(const Duration(seconds: 2)).then((_) async {
              _isNetworkAvail = await isNetworkAvailable();
              if (_isNetworkAvail) {
                if (mounted) {
                  setState(() {
                    _isNetworkAvail = true;
                  });

                  await context.read<HomeProvider>().refreshAPIs();
                  await buttonController.reverse();
                }
              } else {
                await buttonController.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  _getSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 44,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.transparent)),
        child: TextField(
          controller: productsSearchController,
          //textAlign: TextAlign.left,
          onChanged: (value) {
            // Notify the provider or update the state when search query changes
            Provider.of<HomeProvider>(context, listen: false)
                .updateSearchQuery(value);
          },
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 8.0, 5.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
                borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              isDense: true,
              hintText: getTranslated(context, 'searchHint')!,
              hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  'assets/images/search.svg',
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primarytheme,
                      BlendMode.srcIn),
                ),
              ),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              filled: true),
          style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black),
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 40),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)))),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  childAspectRatio: 1.0,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                  children: List.generate(
                                    4,
                                    (index) {
                                      return Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color:
                                            Theme.of(context).colorScheme.white,
                                      );
                                    },
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                    //offerImages.length > index ? _getOfferImage(index) : SizedBox.shrink(),
                  ],
                ))
            .toList());
  }
}
