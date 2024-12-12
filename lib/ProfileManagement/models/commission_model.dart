class Commission {
  final String commissionId;
  final String bookingId;
  final String carOwnerName;
  final String serviceName;
  final double totalPrice;
  final double commissionAmount;
  final String serviceProviderUid;


  Commission({
    required this.commissionId,
    required this.bookingId,
    required this.carOwnerName,
    required this.serviceName,
    required this.totalPrice,
    required this.commissionAmount,
    required this.serviceProviderUid,
  });

  // Method to calculate commission
  static double calculateCommission(double totalPrice, double rate) {
    return totalPrice * rate;
  }

  // Convert Commission to a Map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'commissionId': commissionId,
      'bookingId': bookingId,
      'carOwnerName': carOwnerName,
      'serviceName': serviceName,
      'totalPrice': totalPrice,
      'commissionAmount': commissionAmount,
      'serviceProviderUid': serviceProviderUid
    };
  }

  // Create Commission from a Map (for database retrieval)
  factory Commission.fromMap(Map<String, dynamic> map) {
    return Commission(
      commissionId: map['commissionId'],
      bookingId: map['bookingId'],
      carOwnerName: map['carOwnerName'],
      serviceName: map['serviceName'],
      totalPrice: map['totalPrice'],
      commissionAmount: map['commissionAmount'],
      serviceProviderUid: map['serviceProviderUid']
    );
  }
}
