import 'package:flutter/material.dart';
import './resident.dart';

class AddExpenseScreen extends StatefulWidget {
  final List<Resident> residents;

  const AddExpenseScreen({Key? key, required this.residents}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String category = 'Other';
  double amount = 0;
  List<Resident> selectedResidents = [];

  final List<String> categories = ['Power', 'Water', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  category = newValue!;
                  if (category == 'Power' || category == 'Water') {
                    selectedResidents = List.from(widget.residents);
                  } else {
                    selectedResidents.clear();
                  }
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),
            if (category == 'Other') ...[
              const Text('Assign to Residents:'),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.residents.length,
                  itemBuilder: (context, index) {
                    final resident = widget.residents[index];
                    return CheckboxListTile(
                      title: Text(resident.fullName),
                      subtitle: Text('Apt: ${resident.apartmentNumber}, Millimeters: ${resident.millimeters}'),
                      value: selectedResidents.contains(resident),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedResidents.add(resident);
                          } else {
                            selectedResidents.remove(resident);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            ElevatedButton(
              onPressed: () {
                if (category.isNotEmpty && amount > 0 && (category != 'Other' || selectedResidents.isNotEmpty)) {
                  Expense newExpense = Expense(
                    category: category,
                    amount: amount,
                    assignedResidents: category == 'Other' ? selectedResidents : widget.residents,
                  );
                  
                  for (var resident in (category == 'Other' ? selectedResidents : widget.residents)) {
                    resident.addExpense(newExpense);
                  }

                  Navigator.pop(context, newExpense);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields and select at least one resident for Other expenses')),
                  );
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
