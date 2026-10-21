import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/json_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../services/review_storage.dart';
import 'gem_store_state.dart';

class GemStoreCubit extends Cubit<GemStoreState> {
  final JsonService _jsonService;
  final ReviewStorage _reviewStorage;

  GemStoreCubit({JsonService? jsonService, ReviewStorage? reviewStorage})
    : _jsonService = jsonService ?? JsonService(),
      _reviewStorage = reviewStorage ?? ReviewStorage(),
      super(const GemStoreInitial());

  Future<void> loadData() async {
    emit(const GemStoreLoading());
    try {
      final homeData = await _jsonService.loadData();

      // Collect all products
      // Recommendations can also be featured products. Keep one item per id so
      // favorites and search results remain consistent across the app.
      final productsById = <String, Product>{
        for (final product in [
          ...homeData.featureProducts,
          ...homeData.recommended,
        ])
          if (product.category != 'Men') product.id: product,
      };
      final allProducts = productsById.values.toList(growable: false);

      // Initial favorites set
      final favoriteIds = allProducts
          .where((p) => p.isFavorite)
          .map((p) => p.id)
          .toSet();
      final reviewsByProduct = <String, List<ReviewModel>>{
        for (final product in allProducts)
          product.id: [
            ReviewModel(
              id: '${product.id}_review_1',
              name: 'Jennifer Rose',
              time: '5m ago',
              rating: 5,
              avatarUrl: 'photos/5c86d1e9fefeb1de1a02e52e62f59bb5624dff95.png',
              content: 'I love it. Great quality and fast delivery!',
            ),
            ReviewModel(
              id: '${product.id}_review_2',
              name: 'Kelly Rihana',
              time: '9m ago',
              rating: 5,
              avatarUrl: 'photos/09e90f5ea1ecc64acbaaa975deb94ffe18def16c.png',
              content: 'Very happy with my order. Recommended!',
            ),
          ],
      };
      final savedReviews = await _reviewStorage.load();
      for (final entry in savedReviews.entries) {
        if (reviewsByProduct.containsKey(entry.key)) {
          reviewsByProduct[entry.key]!.insertAll(0, entry.value);
        }
      }

      emit(
        GemStoreSuccess(
          homeData: homeData,
          allProducts: allProducts,
          displayedProducts: allProducts,
          categories: homeData.categories,
          selectedCategory: 'Women',
          searchQuery: '',
          sortOption: 'Default',
          favoriteIds: favoriteIds,
          reviewsByProduct: reviewsByProduct,
          profileName: 'Your name',
          profileEmail: 'you@example.com',
          profileAvatarUrl: 'photos/profile_avatar_unique.png',
          cartQuantities: const {},
        ),
      );
    } catch (e) {
      emit(GemStoreError(message: e.toString()));
    }
  }

  void searchProducts(String query) {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;
    final normalizedQuery = query.trim();
    final category = normalizedQuery.isEmpty
        ? currentState.selectedCategory
        : 'All';
    final categories = currentState.categories
        .map((item) => item.copyWith(isSelected: item.label == category))
        .toList();
    _applyFilterAndSort(
      currentState,
      searchQuery: normalizedQuery,
      selectedCategory: category,
      categories: categories,
    );
  }

  void selectCategory(String categoryLabel) {
    if (state is! GemStoreSuccess && state is! GemStoreEmpty) return;
    if (state is GemStoreEmpty) {
      loadData().then((_) {
        if (state is GemStoreSuccess) {
          _applyFilterAndSort(
            state as GemStoreSuccess,
            selectedCategory: categoryLabel,
          );
        }
      });
      return;
    }
    final currentState = state as GemStoreSuccess;
    final newCategory = (currentState.selectedCategory == categoryLabel)
        ? 'All'
        : categoryLabel;

    final updatedCategories = currentState.categories.map((c) {
      return c.copyWith(isSelected: c.label == newCategory);
    }).toList();

    _applyFilterAndSort(
      currentState,
      selectedCategory: newCategory,
      categories: updatedCategories,
    );
  }

  void sortProducts(String sortOption) {
    if (state is! GemStoreSuccess) return;
    _applyFilterAndSort(state as GemStoreSuccess, sortOption: sortOption);
  }

  void toggleFavorite(String productId) {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;

    final updatedFavorites = Set<String>.from(currentState.favoriteIds);
    if (updatedFavorites.contains(productId)) {
      updatedFavorites.remove(productId);
    } else {
      updatedFavorites.add(productId);
    }

    emit(currentState.copyWith(favoriteIds: updatedFavorites));
  }

  void addToCart(String productId) {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;
    final updatedCart = Map<String, int>.from(currentState.cartQuantities);
    updatedCart[productId] = (updatedCart[productId] ?? 0) + 1;
    emit(currentState.copyWith(cartQuantities: updatedCart));
  }

  void changeCartQuantity(String productId, int quantity) {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;
    final updatedCart = Map<String, int>.from(currentState.cartQuantities);
    if (quantity <= 0) {
      updatedCart.remove(productId);
    } else {
      updatedCart[productId] = quantity;
    }
    emit(currentState.copyWith(cartQuantities: updatedCart));
  }

  void removeFromCart(String productId) {
    changeCartQuantity(productId, 0);
  }

  Future<void> addReview({
    required String productId,
    required String content,
    required int rating,
  }) async {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;
    final updatedReviews = <String, List<ReviewModel>>{
      for (final entry in currentState.reviewsByProduct.entries)
        entry.key: List<ReviewModel>.from(entry.value),
    };
    updatedReviews.putIfAbsent(productId, () => []);
    updatedReviews[productId]!.insert(
      0,
      ReviewModel(
        id: '${productId}_${DateTime.now().microsecondsSinceEpoch}',
        name: currentState.profileName,
        time: 'just now',
        rating: rating,
        avatarUrl: currentState.profileAvatarUrl,
        content: content,
        isMine: true,
      ),
    );
    await _reviewStorage.save(updatedReviews);
    emit(currentState.copyWith(reviewsByProduct: updatedReviews));
  }

  Future<void> deleteReview({
    required String productId,
    required String reviewId,
  }) async {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;
    final updatedReviews = <String, List<ReviewModel>>{
      for (final entry in currentState.reviewsByProduct.entries)
        entry.key: List<ReviewModel>.from(entry.value),
    };
    final productReviews = updatedReviews[productId];
    if (productReviews == null) return;
    productReviews.removeWhere(
      (review) => review.id == reviewId && review.isMine,
    );
    await _reviewStorage.save(updatedReviews);
    emit(currentState.copyWith(reviewsByProduct: updatedReviews));
  }

  void updateProfile({required String name, required String email}) {
    if (state is! GemStoreSuccess) return;
    final currentState = state as GemStoreSuccess;
    emit(currentState.copyWith(profileName: name, profileEmail: email));
  }

  void clearFilters() {
    loadData();
  }

  void _applyFilterAndSort(
    GemStoreSuccess currentState, {
    String? searchQuery,
    String? selectedCategory,
    String? sortOption,
    List<CategoryModel>? categories,
  }) {
    final query = searchQuery ?? currentState.searchQuery;
    final category = selectedCategory ?? currentState.selectedCategory;
    final sort = sortOption ?? currentState.sortOption;

    List<Product> filtered = currentState.allProducts.where((product) {
      final searchableText =
          '${product.name} ${product.category} ${product.description}'
              .toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          searchableText.contains(query.toLowerCase());
      final matchesCategory = category == 'All' || product.category == category;
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort
    if (sort == 'Price: Low -> High') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == 'Price: High -> Low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (sort == 'Name: A -> Z') {
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }

    emit(
      currentState.copyWith(
        displayedProducts: filtered,
        searchQuery: query,
        selectedCategory: category,
        sortOption: sort,
        categories: categories ?? currentState.categories,
      ),
    );
  }
}
