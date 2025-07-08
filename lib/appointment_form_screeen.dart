// lib/appointment_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl: ^latest_version to your pubspec.yaml

// Import your Appointment model
import 'package:obulamucare/appointments_screen.dart'; // Make sure this path is correct

class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment; // Optional: for editing an existing appointment

  const AppointmentFormScreen({super.key, this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _childNameController;
  late TextEditingController _vaccinePurposeController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _doctorNameController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedStatus = 'Upcoming'; // Default status for new appointments

  // Flag to ensure initial context-dependent setup runs only once
  bool _isInitialSetupDone = false;

  @override
  void initState() {
    super.initState();
    _childNameController = TextEditingController(text: widget.appointment?.childName);
    _vaccinePurposeController = TextEditingController(text: widget.appointment?.vaccineOrPurpose);
    _locationController = TextEditingController(text: widget.appointment?.location);
    _doctorNameController = TextEditingController(text: widget.appointment?.doctorName);

    if (widget.appointment != null) {
      _selectedDate = widget.appointment!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.dateTime);
      _selectedStatus = widget.appointment!.status;
    }

    // Initialize controllers with empty text for now, context-dependent parts handled in didChangeDependencies
    _dateController = TextEditingController(
      text: _selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
    );
    _timeController = TextEditingController(text: ''); // Initialize as empty
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only run this part once for initial setup
    if (!_isInitialSetupDone) {
      if (_selectedTime != null) {
        _timeController.text = _selectedTime!.format(context); // Now context is safe to use
      }
      _isInitialSetupDone = true;
    }
  }


  @override
  void dispose() {
    _childNameController.dispose();
    _vaccinePurposeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _doctorNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime!.format(context);
      });
    }
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both date and time.')),
        );
        return;
      }

      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final newOrUpdatedAppointment = Appointment(
        id: widget.appointment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        childName: _childNameController.text.trim(),
        vaccineOrPurpose: _vaccinePurposeController.text.trim(),
        dateTime: combinedDateTime,
        status: _selectedStatus,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        doctorName: _doctorNameController.text.trim().isNotEmpty ? _doctorNameController.text.trim() : null,
      );

      Navigator.pop(context, newOrUpdatedAppointment); // Pass the new/updated appointment back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.appointment == null ? 'Schedule New Appointment' : 'Edit Appointment',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(221, 96, 22, 167),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _childNameController,
                decoration: const InputDecoration(
                  labelText: 'Child\'s Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.child_care),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vaccinePurposeController,
                decoration: const InputDecoration(
                  labelText: 'Vaccine/Purpose',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vaccines),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vaccine or purpose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true, // Make it read-only
                onTap: () => _selectDate(context), // Show date picker on tap
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                readOnly: true, // Make it read-only
                onTap: () => _selectTime(context), // Show time picker on tap
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor/Nurse (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              // Dropdown for Status (only visible for editing existing appointments)
              if (widget.appointment != null) ...[
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: <String>['Upcoming', 'Completed', 'Missed', 'Canceled']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _saveAppointment,
                icon: const Icon(Icons.save),
                label: Text(widget.appointment == null ? 'Save Appointment' : 'Update Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}