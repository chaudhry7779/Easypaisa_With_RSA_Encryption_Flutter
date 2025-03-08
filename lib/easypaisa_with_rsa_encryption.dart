import 'api_service.dart';
import 'models/api_response.dart';

class EasypaisaWithRSA {
  static String? username;
  static String? password;
  static String? storeId;
  static late bool isSandbox;
  static String? accountType = "MA";
  static String? privateKeyPem;
  static String? publicKeyPem;

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
}
