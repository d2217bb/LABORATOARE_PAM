# GemStore Homepage Implementation

Implement a Flutter homepage based on the provided "GemStore" design image. This will involve creating several custom widgets to match the layout and styling.

## User Review Required

> [!IMPORTANT]
> I will replace the existing "Laboratoare" app in `lib/main.dart` with the new GemStore implementation. If you want to keep the old code, please back it up first.

## Proposed Changes

### UI Components

I will build the homepage using a `SingleChildScrollView` to allow scrolling through all sections.

#### [MODIFY] [main.dart](file:///Users/mood_buster/AndroidStudioProjects/PAM_LL1/lib/main.dart)

- **GemStoreApp**: The main `MaterialApp` widget.
- **HomeScreen**: The main scaffold containing the UI sections.
- **CategorySection**: A horizontal list for categories (Women, Men, Accessories, Beauty).
- **PromoBanner**: A carousel-like banner for featured collections.
- **ProductSection**: A reusable section for "Feature Products" and "Recommended" with horizontal scrolling cards.
- **CollectionSection**: The "Top Collection" layout at the bottom.

## Verification Plan

### Manual Verification
- Verify the layout matches the provided image.
- Ensure horizontal scrolling works for categories and product sections.
- Check that the UI is responsive to different screen sizes.
