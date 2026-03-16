# Implementation Plan: Flutter Signup 404 Errors

## Overview

This implementation plan follows the exploratory bugfix workflow to fix 404 errors in the Flutter signup flow. The workflow consists of:
1. Write bug condition exploration test (Property 1) - BEFORE fix
2. Write preservation property tests (Property 2) - BEFORE fix
3. Implement the fix
4. Verify bug condition test passes (Property 1 validation)
5. Verify preservation tests still pass (Property 2 validation)
6. Checkpoint - ensure all tests pass

---

## Phase 1: Exploration & Preservation Testing (BEFORE FIX)

- [ ] 1. Write bug condition exploration test
  - **Property 1: Bug Condition** - REST API 404 Errors on Vendors Table Access
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: For deterministic bugs, scope the property to the concrete failing case(s) to ensure reproducibility
  - Test implementation details from Bug Condition in design:
    - Test that `emailExists('test@example.com')` does NOT throw a 404 exception
    - Test that `register(vendorData)` does NOT throw a 404 exception
    - Test that `registerWithInvite(vendorData, inviteCode)` does NOT throw a 404 exception
  - The test assertions should match the Expected Behavior Properties from design:
    - Email check should return a boolean value (true/false)
    - Registration should return a created vendor record
    - Invite registration should return a created vendor record with invite association
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found to understand root cause:
    - Observe 404 errors when calling REST API endpoints for vendors table
    - Confirm REST API access is not enabled for vendors table in Supabase
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3_

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Login and Other Operations Continue to Work
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-buggy inputs (operations that don't involve vendors table REST API)
  - Write property-based tests capturing observed behavior patterns from Preservation Requirements:
    - Test that login with valid credentials continues to work (if not affected by the same 404 issue)
    - Test that operations on other tables (products, categories, customers) continue to work
    - Test that existing vendor data remains intact and accessible
    - Test that error handling for invalid inputs continues to work
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

---

## Phase 2: Implementation

- [ ] 3. Fix for Flutter Signup 404 Errors

  - [ ] 3.1 Verify Supabase configuration and enable REST API for vendors table
    - Check Supabase dashboard to confirm vendors table exists in public schema
    - Enable REST API access for vendors table through Supabase dashboard (Settings → API → Exposed schemas)
    - Verify the table is properly exposed in the REST API configuration
    - Document the configuration changes made
    - _Bug_Condition: REST_API_ACCESS_NOT_ENABLED('vendors') from design_
    - _Expected_Behavior: API requests to /rest/v1/vendors return expected responses without 404 errors_
    - _Preservation: Other table operations and existing vendor data remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 3.2 Configure RLS policies for vendors table
    - Create Row-Level Security (RLS) policies for the vendors table if RLS is enabled
    - Allow anonymous users to check email existence (SELECT with email filter)
    - Allow anonymous users to create new vendor records (INSERT)
    - Restrict other operations to authenticated users as appropriate
    - Test that RLS policies don't block legitimate API requests
    - Document the RLS policies created
    - _Bug_Condition: Missing RLS policies preventing REST API access_
    - _Expected_Behavior: RLS policies allow email check and registration without blocking_
    - _Preservation: Existing security model and data access patterns remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 3.3 Update auth_repository.dart if needed
    - Review `emailExists()` function to ensure it calls the correct REST API endpoint
    - Review `register()` function to ensure it calls the correct REST API endpoint
    - Review `registerWithInvite()` function to ensure it calls the correct REST API endpoint
    - Verify API calls use correct Supabase URL and API key configuration
    - If custom backend endpoints are needed, implement them and update the repository
    - Document any changes made to the repository
    - _Bug_Condition: Incorrect API endpoint configuration or missing custom backend_
    - _Expected_Behavior: API calls to vendors table succeed without 404 errors_
    - _Preservation: Login and other operations continue to work as before_
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 3.4 Verify API configuration and connectivity
    - Confirm Supabase URL in app configuration matches the actual Supabase instance
    - Verify API key has appropriate permissions for vendors table access
    - Test that REST API endpoint is accessible from the app
    - Check network connectivity and firewall rules if applicable
    - Document the configuration verification steps
    - _Bug_Condition: Incorrect API configuration or connectivity issues_
    - _Expected_Behavior: API requests reach the correct Supabase instance and vendors table_
    - _Preservation: Existing configuration for other tables remains unchanged_
    - _Requirements: 2.1, 2.2, 2.3_

---

## Phase 3: Validation

- [ ] 4. Verify bug condition exploration test now passes
  - **Property 1: Expected Behavior** - REST API 404 Errors Fixed
  - **IMPORTANT**: Re-run the SAME test from task 1 - do NOT write a new test
  - The test from task 1 encodes the expected behavior
  - When this test passes, it confirms the expected behavior is satisfied
  - Run bug condition exploration test from step 1
  - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
  - Verify that:
    - `emailExists()` returns boolean values without throwing 404 exceptions
    - `register()` returns created vendor records without throwing 404 exceptions
    - `registerWithInvite()` returns created vendor records without throwing 404 exceptions
  - _Requirements: 2.1, 2.2, 2.3_

- [ ] 5. Verify preservation tests still pass
  - **Property 2: Preservation** - Login and Other Operations Preserved
  - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
  - Run preservation property tests from step 2
  - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
  - Confirm all tests still pass after fix (no regressions)
  - Verify that:
    - Login continues to work with valid credentials
    - Operations on other tables continue to work
    - Existing vendor data remains intact
    - Error handling continues to work as before
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

---

## Phase 4: Checkpoint

- [ ] 6. Checkpoint - Ensure all tests pass
  - Run complete test suite to verify all tests pass
  - Verify bug condition exploration test passes (Property 1)
  - Verify preservation property tests pass (Property 2)
  - Verify no new errors or warnings introduced
  - Test complete signup flow end-to-end:
    - Email availability check works
    - New vendor registration works
    - Invite code registration works
    - Newly registered vendors can login
  - Verify no regressions in existing functionality:
    - Login with existing credentials works
    - Other database operations work
    - Existing vendor data is intact
  - Document any issues found and ensure they are resolved
  - Mark complete when all tests pass and signup flow is fully functional
