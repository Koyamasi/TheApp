import 'package:flutter/material.dart';
import './expense_list_screen.dart';
import './add_expense_screen.dart';
import './resident.dart';

void main() {
  runApp(const BuildingExpenseApp());
}

class BuildingExpenseApp extends StatelessWidget {
  const BuildingExpenseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Building Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Resident> residents = [];
  bool _isResidentListVisible = false;

  void _toggleResidentList() {
    setState(() {
      _isResidentListVisible = !_isResidentListVisible;
    });
  }

  void _sortResidents() {
    residents.sort((a, b) {
      int floorComparison = a.floor.compareTo(b.floor);
      if (floorComparison != 0) return floorComparison;
      return a.apartmentNumber.compareTo(b.apartmentNumber);
    });
  }

  void _addResident() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String firstName = '';
        String lastName = '';
        int floor = 1;
        String apartmentNumber = '';
        int millimeters = 0;

        return AlertDialog(
          title: const Text('Add New Resident'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(hintText: "First Name"),
                  onChanged: (value) {
                    firstName = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Last Name"),
                  onChanged: (value) {
                    lastName = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Floor"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    floor = int.tryParse(value) ?? 1;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Apartment Number"),
                  onChanged: (value) {
                    apartmentNumber = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Millimeters"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    millimeters = int.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                setState(() {
                  residents.add(Resident(
                    firstName: firstName,
                    lastName: lastName,
                    floor: floor,
                    apartmentNumber: apartmentNumber,
                    millimeters: millimeters,
                  ));
                  _sortResidents();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResidentDetails(Resident resident) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double paymentAmount = 0;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('${resident.fullName} Details'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Floor: ${resident.floor}, Apt: ${resident.apartmentNumber}'),
                    Text('Millimeters: ${resident.millimeters}'),
                    const SizedBox(height: 16),
                    Text('Total Owed: \$${resident.totalOwed.toStringAsFixed(2)}'),
                    Text('Total Paid: \$${resident.totalPaid.toStringAsFixed(2)}'),
                    Text('Current Balance: \$${resident.balance.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    const Text('Ongoing Expenses:'),
                    ...resident.ongoingExpenses.map((expense) => 
                      Text('${expense.category}: \$${expense.amount.toStringAsFixed(2)}')
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Payment Amount'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        paymentAmount = double.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      child: const Text('Make Payment'),
                      onPressed: () {
                        if (paymentAmount > 0 && paymentAmount <= resident.balance) {
                          setState(() {
                            resident.payments.add(Payment(amount: paymentAmount, date: DateTime.now()));
                            double remainingPayment = paymentAmount;
                            List<Expense> updatedExpenses = [];

                            for (var expense in resident.ongoingExpenses) {
                              if (remainingPayment >= expense.amount) {
                                remainingPayment -= expense.amount;
                              } else if (remainingPayment > 0) {
                                updatedExpenses.add(Expense(
                                  category: expense.category,
                                  amount: expense.amount - remainingPayment,
                                  assignedResidents: expense.assignedResidents,
                                ));
                                remainingPayment = 0;
                              } else {
                                updatedExpenses.add(expense);
                              }
                            }

                            resident.ongoingExpenses = updatedExpenses;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment of \$${paymentAmount.toStringAsFixed(2)} processed')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid payment amount')),
                          );
                        }
                      },
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Building Expense Manager'),
        leading: IconButton(
          icon: Icon(_isResidentListVisible ? Icons.menu_open : Icons.menu),
          onPressed: _toggleResidentList,
        ),
      ),
      body: Row(
        children: [
          if (_isResidentListVisible)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _addResident,
                      child: const Text('Add Resident'),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: residents.length,
                      itemBuilder: (context, index) {
                        final resident = residents[index];
                        return ListTile(
                          title: Text(resident.fullName),
                          subtitle: Text('Floor: ${resident.floor}, Apt: ${resident.apartmentNumber}'),
                          onTap: () => _showResidentDetails(resident),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            flex: _isResidentListVisible ? 2 : 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExpensesListScreen(residents: residents)),
                      );
                    },
                    child: const Text('View Expenses'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(residents: residents),
                        ),
                      ).then((newExpense) {
                        if (newExpense != null) {
                          setState(() {
                            // Update UI if needed after adding an expense
                          });
                        }
                      });
                    },
                    child: const Text('Add Expense'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to Reports screen
                    },
                    child: const Text('View Reports'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
