import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../models/apartment.dart';

class AddResidentDialog {
  static void show(BuildContext context, Function(Resident) onResidentAdded) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final numberOfApartmentsController = TextEditingController();
    final apartments = <Apartment>[];
    int currentApartmentIndex = 0;

    void showApartmentForm() {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Apartment ${currentApartmentIndex + 1} of ${numberOfApartmentsController.text}'),
            content: _AddApartmentForm(
              onSave: (apartment) {
                if (currentApartmentIndex < apartments.length) {
                  apartments[currentApartmentIndex] = apartment;
                } else {
                  apartments.add(apartment);
                }
                
                if (currentApartmentIndex < int.parse(numberOfApartmentsController.text) - 1) {
                  currentApartmentIndex++;
                  Navigator.pop(context);
                  showApartmentForm();
                } else {
                  // All apartments added, create resident
                  final resident = Resident(
                    id: DateTime.now().toString(),
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    apartments: apartments,
                  );
                  onResidentAdded(resident);
                  Navigator.pop(context);
                }
              },
              currentIndex: currentApartmentIndex,
              totalApartments: int.parse(numberOfApartmentsController.text),
            ),
            actions: [
              if (currentApartmentIndex > 0)
                TextButton(
                  onPressed: () {
                    currentApartmentIndex--;
                    Navigator.pop(context);
                    showApartmentForm();
                  },
                  child: const Text('Previous'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Resident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: numberOfApartmentsController,
              decoration: const InputDecoration(labelText: 'Number of Apartments'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (firstNameController.text.isNotEmpty && 
                  lastNameController.text.isNotEmpty &&
                  numberOfApartmentsController.text.isNotEmpty) {
                Navigator.pop(context);
                showApartmentForm();
              }
            },
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

class _AddApartmentForm extends StatelessWidget {
  final Function(Apartment) onSave;
  final int currentIndex;
  final int totalApartments;
  final apartmentNumberController = TextEditingController();
  final floorController = TextEditingController();
  final millimetersController = TextEditingController();

  _AddApartmentForm({
    required this.onSave,
    required this.currentIndex,
    required this.totalApartments,
  });

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
          child: Text(currentIndex < totalApartments - 1 ? 'Next' : 'Finish'),
        ),
      ],
    );
  }
} 