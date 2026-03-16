# Bugfix Requirements Document: Flutter Signup 404 Errors

## Introduction

The Flutter app is experiencing 404 errors during the signup flow when attempting to check email availability and register new vendors. These errors occur when the app makes REST API calls to the Supabase backend for the `vendors` table. The issue prevents users from completing the signup process and must be resolved to restore signup functionality.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the user attempts to check if an email exists during signup THEN the system returns "PostgrestException(message: 404 page not found)" instead of a boolean result

1.2 WHEN the user attempts to register a new vendor account THEN the system returns "PostgrestException(message: 404 page not found)" instead of creating a vendor record

1.3 WHEN the user attempts to register with an invite code THEN the system returns "PostgrestException(message: 404 page not found)" instead of creating a vendor record with the invite association

### Expected Behavior (Correct)

2.1 WHEN the user attempts to check if an email exists during signup THEN the system SHALL return a boolean value (true if email exists, false if available) without throwing a 404 exception

2.2 WHEN the user attempts to register a new vendor account THEN the system SHALL create a vendor record in the database and return the created record without throwing a 404 exception

2.3 WHEN the user attempts to register with an invite code THEN the system SHALL create a vendor record with the invite association and return the created record without throwing a 404 exception

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the user provides valid credentials for an existing email THEN the system SHALL CONTINUE TO correctly identify the email as already registered

3.2 WHEN the user provides valid registration data with all required fields THEN the system SHALL CONTINUE TO validate and store all vendor information correctly

3.3 WHEN the user provides an invalid invite code during registration THEN the system SHALL CONTINUE TO handle the error appropriately without affecting the vendor creation process

3.4 WHEN the user attempts to login after successful registration THEN the system SHALL CONTINUE TO authenticate the user with the newly created vendor account
