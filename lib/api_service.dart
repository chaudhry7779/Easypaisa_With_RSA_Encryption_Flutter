import 'dart:convert';
import 'package:http/http.dart' as http;
import 'easypaisa_with_rsa_encryption.dart';
import 'rsa_utils.dart';
import 'models/payment_request.dart';
import 'models/api_response.dart';

/// A service class for handling API requests related to payment processing.
/// This class encapsulates the logic for initiating a payment transaction
/// with the Easypaisa payment gateway.
class ApiService {
  /// Base URLs for the Easypaisa API (sandbox and live environments).
  static const String _sandboxUrl =
      'https://easypaystg.easypaisa.com.pk/easypay-service/rest/v5/initiate-ma-transaction';
  static const String _liveUrl =
      'https://easypay.easypaisa.com.pk/easypay-service/rest/v5/initiate-ma-transaction';

  /// Initiates a payment request with the provided details.
  ///
  /// - [amount]: The transaction amount as a string (e.g., "100.00").
  /// - [accountNo]: The mobile account number associated with the payment.
  /// - [email]: The email address of the customer initiating the payment.
  ///
  /// Throws an exception if required credentials or keys are not initialized,
  /// or if the API request fails or the response signature is invalid.
  ///
  /// Returns an [ApiResponse] object containing the API response data.
  static Future<ApiResponse> requestPayment({
    required String amount,
    required String accountNo,
    required String email,
  }) async {
    _validateCredentialsAndKeys();

    // Create a PaymentRequest object
    final requestBody = PaymentRequest(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      storeId: EasypaisaWithRSA.storeId!,
      transactionAmount: amount,
      transactionType: 'MA', // MA stands for Mobile Account
      mobileAccountNo: accountNo,
      emailAddress: email,
    );

    // Prepare the API request
    final url = EasypaisaWithRSA.isSandbox ? _sandboxUrl : _liveUrl;
    final requestJson = jsonEncode(requestBody.toJson());
    final signature =
        RSAUtils.signData(requestJson, EasypaisaWithRSA.privateKeyPem!);

    final jsonPayload = {
      'request': requestBody.toJson(),
      'signature': signature,
    };

    // Send the API request
    final response = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(),
      body: jsonEncode(jsonPayload),
    );

    _validateResponse(response);

    // Parse and verify the API response
    final apiResponseJson = jsonDecode(response.body);
    final isSignatureValid = RSAUtils.verifySignature(
      jsonEncode(apiResponseJson['response']),
      apiResponseJson['signature'],
      EasypaisaWithRSA.publicKeyPem!,
    );

    final apiResponse = ApiResponse.fromJson(apiResponseJson, isSignatureValid);

    if (!apiResponse.isSignatureValid) {
      throw Exception('Invalid response signature.');
    }

    return apiResponse;
  }

  /// Validates that required credentials and keys are initialized.
  static void _validateCredentialsAndKeys() {
    if (EasypaisaWithRSA.username == null ||
        EasypaisaWithRSA.password == null ||
        EasypaisaWithRSA.storeId == null) {
      throw Exception(
          'Username, password, and storeId must be initialized first.');
    }
    if (EasypaisaWithRSA.privateKeyPem == null ||
        EasypaisaWithRSA.publicKeyPem == null) {
      throw Exception('Private key and public key must be initialized first.');
    }
  }

  /// Builds the headers for the API request.
  static Map<String, String> _buildHeaders() {
    final credentials = base64.encode(
      utf8.encode('${EasypaisaWithRSA.username}:${EasypaisaWithRSA.password}'),
    );
    return {
      "Credentials": credentials,
      "Content-Type": "application/json",
    };
  }

  /// Validates the HTTP response.
  static void _validateResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
        'API request failed: ${response.statusCode}. Response: ${response.body}',
      );
    }
  }
}
