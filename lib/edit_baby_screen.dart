import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditBabyScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> existingData;

  const EditBabyScreen({
    super.key,
    required this.documentId,
    required this.existingData,
  });

  @override
  State<EditBabyScreen> createState() => _EditBabyScreenState();
}

class _EditBabyScreenState extends State<EditBabyScreen> {
  DateTime? birthDate;
  Map<DateTime, Map<String, dynamic>> vaccineSchedule = {};

  @override
  void initState() {
    super.initState();
    birthDate = (widget.existingData['birthDate'] as Timestamp).toDate();

    final rawSchedule = Map<String, dynamic>.from(
      widget.existingData['vaccineSchedule'],
    );

    vaccineSchedule = rawSchedule.map((key, value) {
      final parsedDate = DateTime.parse(key);
      final details =
          value is Map<String, dynamic>
              ? value
              : {'name': value.toString(), 'given': false, 'givenDate': null};

      return MapEntry(parsedDate, {
        'name': details['name'] ?? '',
        'given': details['given'] ?? false,
        'givenDate':
            details['givenDate'] != null
                ? DateTime.tryParse(details['givenDate'].toString())
                : null,
      });
    });
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  void _updateFirestore() async {
    final updatedSchedule = vaccineSchedule.map((key, value) {
      return MapEntry(key.toIso8601String(), {
        'name': value['name'] ?? '',
        'given': value['given'] ?? false,
        'givenDate': value['givenDate']?.toIso8601String(),
      });
    });

    await FirebaseFirestore.instance
        .collection('babies')
        .doc(widget.documentId)
        .update({'birthDate': birthDate, 'vaccineSchedule': updatedSchedule});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record updated successfully')),
    );

    Navigator.pop(context);
  }

  void _addNewVaccineEntry() {
    setState(() {
      vaccineSchedule[DateTime.now()] = {
        'name': '',
        'given': false,
        'givenDate': null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Baby Record'),
        backgroundColor: const Color.fromARGB(255, 164, 94, 230),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/vaccinating baby.jpeg',
              fit: BoxFit.cover,
            ),
          ),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _selectBirthDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          birthDate != null
                              ? "Birth Date: ${DateFormat.yMMMMd().format(birthDate!)}"
                              : "Select Birth Date",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vaccineSchedule.length,
                  itemBuilder: (context, index) {
                    final entry = vaccineSchedule.entries.elementAt(index);
                    final date = entry.key;
                    final vaccine = entry.value;

                    final nameController = TextEditingController(
                      text: vaccine['name'] ?? '',
                    );
                    final given = vaccine['given'] ?? false;
                    final givenDate = vaccine['givenDate'] as DateTime?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (newDate != null) {
                                final newMap =
                                    Map<DateTime, Map<String, dynamic>>.from(
                                      vaccineSchedule,
                                    );
                                final value = newMap.remove(date);
                                newMap[newDate] = value ?? {};
                                setState(() {
                                  vaccineSchedule = newMap;
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat.yMMMMd().format(date),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Icon(
                                  Icons.edit_calendar,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Vaccine Name",
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                vaccineSchedule[date]!['name'] = value;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: given,
                                onChanged: (val) {
                                  setState(() {
                                    vaccineSchedule[date]!['given'] = val!;
                                    if (val &&
                                        vaccineSchedule[date]!['givenDate'] ==
                                            null) {
                                      vaccineSchedule[date]!['givenDate'] =
                                          DateTime.now();
                                    }
                                  });
                                },
                              ),
                              const Text(
                                "Given",
                                style: TextStyle(color: Colors.white),
                              ),
                              const Spacer(),
                              if (given)
                                TextButton.icon(
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: givenDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        vaccineSchedule[date]!['givenDate'] =
                                            picked;
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    givenDate != null
                                        ? DateFormat.yMMMd().format(givenDate)
                                        : "Select date",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ElevatedButton.icon(
                  onPressed: _addNewVaccineEntry,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Vaccine"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 164, 94, 230),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _updateFirestore,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
