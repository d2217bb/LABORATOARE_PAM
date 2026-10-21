import 'product.dart';
import 'category.dart';

class HomePageData {
  final List<CategoryModel> categories;
  final Map<String, dynamic> heroBanner;
  final List<Product> featureProducts;
  final Map<String, dynamic> newCollection;
  final List<Product> recommended;
  final List<Map<String, dynamic>> topCollections;
  final List<Map<String, dynamic>> categoryPromos;
  final Map<String, dynamic> productPageData;

  const HomePageData({
    required this.categories,
    required this.heroBanner,
    required this.featureProducts,
    required this.newCollection,
    required this.recommended,
    required this.topCollections,
    required this.categoryPromos,
    required this.productPageData,
  });

  factory HomePageData.fromJson(Map<String, dynamic> json) {
    final homePage = json['homePage'] as Map<String, dynamic>? ?? {};
    final productPage = json['productPage'] as Map<String, dynamic>? ?? {};

    final categoriesList = (homePage['categories'] as List<dynamic>?)
            ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final featureProductsList = (homePage['featureProducts'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final recommendedList = (homePage['recommended'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final topCollectionsList = (homePage['topCollections'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    final categoryPromosList = (homePage['categoryPromos'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    return HomePageData(
      categories: categoriesList,
      heroBanner: Map<String, dynamic>.from(homePage['heroBanner'] as Map? ?? {}),
      featureProducts: featureProductsList,
      newCollection: Map<String, dynamic>.from(homePage['newCollection'] as Map? ?? {}),
      recommended: recommendedList,
      topCollections: topCollectionsList,
      categoryPromos: categoryPromosList,
      productPageData: Map<String, dynamic>.from(productPage),
    );
  }
}
