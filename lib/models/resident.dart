import 'apartment.dart';

class Resident {
  final String id;
  final String firstName;
  final String lastName;
  final List<Apartment> apartments;

  Resident({
    required this.id,
    required this.firstName,
    required this.lastName,
    List<Apartment>? apartments,
  }) : apartments = apartments ?? [];

  String get fullName => '$firstName $lastName';
  int get totalMillimeters => 
      apartments.fold(0, (sum, apt) => sum + apt.millimeters);
} 