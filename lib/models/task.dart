class Task {
  final int? id;
  final String shopName;
  final String productSold;
  final int quantity;
  final double amount;
  final String? notes;
  final DateTime timestamp;
  final bool synced;

  Task({
    this.id,
    required this.shopName,
    required this.productSold,
    required this.quantity,
    required this.amount,
    this.notes,
    required this.timestamp,
    this.synced = false,
  });

  // Convert a Task into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shopName': shopName,
      'productSold': productSold,
      'quantity': quantity,
      'amount': amount,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  // Create a Task from a Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      shopName: map['shopName'],
      productSold: map['productSold'],
      quantity: map['quantity'],
      amount: map['amount'],
      notes: map['notes'],
      timestamp: DateTime.parse(map['timestamp']),
      synced: map['synced'] == 1,
    );
  }

  // Create a copy of this task with the given fields replaced with new values
  Task copyWith({
    int? id,
    String? shopName,
    String? productSold,
    int? quantity,
    double? amount,
    String? notes,
    DateTime? timestamp,
    bool? synced,
  }) {
    return Task(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      productSold: productSold ?? this.productSold,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }
}