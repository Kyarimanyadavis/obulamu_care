import 'dart:ui';

import 'package:akwap/akwap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddBabyPage extends StatefulWidget {
  const AddBabyPage({super.key});

  @override
  State<AddBabyPage> createState() => _AddBabyPageState();
}

class _AddBabyPageState extends State<AddBabyPage> {
  late final ValueNotifier<District?> district;
  late final ValueNotifier<County?> county;
  late final ValueNotifier<Subcounty?> subcounty;
  late final ValueNotifier<Parish?> parish;
  late final ValueNotifier<Village?> village;

  TextEditingController? districtController;
  TextEditingController? countyController;
  TextEditingController? subcountyController;
  TextEditingController? parishController;
  TextEditingController? villageController;

  //controllers for text fields
  final TextEditingController babyNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  //gender controller
  final TextEditingController genderController = TextEditingController();

  final List<District> _districts = [];

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
  void initState() {
    super.initState();
    district = ValueNotifier(null);
    county = ValueNotifier(null);
    subcounty = ValueNotifier(null);
    parish = ValueNotifier(null);
    village = ValueNotifier(null);

    districts.then(
      (value) => setState(() {
        _districts
          ..clear()
          ..addAll(value..sort((a, b) => a.name.compareTo(b.name)));
      }),
    );
  }

  @override
  void dispose() {
    // district.dispose();
    // county.dispose();
    // subcounty.dispose();
    // parish.dispose();
    // village.dispose();
    // districtController?.dispose();
    // countyController?.dispose();
    // subcountyController?.dispose();
    // parishController?.dispose();
    // villageController?.dispose();
    super.dispose();
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
                      child: _buildTextField(
                        "Baby's Name",
                        Icons.child_care,
                        babyNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        "Gender",
                        Icons.male,
                        genderController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Mother's Name",
                  Icons.female,
                  motherNameController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Father's Name",
                  Icons.male,
                  fatherNameController,
                ),
                const SizedBox(height: 16),
                Autocomplete<District>(
                  optionsBuilder: (value) {
                    final name = value.text.trim();
                    if (name.isEmpty) {
                      return _districts;
                    }

                    return _districts.findByName(name);
                  },
                  displayStringForOption: (option) => option.name,
                  onSelected: (option) {
                    district.value = option;
                    county.value = null;
                    countyController?.clear();

                    subcounty.value = null;
                    subcountyController?.clear();

                    parish.value = null;
                    parishController?.clear();

                    village.value = null;
                    villageController?.clear();
                  },
                  fieldViewBuilder: (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    districtController = textEditingController;

                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) => onFieldSubmitted,
                      validator: (_) {
                        if (district.value?.name.trim().isNotEmpty != true) {
                          return 'District required';
                        }

                        return null;
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "District",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.location_city_outlined,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<District?>(
                  valueListenable: district,
                  builder: (context, d, child) {
                    final counties = d?.counties ?? [];

                    return Autocomplete<County>(
                      key: ValueKey('district-${d?.id ?? "XXXX"}'),
                      optionsBuilder: (value) {
                        final name = value.text.trim();
                        if (name.isEmpty) {
                          return counties;
                        }

                        return counties.findByName(name);
                      },
                      displayStringForOption: (option) => option.name,
                      onSelected: (option) {
                        county.value = option;

                        subcounty.value = null;
                        subcountyController?.clear();

                        parish.value = null;
                        parishController?.clear();

                        village.value = null;
                        villageController?.clear();
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        countyController = textEditingController;

                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) => onFieldSubmitted,
                          style: const TextStyle(color: Colors.white),
                          validator: (_) {
                            if (county.value?.name.trim().isNotEmpty != true) {
                              return 'County required';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'County',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          enabled: district.value != null,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<County?>(
                  valueListenable: county,
                  builder: (context, d, child) {
                    final subcounties = d?.subcounties ?? [];

                    return Autocomplete<Subcounty>(
                      key: ValueKey('county-${d?.id ?? "XXXX"}'),
                      optionsBuilder: (value) {
                        final name = value.text.trim();
                        if (name.isEmpty) {
                          return subcounties;
                        }

                        return subcounties.findByName(name);
                      },
                      displayStringForOption: (option) => option.name,
                      onSelected: (option) {
                        subcounty.value = option;

                        parish.value = null;
                        parishController?.clear();

                        village.value = null;
                        villageController?.clear();
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        subcountyController = textEditingController;

                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) => onFieldSubmitted,
                          style: const TextStyle(color: Colors.white),
                          validator: (_) {
                            if (subcounty.value?.name.trim().isNotEmpty !=
                                true) {
                              return 'Subcounty required';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Subcounty',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.place_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          enabled: county.value != null,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<Subcounty?>(
                  valueListenable: subcounty,
                  builder: (context, d, child) {
                    final subcounties = d?.parishes ?? [];

                    return Autocomplete<Parish>(
                      key: ValueKey('parish-${d?.id ?? "XXXX"}'),
                      optionsBuilder: (value) {
                        final name = value.text.trim();
                        if (name.isEmpty) {
                          return subcounties;
                        }

                        return subcounties.findByName(name);
                      },
                      displayStringForOption: (option) => option.name,
                      onSelected: (option) {
                        parish.value = option;

                        village.value = null;
                        villageController?.clear();
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        parishController = textEditingController;

                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) => onFieldSubmitted,
                          style: const TextStyle(color: Colors.white),
                          validator: (_) {
                            if (parish.value?.name.trim().isNotEmpty != true) {
                              return 'Parish required';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Parish',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.location_searching_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          enabled: subcounty.value != null,
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<Parish?>(
                  valueListenable: parish,
                  builder: (context, d, child) {
                    final subcounties = d?.villages ?? [];

                    return Autocomplete<Village>(
                      key: ValueKey('village-${d?.id ?? "XXXX"}'),
                      optionsBuilder: (value) {
                        final name = value.text.trim();
                        if (name.isEmpty) {
                          return subcounties;
                        }

                        return subcounties.findByName(name);
                      },
                      displayStringForOption: (option) => option.name,
                      onSelected: (option) {
                        village.value = option;
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        villageController = textEditingController;

                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (_) => onFieldSubmitted,
                          style: const TextStyle(color: Colors.white),
                          validator: (_) {
                            if (village.value?.name.trim().isNotEmpty != true) {
                              return 'Village required';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Village',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(
                              Icons.home_outlined,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.black26,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          enabled: parish.value != null,
                        );
                      },
                    );
                  },
                ),

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
                      'district': district.value?.name,
                      'county': county.value?.name,
                      'subcounty': subcounty.value?.name,
                      'parish': parish.value?.name,
                      'village': village.value?.name,
                      'motherName': motherNameController.text,
                      'fatherName': fatherNameController.text,
                      'babyName': babyNameController.text,
                      'gender': genderController.text,
                      'dateOfBirth': _birthDate?.toIso8601String(),
                      'createdAt': Timestamp.now(),
                      'updatedAt': Timestamp.now(),
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

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController? controller,
  ) {
    return TextField(
      controller: controller,
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
