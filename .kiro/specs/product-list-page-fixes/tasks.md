# Implementation Plan

## Phase 1: Exploration Tests (Bug Condition Verification)

- [-] 1. Write bug condition exploration tests
  - **Property 1: Bug Condition** - Product Card Navigation, Filter Highlighting, Image Display, and Product Save
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failure confirms the bugs exist
  - **DO NOT attempt to fix the tests or the code when they fail**
  - **NOTE**: These tests encode the expected behavior - they will validate the fixes when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate each bug exists
  - **Scoped PBT Approach**: For deterministic bugs, scope the property to concrete failing case(s) to ensure reproducibility
  
  Test implementation details from Bug Condition in design:
  
  **Test 1a: Product Card Click Navigation**
  - Simulate tapping a product card with a valid product ID
  - Assert that `Get.toNamed(AppRoutes.productDetail, arguments: product.id)` is called
  - Test with concrete products: "Tomato" (id: 1), "Onion" (id: 2)
  - Expected behavior: Navigation to product details page occurs
  - Run on UNFIXED code - expect FAILURE (confirms bug exists)
  
  **Test 1b: Category Filter Highlighting**
  - Simulate selecting a category filter chip
  - Assert that `selectedCategory` observable is updated with the selected category ID
  - Assert that `ModernFilterChip` widget receives `isSelected: true` and displays gradient background
  - Test with concrete categories: "Leafy Vegetables", "Root Vegetables"
  - Expected behavior: Filter chip shows visual highlight and state updates
  - Run on UNFIXED code - expect FAILURE or partial failure (confirms bug exists)
  
  **Test 1c: Product Image Display Removal**
  - Render a `ModernProductCard` widget with product data
  - Assert that no image-related UI elements (Image, NetworkImage, AssetImage widgets) are present
  - Assert that only icon container, product name, category, and price are displayed
  - Test with concrete products: various products from the database
  - Expected behavior: No image UI elements visible in the card
  - Run on UNFIXED code - may PASS or FAIL depending on current implementation
  
  **Test 1d: Product Form Submission and Save**
  - Simulate filling the product form with valid data (name, category, unit, price)
  - Simulate clicking the Save button
  - Assert that `_productRepository.createProduct()` is called with correct data
  - Assert that the product is created in the database
  - Assert that a success message is displayed
  - Assert that navigation back to product list occurs
  - Test with concrete data: "ટમેટો" (Gujarati name), category: "Vegetables", unit: "kg", price: 50
  - Expected behavior: Product is created and user is navigated back
  - Run on UNFIXED code - expect FAILURE (confirms bug exists)
  
  The test assertions should match the Expected Behavior Properties from design
  
  Run tests on UNFIXED code
  
  **EXPECTED OUTCOME**: Tests FAIL (this is correct - it proves the bugs exist)
  
  Document counterexamples found to understand root cause:
  - Product card tap: No navigation occurs
  - Category filter: State not updating or visual highlight not showing
  - Product image: Image elements may be present (if bug exists)
  - Product save: Database operation fails or returns null
  
  Mark task complete when tests are written, run, and failures are documented
  
  _Requirements: 2.1, 2.2, 2.3, 2.4_

## Phase 2: Preservation Tests (Non-Buggy Behavior Verification)

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Search, All Filter, Product List Order, Form Validation, and Optional Fields
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements
  - Property-based testing generates many test cases for stronger guarantees
  
  **Test 2a: Search Functionality Preservation**
  - Observe: Search query "ટમ" returns products with names containing "ટમ"
  - Observe: Search query "onion" returns products with names containing "onion"
  - Observe: Empty search returns all products
  - Write property-based test: For all search queries that do NOT trigger bug conditions, search results match the query pattern
  - Generate random search strings and verify filtering works correctly
  - Expected behavior: Search filtering continues to work as before
  
  **Test 2b: All Filter Behavior Preservation**
  - Observe: Selecting "All" filter displays all products without category filtering
  - Observe: "All" filter shows all products regardless of category
  - Write property-based test: For all "All" filter selections, all products are displayed
  - Generate random product lists and verify "All" filter displays all items
  - Expected behavior: "All" filter continues to display all products
  
  **Test 2c: Product List Display Order Preservation**
  - Observe: Product list maintains consistent sort order (by name, date, or other criteria)
  - Observe: Product information (name, category, price) displays correctly
  - Write property-based test: For all product list renders, products appear in the same order as original code
  - Generate random product lists and verify order is preserved
  - Expected behavior: Product list order and display remain unchanged
  
  **Test 2d: Form Field Validation Preservation**
  - Observe: Required fields (product name, category, unit) must be filled
  - Observe: Optional fields (English name, price) can be empty
  - Observe: Price field accepts numeric values
  - Write property-based test: For all form submissions with valid data, validation passes
  - Generate random valid form data and verify validation works correctly
  - Expected behavior: Form validation continues to work as before
  
  **Test 2e: Product Edit Preservation**
  - Observe: Existing product data populates all form fields correctly
  - Observe: Editing and saving updates the product in the database
  - Write property-based test: For all product edit operations, form fields populate correctly and updates succeed
  - Generate random products and verify edit flow works correctly
  - Expected behavior: Product editing continues to work as before
  
  Run tests on UNFIXED code
  
  **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  
  Mark task complete when tests are written, run, and passing on unfixed code
  
  _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

## Phase 3: Implementation

- [ ] 3. Fix for product list page bugs

  - [x] 3.1 Implement product card navigation
    - **File**: `lib/app/modules/products/views/products_view.dart`
    - **Function**: `_buildProductCard()`
    - **Changes**:
      - Replace the TODO comment in the `onTap` handler with actual navigation code
      - Implement: `Get.toNamed(AppRoutes.productDetail, arguments: product.id)`
      - Ensure navigation passes the product ID as an argument to the details page
    - _Bug_Condition: isBugCondition_ProductCardClick(input) where input.userTappedProductCard == true_
    - _Expected_Behavior: Navigation to product details page occurs for all product card taps_
    - _Preservation: Other UI interactions remain unchanged_
    - _Requirements: 2.1_

  - [x] 3.2 Verify/fix category filter highlighting
    - **File**: `lib/app/widgets/common_widgets.dart`
    - **Class**: `ModernFilterChip`
    - **Changes**:
      - Verify that the `isSelected` property correctly triggers the gradient background styling
      - Confirm that white text color is applied when `isSelected: true`
      - Check that the widget rebuilds when `isSelected` changes
      - If styling is correct, verify the state is being passed correctly from `ProductsController.filterByCategory()`
      - Ensure `selectedCategory` observable is updated when filter is selected
    - _Bug_Condition: isBugCondition_FilterHighlight(input) where input.userSelectedCategoryFilter == true_
    - _Expected_Behavior: Filter chip displays gradient background with white text when selected_
    - _Preservation: Other filter chips and UI elements remain unchanged_
    - _Requirements: 2.2_

  - [x] 3.3 Remove product image UI elements
    - **File**: `lib/app/widgets/common_widgets.dart`
    - **Class**: `ModernProductCard`
    - **Changes**:
      - Audit the `build()` method to identify any product image display elements
      - Remove or comment out any Image, NetworkImage, or AssetImage widgets
      - Verify that only the icon container, product name, category, and price are displayed
      - Ensure the card layout remains clean and properly formatted without image elements
    - _Bug_Condition: isBugCondition_ImageDisplay(input) where input.productListIsDisplayed == true_
    - _Expected_Behavior: No product image UI elements are displayed in the card_
    - _Preservation: Product name, category, price, and icon display remain unchanged_
    - _Requirements: 2.3_

  - [x] 3.4 Fix product form submission and save
    - **File**: `lib/app/modules/products/controllers/product_form_controller.dart`
    - **Function**: `saveProduct()`
    - **Changes**:
      - Verify that the `Product` object is created with all required fields correctly mapped from form inputs
      - Ensure `_productRepository.createProduct()` is called with the correct Product object
      - Add error handling to catch and log any database operation failures
      - Verify that the method returns the created product from the database response
      - Ensure success message is displayed after successful creation
      - Ensure navigation back to product list occurs after successful save
    - **File**: `lib/app/data/repositories/product_repository.dart`
    - **Function**: `createProduct()`
    - **Changes**:
      - Verify the method correctly calls `_databaseProvider.insert()` with the product data
      - Ensure the method returns the created product from the database response
      - Add logging to track the product creation flow
    - _Bug_Condition: isBugCondition_ProductSave(input) where input.userSubmittedForm == true AND input.formIsValid == true_
    - _Expected_Behavior: Product is created in database, success message displayed, navigation back to list_
    - _Preservation: Form validation and other database operations remain unchanged_
    - _Requirements: 2.4_

  - [ ] 3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Product Card Navigation, Filter Highlighting, Image Display, and Product Save
    - **IMPORTANT**: Re-run the SAME tests from task 1 - do NOT write new tests
    - The tests from task 1 encode the expected behavior
    - When these tests pass, it confirms the expected behavior is satisfied
    - Run bug condition exploration tests from step 1
    - **EXPECTED OUTCOME**: Tests PASS (confirms bugs are fixed)
    - Verify all four bug condition tests pass:
      - Product card navigation test passes
      - Category filter highlighting test passes
      - Product image display test passes
      - Product form submission test passes
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [ ] 3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Search, All Filter, Product List Order, Form Validation, and Optional Fields
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run preservation property tests from step 2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Verify all five preservation tests still pass:
      - Search functionality preservation test passes
      - All filter behavior preservation test passes
      - Product list display order preservation test passes
      - Form field validation preservation test passes
      - Product edit preservation test passes
    - Confirm all tests still pass after fixes (no regressions)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 4. Checkpoint - Ensure all tests pass
  - Verify all exploration tests pass (Property 1 tests)
  - Verify all preservation tests pass (Property 2 tests)
  - Verify no new errors or warnings in the codebase
  - Confirm all four bugs are fixed and working correctly
  - Ensure no regressions in existing functionality
  - Ask the user if questions arise or if additional testing is needed
