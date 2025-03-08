# Easypaisa RSA Payment Example

This example demonstrates how to integrate Easypaisa payment processing with RSA encryption in a Flutter application.

## Features
- Initialize Easypaisa credentials and RSA keys.
- Request payment using Easypaisa API.
- Validate API response signature.
- Display transaction details.

## Setup
1. Replace the placeholders (`username`, `password`, `storeId`) in `main.dart` with your actual Easypaisa credentials.
2. Place your RSA keys (`merchant_private_key.pem` and `easypaisa_public_key.pem`) in the `assets/keys` directory.
3. Run the app and test the payment flow.


## Dependencies
- `easypaisa_with_rsa_encryption`: The main package for Easypaisa RSA integration.
- `flutter`: The Flutter framework.

## License
MIT