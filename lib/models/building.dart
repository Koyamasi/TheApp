import 'resident.dart';
import 'expense.dart';

class Address {
  final String street;
  final String number;
  final String zipCode;

  Address({
    required this.street,
    required this.number,
    required this.zipCode,
  });

  String get fullAddress => '$street $number, $zipCode';
}

class Building {
  final String id;
  final String name;
  final Address address;
  final int floors;
  final List<Resident> residents;
  final List<Expense> expenses;
  final String managerId;

  Building({
    required this.id,
    required this.name,
    required this.address,
    required this.floors,
    required this.managerId,
    List<Resident>? residents,
    List<Expense>? expenses,
  }) : 
    residents = residents ?? [],
    expenses = expenses ?? [];
} 