import 'api_service.dart';
import 'models/api_response.dart';

/// A class for managing Easypaisa payment integration with RSA encryption.
/// This class provides a simplified interface for initializing credentials,
/// keys, and initiating payment requests.
class EasypaisaWithRSA {
  /// The username for authenticating with the Easypaisa API.
  static String? username;

  /// The password for authenticating with the Easypaisa API.
  static String? password;

  /// The store ID associated with the merchant account.
  static String? storeId;

  /// A flag indicating whether to use the sandbox or live environment.
  static late bool isSandbox;

  /// The type of account used for transactions (e.g., "MA" for Mobile Account).
  static String? accountType = "MA";

  /// The private key in PEM format for signing requests.
  static String? privateKeyPem;

  /// The public key in PEM format for verifying responses.
  static String? publicKeyPem;

  /// Initializes the Easypaisa integration with the required credentials and keys.
  ///
  /// - [username]: The username for API authentication.
  /// - [password]: The password for API authentication.
  /// - [storeId]: The store ID associated with the merchant account.
  /// - [privateKey]: The private key in PEM format for signing requests.
  /// - [publicKey]: The public key in PEM format for verifying responses.
  /// - [isSandbox]: A flag indicating whether to use the sandbox environment (default: true).
  /// - [accountType]: The type of account used for transactions (default: "MA").
  static void initialize(
    String username,
    String password,
    String storeId,
    String privateKey,
    String publicKey, {
    bool isSandbox = true,
    String accountType = "MA",
  }) {
    EasypaisaWithRSA.username = username;
    EasypaisaWithRSA.password = password;
    EasypaisaWithRSA.storeId = storeId;
    EasypaisaWithRSA.isSandbox = isSandbox;
    EasypaisaWithRSA.accountType = accountType;
    EasypaisaWithRSA.privateKeyPem = privateKey;
    EasypaisaWithRSA.publicKeyPem = publicKey;
  }

  /// Initiates a payment request using the provided details.
  ///
  /// - [amount]: The transaction amount as a string (e.g., "100.00").
  /// - [accountNo]: The mobile account number associated with the payment.
  /// - [email]: The email address of the customer initiating the payment.
  ///
  /// Returns an [ApiResponse] object containing the API response data.
  ///
  /// Throws an exception if required credentials or keys are not initialized,
  /// or if the API request fails.
  static Future<ApiResponse> requestPayment({
    required String amount,
    required String accountNo,
    required String email,
  }) async {
    return ApiService.requestPayment(
      amount: amount,
      accountNo: accountNo,
      email: email,
    );
  }

  static Future<ApiResponse> inquirePayment(
      {required String orderId, required String accountNum}) async {
    return ApiService.inquireTransaction(
      orderId: orderId,
      accountNum: accountNum,
    );
  }
}
