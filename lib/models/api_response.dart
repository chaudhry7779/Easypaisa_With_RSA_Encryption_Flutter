class ApiResponse {
  final Map<String, dynamic> response;
  final String signature;
  final bool isSignatureValid;

  ApiResponse({
    required this.response,
    required this.signature,
    required this.isSignatureValid,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, bool isSignatureValid) {
    return ApiResponse(
      response: json['response'],
      signature: json['signature'],
      isSignatureValid: isSignatureValid,
    );
  }

  Map<String, dynamic> toJson() => {
        'response': response,
        'signature': signature,
        'isSignatureValid': isSignatureValid,
      };
}
