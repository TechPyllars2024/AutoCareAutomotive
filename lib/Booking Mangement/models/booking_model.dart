import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String? bookingId;
  String carOwnerUid;
  String serviceProviderUid;
  List<String> selectedService;
  String bookingTime;
  String carBrand;
  String carModel;
  String carYear;
  String fuelType;
  String color;
  String transmission;
  DateTime createdAt;
  String bookingDate;
  String? status;
  String? phoneNumber;
  String fullName;
  double totalPrice;
  String? shopName;
  String? shopAddress;
  double? latitude;
  double? longitude;

  BookingModel({
    required this.carOwnerUid,
    required this.serviceProviderUid,
    required this.selectedService,
    required this.bookingTime,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.fuelType,
    required this.color,
    required this.transmission,
    required this.createdAt,
    required this.bookingDate,
    required this.status,
    required this.phoneNumber,
    required this.fullName,
    required this.totalPrice,
    required this.shopAddress,
    required this.shopName,
    required this.latitude,
    required this.longitude
  });

  // Create a BookingModel from a map
  factory BookingModel.fromMap(Map<String, dynamic> data) {
    // Handle the 'createdAt' field to ensure it's a DateTime
    DateTime createdAt = DateTime.now(); // Default value in case of type mismatch
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt = DateTime.parse(data['createdAt']);
    }

    return BookingModel(
      carOwnerUid: data['carOwnerUid'] ?? '',
      serviceProviderUid: data['serviceProviderUid'] ?? '',
      selectedService: List<String>.from(data['selectedService'] ?? []),
      bookingTime: data['bookingTime'] ?? '',
      carBrand: data['carBrand'] ?? '',
      carModel: data['carModel'] ?? '',
      carYear: data['carYear'] ?? '',
      fuelType: data['fuelType'] ?? '',
      color: data['color'] ?? '',
      transmission: data['transmission'] ?? '',
      createdAt: createdAt,
      bookingDate: data['bookingDate'] ?? '',
      status: data['status'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      fullName: data['fullName'] ?? '',
      shopName: data['shopName'] ?? '',
      shopAddress: data['shopAddress'],
      latitude: data['latitude'],
      longitude: data['longitude']

    );
  }

  // Convert BookingModel to map
  Map<String, dynamic> toMap() {
    return {
      'carOwnerUid': carOwnerUid,
      'serviceProviderUid': serviceProviderUid,
      'selectedService': selectedService,
      'bookingTime': bookingTime,
      'carBrand': carBrand,
      'carModel': carModel,
      'carYear': carYear,
      'fuelType': fuelType,
      'color': color,
      'transmission': transmission,
      'createdAt': Timestamp.fromDate(createdAt), // Store as Timestamp
      'bookingDate': bookingDate,
      'status': status,
      'phoneNumber': phoneNumber,
      'totalPrice': totalPrice,
      'fullName': fullName,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'latitude': latitude,
      'longitude': longitude
    };
  }
  @override
  String toString() {
    return 'BookingModel(bookingId: $bookingId, carOwnerUid: $carOwnerUid, serviceProviderUid: $serviceProviderUid, bookingTime: $bookingTime, carBrand: $carBrand, carModel: $carModel, carYear: $carYear, fuelType: $fuelType, bookingDate: $bookingDate, status: $status)';
  }
}
