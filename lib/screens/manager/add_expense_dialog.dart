import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/resident.dart';
import '../../models/building.dart';

class AddExpenseDialog {
  static void show(BuildContext context, Building building, Function(Expense) onExpenseAdded) {
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();
    ExpenseType selectedType = ExpenseType.water;
    List<Resident> selectedResidents = [];
    DateTime selectedDate = DateTime.now();

    void updateResidents() {
      if (selectedType == ExpenseType.water || selectedType == ExpenseType.electricity) {
        selectedResidents = List.from(building.residents);
      } else {
        selectedResidents.clear();
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ExpenseType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Expense Type',
                ),
                items: ExpenseType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                    updateResidents();
                  });
                },
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(
                  labelText: 'Amount (€)',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              ListTile(
                title: Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              if (selectedType == ExpenseType.other) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select Residents'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: building.residents.map((resident) {
                              return CheckboxListTile(
                                title: Text('${resident.firstName} ${resident.lastName}'),
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
                            }).toList(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Select Residents'),
                ),
                Text('Selected: ${selectedResidents.length} residents'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (valueController.text.isNotEmpty && 
                    (selectedType != ExpenseType.other || selectedResidents.isNotEmpty)) {
                  final expense = Expense(
                    id: DateTime.now().toString(),
                    category: descriptionController.text,
                    amount: double.parse(valueController.text),
                    date: selectedDate,
                    type: selectedType,
                    assignedResidents: selectedResidents,
                  );
                  onExpenseAdded(expense);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
} 