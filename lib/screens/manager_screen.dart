import 'package:flutter/material.dart';
import '../models/building.dart';
import './manager/add_resident_dialog.dart';
import './manager/edit_resident_dialog.dart';
import './manager/add_expense_dialog.dart';
import './manager/expenses_break_down.dart';
import './manager/residents_page.dart';

class ManagerScreen extends StatefulWidget {
  final String userId;

  const ManagerScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  List<Building> _buildings = [];
  Building? _selectedBuilding;
  bool _isDrawerOpen = false;
  int _selectedTabIndex = 0;

  final List<Widget> _buildingTabs = const [
    Tab(icon: Icon(Icons.people), text: 'Residents'),
    Tab(icon: Icon(Icons.money), text: 'Expenses'),
    Tab(icon: Icon(Icons.calculate), text: 'Expense Breakdown'),
    Tab(icon: Icon(Icons.settings), text: 'Settings'),
  ];

  void _addBuilding(String name, String street, String number, String zipCode, int floors) {
    final newBuilding = Building(
      id: DateTime.now().toString(),
      name: name,
      address: Address(
        street: street,
        number: number,
        zipCode: zipCode,
      ),
      floors: floors,
      managerId: widget.userId,
    );

    setState(() {
      _buildings.add(newBuilding);
    });
  }

  void _deleteBuilding(Building building) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Building'),
        content: Text('Are you sure you want to delete ${building.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _buildings.remove(building);
                if (_selectedBuilding?.id == building.id) {
                  _selectedBuilding = null;
                }
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddBuildingDialog() {
    final nameController = TextEditingController();
    final streetController = TextEditingController();
    final numberController = TextEditingController();
    final zipController = TextEditingController();
    final floorsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Building'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Building Name',
                  hintText: 'Enter building name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: streetController,
                decoration: const InputDecoration(
                  labelText: 'Street',
                  hintText: 'Enter street name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Building Number',
                  hintText: 'Enter building number',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: zipController,
                decoration: const InputDecoration(
                  labelText: 'ZIP Code',
                  hintText: 'Enter ZIP code',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: floorsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Floors',
                  hintText: 'Enter number of floors',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  streetController.text.isNotEmpty &&
                  numberController.text.isNotEmpty &&
                  zipController.text.isNotEmpty &&
                  floorsController.text.isNotEmpty) {
                _addBuilding(
                  nameController.text,
                  streetController.text,
                  numberController.text,
                  zipController.text,
                  int.tryParse(floorsController.text) ?? 1,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingContent() {
    if (_selectedBuilding == null) {
      return const Center(child: Text('Select a building to manage'));
    }

    return DefaultTabController(
      length: _buildingTabs.length,
      child: Column(
        children: [
          TabBar(
            tabs: _buildingTabs,
            labelColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Residents Tab
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Residents of ${_selectedBuilding!.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                AddResidentDialog.show(
                                  context,
                                  (resident) {
                                    setState(() {
                                      _selectedBuilding!.residents.add(resident);
                                    });
                                  },
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Resident'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ResidentListPage(building: _selectedBuilding!),
                      ),
                    ],
                  ),
                ),
                // Expenses Tab
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Expenses for ${_selectedBuilding!.name}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                AddExpenseDialog.show(
                                  context,
                                  _selectedBuilding!,
                                  (expense) {
                                    setState(() {
                                      _selectedBuilding!.expenses.add(expense);
                                    });
                                  },
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Expense'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _selectedBuilding!.expenses.length,
                          itemBuilder: (context, index) {
                            final expense = _selectedBuilding!.expenses[index];
                            return ListTile(
                              title: Text(
                                '${expense.type.name.toUpperCase()} - ${expense.amount.toStringAsFixed(2)}€',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense.category),
                                  Text(
                                    'Date: ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _selectedBuilding!.expenses.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Expense Breakdown Tab
                ExpensesBreakDown(building: _selectedBuilding!),
                // Settings Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Building: ${_selectedBuilding!.name}'),
                      Text('Address: ${_selectedBuilding!.address.fullAddress}'),
                      Text('Floors: ${_selectedBuilding!.floors}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _deleteBuilding(_selectedBuilding!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Building'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedBuilding?.name ?? 'Select Building'),
        actions: [
          IconButton(
            icon: Icon(_isDrawerOpen ? Icons.menu_open : Icons.menu),
            onPressed: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: _buildBuildingContent(),
          ),
          if (_isDrawerOpen)
            SizedBox(
              width: 300,
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Buildings'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddBuildingDialog,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _buildings.length,
                        itemBuilder: (context, index) {
                          final building = _buildings[index];
                          return ListTile(
                            title: Text(building.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(building.address.fullAddress),
                                Text('Floors: ${building.floors}'),
                                Text('Residents: ${building.residents.length}'),
                              ],
                            ),
                            selected: _selectedBuilding?.id == building.id,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                              onPressed: () => _deleteBuilding(building),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedBuilding = building;
                                // Optionally close the drawer when selecting a building
                                // _isDrawerOpen = false;
                              });
                            },
                          );
                        },
                      ),
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