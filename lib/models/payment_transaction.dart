import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum TransactionStatus { pending, completed, failed, refunded }
enum ItemType { book, premiumPlan }

class PaymentTransaction extends Equatable {
  final String transactionId;
  final String userId;
  final double amount;
  final DateTime transactionDate;
  final TransactionStatus status;
  final String? paymentMethod;
  final String? providerTransactionId;
  final ItemType itemType;
  final String? itemId; // book_id or plan_id
  final String? receiptData;

  const PaymentTransaction({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.transactionDate,
    required this.status,
    this.paymentMethod,
    this.providerTransactionId,
    required this.itemType,
    this.itemId,
    this.receiptData,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    T _parseEnum<T extends Enum>(Map<String, dynamic> json, String camelKey, String snakeKey, List<T> values) {
      final String? value = json[camelKey] as String? ?? json[snakeKey] as String?;
      if (value == null) {
        throw ArgumentError('Required enum value not found for $camelKey or $snakeKey');
      }
      return values.firstWhere((e) => e.toString().split('.').last == value);
    }

    return PaymentTransaction(
      transactionId: json['transactionId'] as String? ?? json['transaction_id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'] as String)
          : DateTime.parse(json['transaction_date'] as String),

      status: _parseEnum(json, 'status', 'status', TransactionStatus.values), // 'status' đã là camelCase

      paymentMethod: json['paymentMethod'] as String? ?? json['payment_method'] as String?,
      providerTransactionId: json['providerTransactionId'] as String? ?? json['provider_transaction_id'] as String?,

      itemType: _parseEnum(json, 'itemType', 'item_type', ItemType.values),

      itemId: json['itemId'] as String? ?? json['item_id'] as String?,
      receiptData: json['receiptData'] as String? ?? json['receipt_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Xuất ra camelCase (giả sử API backend của bạn đã hỗ trợ camelCase)
      'transactionId': transactionId.isEmpty ? const Uuid().v4() : transactionId, // Đổi từ 'transaction_id'
      'userId': userId, // Đổi từ 'user_id'
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(), // Đổi từ 'transaction_date'
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod, // Đổi từ 'payment_method'
      'providerTransactionId': providerTransactionId, // Đổi từ 'provider_transaction_id'
      'itemType': itemType.toString().split('.').last, // Đổi từ 'item_type'
      'itemId': itemId, // Đổi từ 'item_id'
      'receiptData': receiptData, // Đổi từ 'receipt_data'
    };
  }

  PaymentTransaction copyWith({
    String? transactionId,
    String? userId,
    double? amount,
    DateTime? transactionDate,
    TransactionStatus? status,
    String? paymentMethod,
    String? providerTransactionId,
    ItemType? itemType,
    String? itemId,
    String? receiptData,
  }) {
    return PaymentTransaction(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      providerTransactionId: providerTransactionId ?? this.providerTransactionId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      receiptData: receiptData ?? this.receiptData,
    );
  }

  @override
  List<Object?> get props => [
    transactionId,
    userId,
    amount,
    transactionDate,
    status,
    paymentMethod,
    providerTransactionId,
    itemType,
    itemId,
    receiptData,
  ];
}