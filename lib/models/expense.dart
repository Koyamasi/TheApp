import 'resident.dart';

enum ExpenseType {
  water,
  electricity,
  other
}

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final ExpenseType type;
  final List<Resident> assignedResidents;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.assignedResidents,
  });

  double calculateForMillimeters(int millimeters) {
    if (type == ExpenseType.water || type == ExpenseType.electricity) {
      int totalMillimeters = assignedResidents
          .fold(0, (sum, resident) => sum + resident.totalMillimeters);
      return (millimeters / totalMillimeters) * amount;
    }
    return amount / assignedResidents.length;
  }
} 