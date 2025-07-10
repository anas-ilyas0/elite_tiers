import 'dart:convert';
import 'package:elite_tiers/Helpers/Constant.dart';
import 'package:elite_tiers/Models/brands_model.dart';
import 'package:elite_tiers/Models/category_model.dart';
import 'package:elite_tiers/Models/deal_model.dart';
import 'package:elite_tiers/Models/products_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeProvider extends ChangeNotifier {
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  int _curSlider = 0;
  bool _secLoading = true;
  bool _sliderLoading = true;
  bool _offerLoading = true;
  bool _mostLikeLoading = true;
  bool _showBars = true;
  late AnimationController _animationController;
//cat
  bool _isCatLoading = true;
  bool get catLoading => _isCatLoading;
  List<CategoryData> _catList = [];
  List<CategoryData> get catList => _catList;
//brands
  bool _isBrandsLoading = true;
  bool get brandsLoading => _isBrandsLoading;
  List<Brands> _brandsList = [];
  List<Brands> get brandsList => _brandsList;
//blogs
  // bool _isBlogsLoading = true;
  // bool get blogsLoading => _isBlogsLoading;
  // List<Blogs> _blogsList = [];
  // List<Blogs> get blogsList => _blogsList;
//products
  bool _isProductsLoading = true;
  bool get productsLoading => _isProductsLoading;

  List<ProductsCategories> _tiresList = [];
  List<ProductsCategories> get tiresList => _tiresList;

  List<ProductsCategories> _oilList = [];
  List<ProductsCategories> get oilList => _oilList;

  List<ProductsCategories> _cleanersList = [];
  List<ProductsCategories> get cleanersList => _cleanersList;

  List<ProductsCategories> _batteriesList = [];
  List<ProductsCategories> get batteriesList => _batteriesList;

  List<ProductsCategories> _categories = [];
  List<ProductsCategories> get categories => _categories;

//deal
  bool _isDealLoading = true;
  bool get dealLoading => _isDealLoading;
  List<Deal> _dealList = [];
  List<Deal> get dealList => _dealList;
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
  //categories

  List<Map<String, Object>> _categoriesList = [];

  bool get isProductsLoading => _isProductsLoading;
  List<Map<String, Object>> get categoriesList => _categoriesList;

  HomeProvider() {
    fetchCategories();
    fetchBrands();
    //fetchBlogs();
    fetchProducts();
    fetchDeal();
  }

  Future<void> refreshAPIs() async {
    await Future.wait([
      fetchCategories(),
      fetchBrands(),
      //fetchBlogs(),
      fetchProducts(),
      fetchDeal(),
    ]);
  }

//categories
  Future<void> fetchCategories() async {
    _isCatLoading = true;
    notifyListeners();

    var url = Uri.parse('${baseUrl}all/categories');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var categoryResponse = CategoryModel.fromJson(data);
      _catList = categoryResponse.data;
      _isCatLoading = false;
      notifyListeners();
    } else {
      _isCatLoading = false;
      notifyListeners();
      throw Exception('Failed to load categories');
    }
  }

//brands
  Future<void> fetchBrands() async {
    _isBrandsLoading = true;
    notifyListeners();

    var url = Uri.parse('${baseUrl}all/brands');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var bandsResponse = BrandsModel.fromJson(data);
      _brandsList = bandsResponse.data;
      _isBrandsLoading = false;
      notifyListeners();
    } else {
      _isBrandsLoading = false;
      notifyListeners();
      throw Exception('Failed to load brands');
    }
  }

//blogs
  // Future<void> fetchBlogs() async {
  //   _isBlogsLoading = true;
  //   notifyListeners();

  //   var url = Uri.parse('${baseUrl}all/blogs');
  //   var response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     var data = json.decode(response.body);
  //     var blogResponse = BlogsModel.fromJson(data);
  //     _blogsList = blogResponse.data;
  //     _isBlogsLoading = false;
  //     notifyListeners();
  //   } else {
  //     _isBlogsLoading = false;
  //     notifyListeners();
  //     throw Exception('Failed to load blogs');
  //   }
  // }

//products
  Future<void> fetchProducts() async {
    _isProductsLoading = true;
    notifyListeners();

    var url = Uri.parse('${baseUrl}category/products');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var productResponse = ProductsModel.fromJson(data);
      _categories = productResponse.data;
      _categoriesList = productResponse.data.map((category) {
        return {
          'name': category.name,
          'image': category.products.isNotEmpty ? category.image : '',
          'products': category.products
              .map((product) => {
                    'id': product.id,
                    'en_Product_Name': product.enProductName,
                    'fr_Product_Name': product.frProductName,
                    'en_brand': product.enBrand,
                    'fr_brand': product.frBrand,
                    'price': product.price,
                    'discount_price': product.discountPrice,
                    'tag': product.tag,
                    //'sku': product.sku,
                    'origin': product.origin,
                    'year': product.year,
                    'width': product.width,
                    'ratio': product.ratio,
                    'pattern': product.pattern,
                    'rim_size': product.rimSize,
                    'en_Description': product.enDescription,
                    'fr_Description': product.frDescription,
                    'diameter': product.diameter,
                    'primary_image': product.primaryImage,
                    'created_at': product.createdAt,
                    'updated_at': product.updatedAt,
                  })
              .toList(),
        };
      }).toList();

      _tiresList = productResponse.data
          .where((category) => category.name.toLowerCase() == "الإطارات")
          .toList();
      _oilList = productResponse.data
          .where((category) => category.name.toLowerCase() == "زيوت")
          .toList();
      _cleanersList = productResponse.data
          .where((category) => category.name.toLowerCase() == "منظفات")
          .toList();
      _batteriesList = productResponse.data
          .where((category) => category.name.toLowerCase() == "البطاريات")
          .toList();

      _isProductsLoading = false;
      notifyListeners();
    } else {
      _isProductsLoading = false;
      notifyListeners();
      throw Exception('Failed to load products');
    }
  }

//deal
  Future<void> fetchDeal() async {
    _isDealLoading = true;
    notifyListeners();

    try {
      var url = Uri.parse('${baseUrl}deal/product');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var dealResponse = DealModel.fromJson(data);
        _dealList = [dealResponse.data];
      } else {
        throw Exception('Failed to load deals');
      }
    } catch (e) {
      throw Exception('Error fetching deals: $e');
    } finally {
      _isDealLoading = false;
      notifyListeners();
    }
  }

  //setter for cat loading
  setCatLoading(bool loading) {
    _isCatLoading = loading;
    notifyListeners();
  }

  // setter for brands loading
  setBrandsLoading(bool loading) {
    _isBrandsLoading = loading;
    notifyListeners();
  }

  // setter for blogs loading
  // setBlogsLoading(bool loading) {
  //   _isBlogsLoading = loading;
  //   notifyListeners();
  // }

  // setter for products loading
  setProductsLoading(bool loading) {
    _isProductsLoading = loading;
    notifyListeners();
  }

  //setter for deal loading
  setDealLoading(bool loading) {
    _isDealLoading = loading;
    notifyListeners();
  }

  get getBars => _showBars;

  get curSlider => _curSlider;

  get secLoading => _secLoading;

  get sliderLoading => _sliderLoading;

  get offerLoading => _offerLoading;
  get mostLikeLoading => _mostLikeLoading;

  AnimationController get animationController => _animationController;

  showBars(bool value) {
    _showBars = value;
    notifyListeners();
  }

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
    notifyListeners();
  }

  setCurSlider(int pos) {
    _curSlider = pos;
    notifyListeners();
  }

  setOfferLoading(bool loading) {
    _offerLoading = loading;
    notifyListeners();
  }

  setSliderLoading(bool loading) {
    _sliderLoading = loading;
    notifyListeners();
  }

  setSecLoading(bool loaidng) {
    _secLoading = loaidng;
    notifyListeners();
  }

  setMostLikeLoading(bool loading) {
    _mostLikeLoading = loading;
    notifyListeners();
  }
}
