/// Represents a response from an API, including the response data,
/// a digital signature, and a flag indicating whether the signature is valid.
class ApiResponse {
  /// The actual response data returned from the API.
  /// This is typically a map containing key-value pairs of the API's response.
  final Map<String, dynamic> response;

  /// A digital signature associated with the response.
  /// This is used to verify the authenticity and integrity of the response.
  final String signature;

  /// A flag indicating whether the digital signature is valid.
  /// This is typically determined by verifying the signature against the response data.
  final bool isSignatureValid;

  /// Constructs an instance of [ApiResponse].
  ///
  /// - [response]: The API response data as a map.
  /// - [signature]: The digital signature associated with the response.
  /// - [isSignatureValid]: A flag indicating whether the signature is valid.
  ApiResponse({
    required this.response,
    required this.signature,
    required this.isSignatureValid,
  });

  /// Creates an instance of [ApiResponse] from a JSON map.
  ///
  /// - [json]: A map containing the JSON representation of the API response.
  /// - [isSignatureValid]: A flag indicating whether the signature is valid.
  ///
  /// Returns an [ApiResponse] object populated with the data from the JSON map.
  factory ApiResponse.fromJson(
      Map<String, dynamic> json, bool isSignatureValid) {
    return ApiResponse(
      response: json['response'],
      signature: json['signature'],
      isSignatureValid: isSignatureValid,
    );
  }

  /// Converts the [ApiResponse] object into a JSON map.
  ///
  /// Returns a map containing the response data, signature, and signature validity flag.
  Map<String, dynamic> toJson() => {
        'response': response,
        'signature': signature,
        'isSignatureValid': isSignatureValid,
      };
}
