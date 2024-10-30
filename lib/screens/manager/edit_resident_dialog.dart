import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../models/apartment.dart';

class EditResidentDialog {
  static void show(
    BuildContext context,
    Resident resident,
    Function(Resident) onResidentUpdated,
  ) {
    final firstNameController = TextEditingController(text: resident.firstName);
    final lastNameController = TextEditingController(text: resident.lastName);
    final apartments = List<Apartment>.from(resident.apartments);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${resident.fullName}'),
        content: SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: 16),
              // List of apartments
              ...apartments.map((apt) => ListTile(
                title: Text('Apt ${apt.apartmentNumber}'),
                subtitle: Text('Floor: ${apt.floor}, Millimeters: ${apt.millimeters}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Show dialog to edit apartment
                  },
                ),
              )),
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
              if (firstNameController.text.isNotEmpty && 
                  lastNameController.text.isNotEmpty) {
                final updatedResident = Resident(
                  id: resident.id,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  apartments: apartments,
                );
                onResidentUpdated(updatedResident);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 