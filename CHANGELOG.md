## 1.0.0

* Initial release.

## [1.1.0] - 2025-March-08

### Added
- Added `isSignatureValid` property to the `ApiResponse` model to indicate whether the signature validation was successful.
- The `requestPayment` method now returns an object with the following properties:
  - `response`: The API response data.
  - `signature`: The signature returned by the API.
  - `isSignatureValid`: A boolean indicating whether the signature validation was successful.

### Removed
- Removed unnecessary dependencies:
  - `convert: ^3.1.1` (no longer needed).
  - `basic_utils: ^5.0.0` (no longer needed).

### Improved
- Modularized the codebase for better maintainability:
  - Separated RSA utilities into `rsa_utils.dart`.
  - Separated API service logic into `api_service.dart`.
  - Added models for `PaymentRequest` and `ApiResponse`.
- Improved code readability and organization.
- Enhanced error handling for API responses.
- Cleaned up `pubspec.yaml` by removing unused dependencies to reduce package size and improve maintainability.

### Fixed
- No breaking changes or bug fixes in this release.

## [1.1.1]

### Improved
- Updated **README.md** to reflect the latest usage instructions and improvements.

## [1.2.0] - 2025-03-08

### Added
- Added a **Flutter example app** to demonstrate how to use the `EasypaisaWithRSA` package in a real-world scenario.
  - The example includes a `PaymentScreen` widget with input fields for amount, account number, and email.
  - It demonstrates how to initialize the package, make a payment request, and handle the API response.

## [1.2.3]

### Added
- **Example App**: Added a complete Flutter example app demonstrating Easypaisa payment integration with RSA encryption.
  - Includes a payment screen with input fields for amount, account number, and email.
  - Implements payment request functionality using the `EasypaisaWithRSA` class.
  - Displays API response details (transaction code, description, ID, and signature validity).
  - Supports sandbox and live environments.
  - Includes proper error handling and loading states.

### Changed
- **Documentation**: Updated `README.md` and `example/README.md` to include setup instructions for the example app.
- **Dependencies**: Added `pointycastle` as a dependency in the example app for RSA encryption.

### Fixed
- **Bug Fixes**: Resolved minor issues in the example app related to form validation and state management.

## [1.2.4]

### Changed
- **Refactoring**: Cleaned up and refactored the `ApiService`, `RSAUtils`, and `EasypaisaWithRSA` classes for better readability and maintainability.
  - Extracted reusable logic into helper methods.
  - Simplified key parsing and signing/verification processes.
  - Improved error handling and validation.