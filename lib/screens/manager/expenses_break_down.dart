import 'package:flutter/material.dart';
import '../../models/building.dart';
import '../../models/expense.dart';
import '../../models/resident.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  amountAsc,
  amountDesc,
}

class ExpensesBreakDown extends StatefulWidget {
  final Building building;

  const ExpensesBreakDown({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  State<ExpensesBreakDown> createState() => _ExpensesBreakDownState();
}

class _ExpensesBreakDownState extends State<ExpensesBreakDown> {
  SortOption _currentSort = SortOption.nameAsc;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  ExpenseType? _selectedExpenseType;

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Expenses'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date Range
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_startDate == null 
                        ? 'Start Date' 
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_endDate == null 
                        ? 'End Date' 
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                        }
                      },
                    ),
                  ),
                ],
              ),
              // Expense Type Filter
              DropdownButton<ExpenseType?>(
                isExpanded: true,
                value: _selectedExpenseType,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Expenses'),
                  ),
                  ...ExpenseType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedExpenseType = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                  _selectedExpenseType = null;
                });
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  List<Expense> _getFilteredExpenses() {
    return widget.building.expenses.where((expense) {
      if (_selectedExpenseType != null && expense.type != _selectedExpenseType) {
        return false;
      }
      if (_startDate != null && expense.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && expense.date.isAfter(_endDate!)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Group residents by name and calculate their total
    Map<String, List<Resident>> residentGroups = {};
    for (var resident in widget.building.residents) {
      final key = '${resident.firstName} ${resident.lastName}';
      if (key.toLowerCase().contains(_searchQuery.toLowerCase())) {
        residentGroups[key] = residentGroups[key] ?? [];
        residentGroups[key]!.add(resident);
      }
    }

    // Calculate totals and sort
    List<MapEntry<String, double>> sortedEntries = residentGroups.entries.map((entry) {
      double totalOwed = 0;
      for (var resident in entry.value) {
        for (var apartment in resident.apartments) {
          for (var expense in _getFilteredExpenses()) {
            totalOwed += expense.calculateForMillimeters(apartment.millimeters);
          }
        }
      }
      return MapEntry(entry.key, totalOwed);
    }).toList();

    // Sort based on selected option
    switch (_currentSort) {
      case SortOption.nameAsc:
        sortedEntries.sort((a, b) => a.key.compareTo(b.key));
        break;
      case SortOption.nameDesc:
        sortedEntries.sort((a, b) => b.key.compareTo(a.key));
        break;
      case SortOption.amountAsc:
        sortedEntries.sort((a, b) => a.value.compareTo(b.value));
        break;
      case SortOption.amountDesc:
        sortedEntries.sort((a, b) => b.value.compareTo(a.value));
        break;
    }

    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search residents...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                onSelected: (SortOption result) {
                  setState(() => _currentSort = result);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: SortOption.nameAsc,
                    child: Text('Name (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.nameDesc,
                    child: Text('Name (Z-A)'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.amountAsc,
                    child: Text('Amount (Low-High)'),
                  ),
                  const PopupMenuItem(
                    value: SortOption.amountDesc,
                    child: Text('Amount (High-Low)'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Active Filters Display
        if (_startDate != null || _endDate != null || _selectedExpenseType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16),
                const SizedBox(width: 8),
                if (_selectedExpenseType != null)
                  Chip(
                    label: Text(_selectedExpenseType!.name.toUpperCase()),
                    onDeleted: () => setState(() => _selectedExpenseType = null),
                  ),
                if (_startDate != null || _endDate != null)
                  Chip(
                    label: Text(
                      '${_startDate?.day ?? ''}-${_endDate?.day ?? ''}'
                    ),
                    onDeleted: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                  ),
              ],
            ),
          ),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final name = sortedEntries[index].key;
              final totalOwed = sortedEntries[index].value;
              final apartments = residentGroups[name]!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${totalOwed.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () => _showExpenseDetails(
                    context,
                    name,
                    apartments,
                    _getFilteredExpenses(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showExpenseDetails(BuildContext context, String residentName, List<Resident> residents, List<Expense> expenses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$residentName\'s Expenses'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: residents.expand((resident) =>
              resident.apartments.map((apartment) {
                double apartmentTotal = 0;
                Map<ExpenseType, double> expensesByType = {
                  ExpenseType.water: 0,
                  ExpenseType.electricity: 0,
                };

                for (var expense in expenses) {
                  double amount = expense.calculateForMillimeters(apartment.millimeters);
                  apartmentTotal += amount;
                  expensesByType[expense.type] = 
                      (expensesByType[expense.type] ?? 0) + amount;
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apartment ${apartment.apartmentNumber}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Divider(),
                        Text('Water: ${expensesByType[ExpenseType.water]!.toStringAsFixed(2)}€'),
                        Text('Electricity: ${expensesByType[ExpenseType.electricity]!.toStringAsFixed(2)}€'),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Apartment Total:'),
                            Text(
                              '${apartmentTotal.toStringAsFixed(2)}€',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 