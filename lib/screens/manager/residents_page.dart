import 'package:flutter/material.dart';
import '../../models/building.dart';
import '../../models/resident.dart';
import '../../models/apartment.dart';
import './edit_resident_dialog.dart';

class ResidentListPage extends StatefulWidget {
  final Building building;

  const ResidentListPage({
    Key? key,
    required this.building,
  }) : super(key: key);

  @override
  State<ResidentListPage> createState() => _ResidentListPageState();
}

class _ResidentListPageState extends State<ResidentListPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.building.residents.length,
      itemBuilder: (context, index) {
        final resident = widget.building.residents[index];
        
        return ListTile(
          title: Text('${resident.firstName} ${resident.lastName}'),
          subtitle: Text(
            'Apartments: ${resident.apartments.length}, Total Millimeters: ${resident.totalMillimeters}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showApartmentsDialog(context, resident),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete ${resident.firstName} ${resident.lastName}?'),
                      content: const Text('This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              widget.building.residents.remove(resident);
                            });
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApartmentsDialog(BuildContext context, Resident resident) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${resident.firstName} ${resident.lastName}\'s Apartments'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...resident.apartments.map((apt) => ListTile(
                  title: Text('Apartment ${apt.apartmentNumber}'),
                  subtitle: Text('Floor: ${apt.floor}, Millimeters: ${apt.millimeters}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        resident.apartments.remove(apt);
                      });
                    },
                  ),
                )).toList(),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Add Apartment'),
                        content: _AddApartmentForm(
                          onSave: (apartment) {
                            setState(() {
                              resident.apartments.add(apartment);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Apartment'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddApartmentForm extends StatelessWidget {
  final Function(Apartment) onSave;
  final apartmentNumberController = TextEditingController();
  final floorController = TextEditingController();
  final millimetersController = TextEditingController();

  _AddApartmentForm({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: apartmentNumberController,
          decoration: const InputDecoration(labelText: 'Apartment Number'),
        ),
        TextField(
          controller: floorController,
          decoration: const InputDecoration(labelText: 'Floor'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: millimetersController,
          decoration: const InputDecoration(labelText: 'Millimeters'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (apartmentNumberController.text.isNotEmpty &&
                floorController.text.isNotEmpty &&
                millimetersController.text.isNotEmpty) {
              onSave(Apartment(
                id: DateTime.now().toString(),
                apartmentNumber: apartmentNumberController.text,
                floor: int.parse(floorController.text),
                millimeters: int.parse(millimetersController.text),
              ));
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}