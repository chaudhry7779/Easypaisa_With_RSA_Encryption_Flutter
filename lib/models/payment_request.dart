/// Represents a payment request containing details required to process a transaction.
/// This class is typically used to encapsulate payment-related data before sending it to a payment gateway or API.
class PaymentRequest {
  /// A unique identifier for the order associated with the payment.
  final String orderId;

  /// The identifier of the store or merchant initiating the payment.
  final String storeId;

  /// The amount of the transaction, typically represented as a string (e.g., "100.00").
  final String transactionAmount;

  /// The type of transaction (e.g., "purchase", "refund", "authorization").
  final String transactionType;

  /// The mobile account number associated with the payment (e.g., a phone number for mobile money payments).
  final String mobileAccountNo;

  /// The email address of the customer initiating the payment.
  final String emailAddress;

  /// Constructs an instance of [PaymentRequest].
  ///
  /// - [orderId]: A unique identifier for the order.
  /// - [storeId]: The identifier of the store or merchant.
  /// - [transactionAmount]: The amount of the transaction.
  /// - [transactionType]: The type of transaction.
  /// - [mobileAccountNo]: The mobile account number associated with the payment.
  /// - [emailAddress]: The email address of the customer.
  PaymentRequest({
    required this.orderId,
    required this.storeId,
    required this.transactionAmount,
    required this.transactionType,
    required this.mobileAccountNo,
    required this.emailAddress,
  });

  /// Converts the [PaymentRequest] object into a JSON map.
  ///
  /// Returns a map containing the payment request details in a format suitable for sending to an API.
  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'storeId': storeId,
        'transactionAmount': transactionAmount,
        'transactionType': transactionType,
        'mobileAccountNo': mobileAccountNo,
        'emailAddress': emailAddress,
      };
}
