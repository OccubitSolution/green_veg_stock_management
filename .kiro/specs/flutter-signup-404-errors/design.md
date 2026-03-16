# Flutter Signup 404 Errors Bugfix Design

## Overview

The Flutter app is experiencing 404 errors when attempting to check email availability and register new vendors via Supabase REST API. The issue occurs because the app is making direct REST API calls to the `vendors` table using the Supabase REST endpoint, but the REST API access to the `vendors` table is not properly configured or enabled in Supabase. The fix involves either enabling REST API access for the vendors table or implementing a custom backend endpoint to handle these operations securely.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when the app attempts to call REST API endpoints for the vendors table (GET /rest/v1/vendors for email check, POST /rest/v1/vendors for registration)
- **Property (P)**: The desired behavior when these endpoints are called - the API should return the expected response (list of vendors for GET, created vendor record for POST) without throwing a 404 error
- **Preservation**: Existing login functionality and other database operations that must remain unchanged by the fix
- **emailExists()**: The function in `lib/app/data/repositories/auth_repository.dart` that checks if an email is already registered by querying the vendors table
- **register()**: The function in `lib/app/data/repositories/auth_repository.dart` that creates a new vendor record
- **registerWithInvite()**: The function in `lib/app/data/repositories/auth_repository.dart` that creates a new vendor record with an invite code association
- **Supabase REST API**: The HTTP-based API endpoint at `http://supabasekong-i4gwgw48ok4sg08o0go4kkcg.72.60.99.108.sslip.io/rest/v1/` that provides direct table access

## Bug Details

### Bug Condition

The bug manifests when the app attempts to make REST API calls to the `vendors` table during signup. The `emailExists()`, `register()`, and `registerWithInvite()` functions in the auth repository are calling Supabase REST API endpoints that return 404 errors instead of the expected data.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type APIRequest (email check or registration request)
  OUTPUT: boolean
  
  RETURN input.endpoint IN ['/rest/v1/vendors', 'POST /rest/v1/vendors']
         AND input.table == 'vendors'
         AND REST_API_ACCESS_NOT_ENABLED('vendors')
         AND HTTP_RESPONSE_CODE == 404
END FUNCTION
```

### Examples

- **Email Check Bug**: User enters email "test@example.com" during signup → `emailExists()` calls `GET /rest/v1/vendors?email=eq.test@example.com` → Returns "PostgrestException(message: 404 page not found)" instead of boolean result
- **Registration Bug**: User submits registration form with email, password, name → `register()` calls `POST /rest/v1/vendors` with vendor data → Returns "PostgrestException(message: 404 page not found)" instead of created vendor record
- **Invite Registration Bug**: User registers with invite code → `registerWithInvite()` calls `POST /rest/v1/vendors` → Returns "PostgrestException(message: 404 page not found)" instead of created vendor record with invite association
- **Edge Case - Login Still Works**: User attempts to login with existing credentials → `login()` calls `GET /rest/v1/vendors` with email and password filters → This may also fail with 404, indicating the issue is table-wide

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Login functionality must continue to work exactly as before (or be fixed if also affected by the same 404 issue)
- Existing vendor data must remain intact and accessible
- Other table operations (products, categories, customers, orders, etc.) must continue to work
- Database schema and data integrity must be preserved
- Authentication and authorization logic must remain unchanged

**Scope:**
All operations that do NOT involve direct REST API calls to the vendors table should be completely unaffected by this fix. This includes:
- Operations on other tables (products, categories, customers, orders, etc.)
- Any server-side business logic that may be implemented
- Existing vendor data and relationships

## Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

1. **REST API Access Not Enabled**: The `vendors` table does not have REST API access enabled in Supabase. By default, Supabase requires explicit configuration to expose tables via REST API. The table may exist in the database but not be accessible through the REST endpoint.

2. **Incorrect Table Exposure**: The table may be created but not properly exposed in the Supabase REST API configuration. Supabase requires tables to be explicitly enabled for REST access through the dashboard or API.

3. **Missing RLS Policies**: Row-Level Security (RLS) policies may not be configured for the vendors table, preventing REST API access even if the table is exposed.

4. **Incorrect API URL or Configuration**: The Supabase URL or API key configuration in the app may be incorrect, pointing to a different database or instance where the vendors table doesn't exist.

## Correctness Properties

Property 1: Bug Condition - REST API Access to Vendors Table

_For any_ API request where the endpoint is `/rest/v1/vendors` (GET for email check or POST for registration) and the vendors table is properly exposed in Supabase REST API, the fixed implementation SHALL return the expected response (list of vendors for GET, created vendor record for POST) without throwing a 404 error.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Preservation - Non-Vendors Table Operations

_For any_ operation that does NOT involve direct REST API calls to the vendors table (login, operations on other tables, existing vendor data access), the fixed implementation SHALL produce the same result as the original implementation, preserving all existing functionality for non-buggy inputs.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct, the fix involves enabling REST API access for the vendors table in Supabase:

**File**: `supabase_migration.sql` (or Supabase dashboard configuration)

**Specific Changes**:

1. **Enable REST API for Vendors Table**: Ensure the vendors table is exposed in the Supabase REST API by:
   - Verifying the table exists in the public schema
   - Enabling REST API access through Supabase dashboard (Settings → API → Exposed schemas)
   - Ensuring the table is in the "public" schema (REST API only exposes public schema tables by default)

2. **Configure RLS Policies**: If RLS is enabled, create appropriate policies:
   - Allow anonymous users to check email existence (SELECT with email filter)
   - Allow anonymous users to create new vendor records (INSERT)
   - Restrict other operations to authenticated users

3. **Verify API Configuration**: Confirm that:
   - The Supabase URL in the app matches the actual Supabase instance
   - The API key has appropriate permissions
   - The REST API endpoint is accessible from the app

4. **Alternative: Implement Custom Backend**: If REST API access cannot be enabled for security reasons:
   - Create custom backend endpoints for email check and registration
   - Update auth_repository.dart to call custom endpoints instead of direct REST API calls
   - Implement proper validation and security on the backend

5. **Update Auth Repository (if using custom backend)**:
   - Modify `emailExists()` to call custom backend endpoint
   - Modify `register()` to call custom backend endpoint
   - Modify `registerWithInvite()` to call custom backend endpoint

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write tests that simulate email check and registration API calls to the vendors table. Run these tests on the UNFIXED code to observe 404 failures and confirm the root cause.

**Test Cases**:
1. **Email Check Test**: Simulate calling `emailExists('test@example.com')` when vendors table REST API is not accessible (will fail with 404 on unfixed code)
2. **Registration Test**: Simulate calling `register()` with valid vendor data when vendors table REST API is not accessible (will fail with 404 on unfixed code)
3. **Invite Registration Test**: Simulate calling `registerWithInvite()` with valid data and invite code (will fail with 404 on unfixed code)
4. **Existing Email Test**: Simulate checking an email that already exists in the database (will fail with 404 on unfixed code)

**Expected Counterexamples**:
- API calls return 404 errors instead of expected data
- Possible causes: REST API not enabled for vendors table, incorrect table schema, missing RLS policies, incorrect API configuration

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition(input) DO
  result := emailExists_fixed(input) OR register_fixed(input) OR registerWithInvite_fixed(input)
  ASSERT result != 404_error
  ASSERT result == expected_response
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition(input) DO
  ASSERT original_function(input) = fixed_function(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for login and other operations, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Login Preservation**: Verify login with valid credentials continues to work after fix
2. **Other Table Operations Preservation**: Verify operations on products, categories, customers tables continue to work
3. **Existing Vendor Data Preservation**: Verify existing vendor records remain intact and accessible
4. **Error Handling Preservation**: Verify error handling for invalid inputs continues to work

### Unit Tests

- Test email existence check with various email formats
- Test registration with valid and invalid data
- Test invite registration with valid and invalid invite codes
- Test error handling for duplicate emails
- Test error handling for missing required fields

### Property-Based Tests

- Generate random email addresses and verify email check works correctly
- Generate random vendor data and verify registration works correctly
- Generate random invite codes and verify invite registration works correctly
- Verify that login continues to work with various valid credentials

### Integration Tests

- Test complete signup flow with email check and registration
- Test signup with invite code
- Test that newly registered vendors can login
- Test that email validation prevents duplicate registrations
