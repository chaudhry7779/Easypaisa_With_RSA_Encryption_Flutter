import 'dart:convert';
import 'package:http/http.dart' as http;
import 'easypaisa_with_rsa_encryption.dart';
import 'rsa_utils.dart';
import 'models/payment_request.dart';
import 'models/api_response.dart';

class ApiService {
  static Future<ApiResponse> requestPayment({
    required String amount,
    required String accountNo,
    required String email,
  }) async {
    if (EasypaisaWithRSA.username == null || EasypaisaWithRSA.password == null || EasypaisaWithRSA.storeId == null) {
      throw Exception('Username, password, and storeId must be initialized first.');
    }
    if (EasypaisaWithRSA.privateKeyPem == null || EasypaisaWithRSA.publicKeyPem == null) {
      throw Exception('Private key and public key must be initialized first.');
    }

    var requestBody = PaymentRequest(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      storeId: EasypaisaWithRSA.storeId!,
      transactionAmount: amount,
      transactionType: 'MA',
      mobileAccountNo: accountNo,
      emailAddress: email,
    );

    String sandBoxTransactionUrl = 'https://easypaystg.easypaisa.com.pk/easypay-service/rest/v5/initiate-ma-transaction';
    String liveTransactionUrl = 'https://easypay.easypaisa.com.pk/easypay-service/rest/v5/initiate-ma-transaction';
    String url = EasypaisaWithRSA.isSandbox ? sandBoxTransactionUrl : liveTransactionUrl;

    var requestJson = jsonEncode(requestBody.toJson());
    var signature = RSAUtils.signData(requestJson, EasypaisaWithRSA.privateKeyPem!);

    var jsonPayload = {
      'request': requestBody.toJson(),
      'signature': signature,
    };

    var jsonString = jsonEncode(jsonPayload);

    var response = await http.post(
      Uri.parse(url),
      headers: {
        "Credentials": base64.encode(utf8.encode('${EasypaisaWithRSA.username}:${EasypaisaWithRSA.password}')),
        "Content-Type": "application/json",
      },
      body: jsonString,
    );

    if (response.statusCode != 200) {
      throw Exception('API request failed: ${response.statusCode}. Response: ${response.body}');
    }

    var apiResponseJson = jsonDecode(response.body);
    var isSignatureValid = RSAUtils.verifySignature(
      jsonEncode(apiResponseJson['response']),
      apiResponseJson['signature'],
      EasypaisaWithRSA.publicKeyPem!,
    );

    var apiResponse = ApiResponse.fromJson(apiResponseJson, isSignatureValid);

    if (!apiResponse.isSignatureValid) {
      throw Exception('Invalid response signature.');
    }
    return apiResponse;
  }
}
