import 'dart:convert';

class Resident {
  final String firstName;
  final String lastName;
  final int floor;
  final String apartmentNumber;
  final int millimeters;
  List<Expense> ongoingExpenses = [];
  List<Payment> payments = [];

  Resident({
    required this.firstName,
    required this.lastName,
    required this.floor,
    required this.apartmentNumber,
    required this.millimeters,
  });

  String get fullName => '$firstName $lastName';

  double get totalOwed => ongoingExpenses.fold(0, (sum, expense) => sum + expense.amount);

  double get totalPaid => payments.fold(0, (sum, payment) => sum + payment.amount);

  double get balance => totalOwed - totalPaid;

  void addExpense(Expense expense) {
    if (expense.category == 'Water' || expense.category == 'Power') {
      int totalMillimeters = expense.assignedResidents.fold(0, (sum, resident) => sum + resident.millimeters);
      double share = (millimeters / totalMillimeters) * expense.amount;
      ongoingExpenses.add(Expense(
        category: expense.category,
        amount: share,
        assignedResidents: [this],
      ));
    } else {
      // For other expenses, divide equally among assigned residents
      double share = expense.amount / expense.assignedResidents.length;
      ongoingExpenses.add(Expense(
        category: expense.category,
        amount: share,
        assignedResidents: [this],
      ));
    }
  }

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      firstName: json['firstName'],
      lastName: json['lastName'],
      floor: json['floor'],
      apartmentNumber: json['apartmentNumber'],
      millimeters: json['millimeters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'floor': floor,
      'apartmentNumber': apartmentNumber,
      'millimeters': millimeters,
    };
  }
}

class Expense {
  final String category;
  final double amount;
  final List<Resident> assignedResidents;

  Expense({
    required this.category,
    required this.amount,
    required this.assignedResidents,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      category: json['category'],
      amount: json['amount'],
      assignedResidents: List<Resident>.from(json['assignedResidents']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'assignedResidents': assignedResidents,
    };
  }
}

class Payment {
  final double amount;
  final DateTime date;

  Payment({required this.amount, required this.date});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
