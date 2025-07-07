import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BabyScreen extends StatefulWidget {
  const BabyScreen({super.key});

  @override
  State<BabyScreen> createState() => _BabyScreenState();
}

class _DatePickerWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerWidget({Key? key, required this.onDateSelected})
    : super(key: key);

  @override
  State<_DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<_DatePickerWidget> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
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
      icon: const Icon(Icons.calendar_month),
      label: const Text('Select Date of Birth'),
    );
  }
}

class _BabyScreenState extends State<BabyScreen> {
  var _birthDate;
  Map<DateTime, String>? _vaccineSchedule;

  Map<DateTime, String> _generateVaccineSchedule(DateTime birthDate) {
    return {
      birthDate: "BCG Vaccine",
      birthDate.add(const Duration(days: 42)): "DTP 1st Dose",
      birthDate.add(const Duration(days: 70)): "DTP 2nd Dose",
      birthDate.add(const Duration(days: 98)): "Penta-3, OPV 3, PCV 3",
      birthDate.add(const Duration(days: 273)):
          "Measles-Rubella 1 (MR1), Yellow Fever",
      birthDate.add(const Duration(days: 548)):
          "Measles-Rubella 2 (MR2 - Second dose)",
      birthDate.add(const Duration(days: 2190)):
          "Tetanus-Diphtheria booster (Td)",
      birthDate.add(const Duration(days: 3285)):
          "HPV (1st dose, especially for girls)",
      birthDate.add(const Duration(days: 3465)):
          "HPV (2nd dose, 6 months after 1st)",
      birthDate.add(const Duration(days: 3650)):
          "Td booster (every 5–10 years)",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD BABY'),
        backgroundColor: const Color.fromARGB(255, 164, 94, 230),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/vaccinating baby.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient + blur overlay
          SizedBox.expand(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(160, 0, 0, 0),
                    Color.fromARGB(159, 27, 49, 59),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Baby's Name", Icons.child_care),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField("Gender", Icons.male)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField("Mother's Name", Icons.female),
                const SizedBox(height: 16),
                _buildTextField("Father's Name", Icons.male),
                const SizedBox(height: 16),
                _buildTextField("Village", Icons.home),
                const SizedBox(height: 16),
                _buildTextField("Parish", Icons.location_city),
                const SizedBox(height: 16),
                _buildTextField("Subcounty", Icons.map),
                const SizedBox(height: 16),
                _buildTextField("District", Icons.public),
                const SizedBox(height: 16),

                _DatePickerWidget(
                  onDateSelected: (selectedDate) {
                    setState(() {
                      _birthDate = selectedDate;
                      _vaccineSchedule = _generateVaccineSchedule(_birthDate!);
                    });
                  },
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (_birthDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select the baby\'s date of birth.',
                          ),
                        ),
                      );
                      return;
                    }

                    final babyData = {
                      'birthDate': Timestamp.fromDate(_birthDate),
                      'vaccineSchedule': _vaccineSchedule!.map(
                        (date, vaccine) =>
                            MapEntry(date.toIso8601String(), vaccine),
                      ),
                    };

                    try {
                      await FirebaseFirestore.instance
                          .collection('babies')
                          .add(babyData);
                      setState(() {
                        _birthDate = null;
                        _vaccineSchedule = null;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Baby information saved successfully!'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Baby Info',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 164, 94, 230),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                if (_vaccineSchedule != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vaccine Schedule:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vaccineSchedule!.length,
                        itemBuilder: (context, index) {
                          final entry = _vaccineSchedule!.entries.elementAt(
                            index,
                          );
                          return Card(
                            color: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                entry.value,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${entry.key.toLocal()}".split(' ')[0],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
