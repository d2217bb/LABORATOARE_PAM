import '../models/product.dart';
import '../models/category.dart';
import '../models/home_data.dart';
import '../models/review.dart';

abstract class GemStoreState {
  const GemStoreState();
}

class GemStoreInitial extends GemStoreState {
  const GemStoreInitial();
}

class GemStoreLoading extends GemStoreState {
  const GemStoreLoading();
}

class GemStoreSuccess extends GemStoreState {
  final HomePageData homeData;
  final List<Product> allProducts;
  final List<Product> displayedProducts;
  final List<CategoryModel> categories;
  final String selectedCategory;
  final String searchQuery;
  final String sortOption;
  final Set<String> favoriteIds;
  final Map<String, List<ReviewModel>> reviewsByProduct;
  final String profileName;
  final String profileEmail;
  final String profileAvatarUrl;
  final Map<String, int> cartQuantities;

  const GemStoreSuccess({
    required this.homeData,
    required this.allProducts,
    required this.displayedProducts,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
    required this.sortOption,
    required this.favoriteIds,
    required this.reviewsByProduct,
    required this.profileName,
    required this.profileEmail,
    required this.profileAvatarUrl,
    required this.cartQuantities,
  });

  GemStoreSuccess copyWith({
    HomePageData? homeData,
    List<Product>? allProducts,
    List<Product>? displayedProducts,
    List<CategoryModel>? categories,
    String? selectedCategory,
    String? searchQuery,
    String? sortOption,
    Set<String>? favoriteIds,
    Map<String, List<ReviewModel>>? reviewsByProduct,
    String? profileName,
    String? profileEmail,
    String? profileAvatarUrl,
    Map<String, int>? cartQuantities,
  }) {
    return GemStoreSuccess(
      homeData: homeData ?? this.homeData,
      allProducts: allProducts ?? this.allProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      reviewsByProduct: reviewsByProduct ?? this.reviewsByProduct,
      profileName: profileName ?? this.profileName,
      profileEmail: profileEmail ?? this.profileEmail,
      profileAvatarUrl: profileAvatarUrl ?? this.profileAvatarUrl,
      cartQuantities: cartQuantities ?? this.cartQuantities,
    );
  }
}

class GemStoreEmpty extends GemStoreState {
  final String message;

  const GemStoreEmpty({required this.message});
}

class GemStoreError extends GemStoreState {
  final String message;

  const GemStoreError({required this.message});
}
