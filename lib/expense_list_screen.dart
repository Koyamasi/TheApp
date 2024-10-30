import 'package:flutter/material.dart';
import './models/resident.dart';
import './models/expense.dart';

class ExpensesListScreen extends StatelessWidget {
  final List<Resident> residents;

  const ExpensesListScreen({Key? key, required this.residents}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Expense> allExpenses = [];
    for (var resident in residents) {
      allExpenses.addAll(resident.ongoingExpenses);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses List'),
      ),
      body: ListView.builder(
        itemCount: allExpenses.length,
        itemBuilder: (context, index) {
          final expense = allExpenses[index];
          return ListTile(
            title: Text(expense.category),
            subtitle: Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
            trailing: Text('Assigned to: ${expense.assignedResidents.map((r) => r.fullName).join(', ')}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Expense Details: ${expense.category}'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          const Text('Assigned Residents:'),
                          ...expense.assignedResidents.map((resident) => 
                            Text('${resident.fullName} (Apt: ${resident.apartmentNumber}, Millimeters: ${resident.millimeters})')
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
