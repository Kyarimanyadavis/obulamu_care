import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BabyScreen extends StatefulWidget {
  const BabyScreen({super.key});

  @override
  State<BabyScreen> createState() => _BabyScreenState();
}

// Simple DatePickerWidget implementation
class _DatePickerWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerWidget({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  State<_DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<_DatePickerWidget> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
              widget.onDateSelected(picked);
            }
          },
          child: const Text('Select Date'),
        ),
      ],
    );
  }
}

class _BabyScreenState extends State<BabyScreen> {
  DateTime? _birthDate;
  Map<DateTime, String>? _vaccineSchedule;

  // Example implementation for generating a vaccine schedule
  Map<DateTime, String> _generateVaccineSchedule(DateTime birthDate) {
    // This is a simple example; replace with your actual schedule logic
    return {
      birthDate: "BCG Vaccine",
      birthDate.add(const Duration(days: 42)): "DTP 1st Dose",
      birthDate.add(const Duration(days: 70)): "DTP 2nd Dose",
      birthDate.add(const Duration(days: 98)): "Penta-3, OPV 3, PCV 3",
      birthDate.add(const Duration(days: 273)): "Measles-Rubella 1 (MR1), Yellow Fever",
      birthDate.add(const Duration(days: 548)): "Measles-Rubella 2 (MR2 - Second dose)",
      birthDate.add(const Duration(days: 2190)): "Tetanus-Diphtheria booster (Td)",
      birthDate.add(const Duration(days: 3285)): "HPV (1st dose, especially for girls)",
      birthDate.add(const Duration(days: 3465)): "HPV (2nd dose, 6 months after 1st)",
      birthDate.add(const Duration(days: 3650)): "Td booster (every 5–10 years)",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ADD BABY'),
        backgroundColor: const Color.fromARGB(221, 66, 154, 189),
      ),
      // Add text fields for baby's name and gender
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Baby's Name TextField
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Baby's Name",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle name change if needed
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Baby's Gender TextField
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle gender change if needed
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mother's Name
            TextField(
              decoration: const InputDecoration(
                labelText: "Mother's Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.female),
              ),
              onChanged: (value) {
                // Handle mother's name change if needed
              },
            ),
            const SizedBox(height: 16),
            // Father's Name
            TextField(
              decoration: const InputDecoration(
                labelText: "Father's Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.male),
              ),
              onChanged: (value) {
                // Handle father's name change if needed
              },
            ),
            const SizedBox(height: 16),
            // Village
            TextField(
              decoration: const InputDecoration(
                labelText: "Village",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              onChanged: (value) {
                // Handle village change if needed
              },
            ),
            const SizedBox(height: 16),
            // Parish
            TextField(
              decoration: const InputDecoration(
                labelText: "Parish",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              onChanged: (value) {
                // Handle parish change if needed
              },
            ),
            const SizedBox(height: 16),
            // Subcounty
            TextField(
              decoration: const InputDecoration(
                labelText: "Subcounty",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map),
              ),
              onChanged: (value) {
                // Handle subcounty change if needed
              },
            ),
            const SizedBox(height: 16),
            // District
            TextField(
              decoration: const InputDecoration(
                labelText: "District",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              onChanged: (value) {
                // Handle district change if needed
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter Baby\'s Date of Birth:',
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () async {
                // Collect all the entered details
                // (You may want to use TextEditingControllers for better state management)
                // For this example, we'll use simple variables and show a basic approach

                // Show a snackbar if any required field is missing
                if (_birthDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select the baby\'s date of birth.')),
                  );
                  return;
                }

                // You should collect the values from the text fields.
                // For a real app, use TextEditingControllers and assign them to each TextField.
                // Here, we'll just show a placeholder for the data.
                final babyData = {
                  'birthDate': _birthDate,
                  'vaccineSchedule': _vaccineSchedule,
                  // Add other fields here as needed
                  // 'name': ...,
                  // 'gender': ...,
                  // 'motherName': ...,
                  // 'fatherName': ...,
                  // 'village': ...,
                  // 'parish': ...,
                  // 'subcounty': ...,
                  // 'district': ...,
                };

                // Save to Firebase Firestore
                // Make sure you have added cloud_firestore to your pubspec.yaml and initialized Firebase
                try {
                  // Import at the top: import 'package:cloud_firestore/cloud_firestore.dart';
                  await FirebaseFirestore.instance.collection('babies').add(babyData);

                  // Clear all fields (reset state)
                  setState(() {
                    _birthDate = null;
                    _vaccineSchedule = null;
                    // Also clear TextEditingControllers if you use them
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Baby information saved successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save: $e')),
                  );
                }
              },
              child: const Text('Save Baby Info'),
            ),
            const SizedBox(height: 8),
            _DatePickerWidget(
              onDateSelected: (selectedDate) {
                setState(() {
                  _birthDate = selectedDate;
                  _vaccineSchedule = _generateVaccineSchedule(_birthDate!);
                });
              },
            ),
            const SizedBox(height: 24),
            if (_vaccineSchedule != null)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _vaccineSchedule!.length,
                itemBuilder: (context, index) {
                  final entry = _vaccineSchedule!.entries.elementAt(index);
                  return ListTile(
                    title: Text(entry.value),
                    subtitle: Text(
                      "${entry.key.toLocal()}".split(' ')[0],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}