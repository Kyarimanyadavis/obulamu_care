// lib/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure this is imported for date formatting
import 'package:obulamucare/appointment_form_screeen.dart';

// Make sure your Appointment model and AppointmentFormScreen path are correct


// Model for an Appointment (Keep this as it was in your file)
class Appointment {
  final String id;
  final String childName;
  final String vaccineOrPurpose;
  final DateTime dateTime;
  final String status; // e.g., 'Upcoming', 'Completed', 'Missed', 'Canceled'
  final String? location;
  final String? doctorName;

  Appointment({
    required this.id,
    required this.childName,
    required this.vaccineOrPurpose,
    required this.dateTime,
    required this.status,
    this.location,
    this.doctorName,
  });

  // Helper method to create a copy for editing (useful for immutable objects)
  Appointment copyWith({
    String? id,
    String? childName,
    String? vaccineOrPurpose,
    DateTime? dateTime,
    String? status,
    String? location,
    String? doctorName,
  }) {
    return Appointment(
      id: id ?? this.id,
      childName: childName ?? this.childName,
      vaccineOrPurpose: vaccineOrPurpose ?? this.vaccineOrPurpose,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      location: location ?? this.location,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // NEW: Filter date variable
  DateTime? _filterDate;

  // Existing dummy data (keep as is)
  final List<Appointment> _allAppointments = [
    Appointment(
      id: 'app1',
      childName: 'Baby Michael',
      vaccineOrPurpose: 'Measles Vaccine (Dose 1)',
      dateTime: DateTime.now().add(const Duration(days: 7, hours: 2, minutes: 30)),
      status: 'Upcoming',
      location: 'City Health Clinic',
      doctorName: 'Dr. Jane Smith',
    ),
    Appointment(
      id: 'app2',
      childName: 'Baby Jane',
      vaccineOrPurpose: '6-Month Check-up',
      dateTime: DateTime.now().add(const Duration(days: 14, hours: 10, minutes: 0)),
      status: 'Upcoming',
      location: 'Pediatric Center',
      doctorName: 'Dr. Robert Johnson',
    ),
    Appointment(
      id: 'app3',
      childName: 'Baby Alex',
      vaccineOrPurpose: 'Polio Booster',
      dateTime: DateTime.now().subtract(const Duration(days: 30, hours: 5, minutes: 15)),
      status: 'Completed',
      location: 'Community Clinic',
      doctorName: 'Dr. Emily White',
    ),
    Appointment(
      id: 'app4',
      childName: 'Baby Sarah',
      vaccineOrPurpose: 'HPV Vaccine (Dose 1)',
      dateTime: DateTime.now().subtract(const Duration(days: 90, hours: 1, minutes: 45)),
      status: 'Missed',
      location: 'District Hospital',
      doctorName: 'Dr. Adam Green',
    ),
    Appointment(
      id: 'app5',
      childName: 'Baby Michael',
      vaccineOrPurpose: 'Hepatitis B (Birth Dose)',
      dateTime: DateTime.now().subtract(const Duration(days: 180, hours: 1, minutes: 0)),
      status: 'Completed',
      location: 'Private Hospital',
      doctorName: 'Dr. Jane Smith',
    ),
    Appointment(
      id: 'app6',
      childName: 'Baby Jane',
      vaccineOrPurpose: 'DTP-Hib-HepB (Dose 3)',
      dateTime: DateTime.now().add(const Duration(days: 21, hours: 9, minutes: 0)),
      status: 'Upcoming',
      location: 'City Health Clinic',
      doctorName: 'Dr. Jane Smith',
    ),
  ];

  // Modified getters to apply filter
  List<Appointment> get _upcomingAppointments {
    List<Appointment> filteredList = _allAppointments
        .where((app) => app.status == 'Upcoming' && app.dateTime.isAfter(DateTime.now()))
        .toList();

    if (_filterDate != null) {
      filteredList = filteredList.where((app) =>
          app.dateTime.year == _filterDate!.year &&
          app.dateTime.month == _filterDate!.month &&
          app.dateTime.day == _filterDate!.day
      ).toList();
    }
    filteredList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filteredList;
  }

  List<Appointment> get _pastAppointments {
    List<Appointment> filteredList = _allAppointments
        .where((app) => app.status != 'Upcoming' || app.dateTime.isBefore(DateTime.now()))
        .toList();

    if (_filterDate != null) {
      filteredList = filteredList.where((app) =>
          app.dateTime.year == _filterDate!.year &&
          app.dateTime.month == _filterDate!.month &&
          app.dateTime.day == _filterDate!.day
      ).toList();
    }
    filteredList.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Sort by date descending (most recent first)
    return filteredList;
  }


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper function to determine the color for appointment status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue.shade700;
      case 'Completed':
        return Colors.green.shade700;
      case 'Missed':
        return Colors.red.shade700;
      case 'Canceled':
        return Colors.grey.shade600;
      default:
        return Colors.grey; // Fallback color
    }
  }

  // Function to handle adding a new appointment
  void _addAppointment(Appointment newAppointment) {
    setState(() {
      _allAppointments.add(newAppointment);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment added successfully!')),
    );
  }

  // Function to handle editing an existing appointment
  void _editAppointment(Appointment updatedAppointment) {
    setState(() {
      final index = _allAppointments.indexWhere((app) => app.id == updatedAppointment.id);
      if (index != -1) {
        _allAppointments[index] = updatedAppointment;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment updated successfully!')),
    );
  }

  // Function to handle deleting an appointment
  void _deleteAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this appointment? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _allAppointments.removeWhere((app) => app.id == appointmentId);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment deleted!')),
                );
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // NEW: Method to select filter date
  Future<void> _selectFilterDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: 'Select Appointment Date',
      confirmText: 'FILTER',
      cancelText: 'CLEAR FILTER', // Customize cancel text to clear filter
    );

    setState(() {
      if (pickedDate != null && pickedDate != _filterDate) {
        // A new date was picked
        _filterDate = pickedDate;
      } else if (pickedDate == null && _filterDate != null) {
        // User explicitly tapped 'CLEAR FILTER' (which is the cancel button now)
        _filterDate = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date filter cleared.')),
        );
      }
      // If pickedDate is null and _filterDate was already null, do nothing (no filter to clear)
      // If pickedDate is the same as _filterDate, do nothing (filter already active for that date)
    });
  }

  // Widget to build an individual appointment card for display
  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(appointment.dateTime), // e.g., "Tue, Jul 8, 2025"
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Using your app's primary color
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('h:mm a').format(appointment.dateTime), // e.g., "10:30 AM"
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 20, thickness: 1), // Visual separator
            Text(
              appointment.vaccineOrPurpose,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'For: ${appointment.childName}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            // Conditionally display doctor and location if available
            if (appointment.doctorName != null && appointment.doctorName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Doctor: ${appointment.doctorName}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
            if (appointment.location != null && appointment.location!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Location: ${appointment.location}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 12),
            // Actions for the appointment
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // PopUpMenu for more actions
                PopupMenuButton<String>(
                  onSelected: (String result) async {
                    switch (result) {
                      case 'edit':
                        final updatedAppointment = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentFormScreen(appointment: appointment),
                          ),
                        );
                        if (updatedAppointment != null && updatedAppointment is Appointment) {
                          _editAppointment(updatedAppointment);
                        }
                        break;
                      case 'cancel':
                        if (appointment.status == 'Upcoming') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cancel action for ${appointment.childName}')),
                          );
                          // TODO: Implement actual cancel logic (e.g., update status in backend)
                          _editAppointment(appointment.copyWith(status: 'Canceled')); // Update status locally
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Only upcoming appointments can be cancelled.')),
                          );
                        }
                        break;
                      case 'reschedule':
                        if (appointment.status == 'Upcoming') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reschedule action for ${appointment.childName}')),
                          );
                          // TODO: Implement actual reschedule logic (e.g., navigate to form with new date pre-selected)
                          final rescheduledAppointment = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentFormScreen(appointment: appointment), // Re-use form for reschedule
                            ),
                          );
                          if (rescheduledAppointment != null && rescheduledAppointment is Appointment) {
                            _editAppointment(rescheduledAppointment);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Only upcoming appointments can be rescheduled.')),
                          );
                        }
                        break;
                      case 'delete':
                        _deleteAppointment(appointment.id);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Appointment'),
                      ),
                    ),
                    if (appointment.status == 'Upcoming') // Only show cancel/reschedule for upcoming
                      const PopupMenuItem<String>(
                        value: 'reschedule',
                        child: ListTile(
                          leading: Icon(Icons.calendar_month),
                          title: Text('Reschedule'),
                        ),
                      ),
                    if (appointment.status == 'Upcoming') // Only show cancel/reschedule for upcoming
                      const PopupMenuItem<String>(
                        value: 'cancel',
                        child: ListTile(
                          leading: Icon(Icons.cancel),
                          title: Text('Cancel Appointment'),
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete Appointment'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(221, 96, 22, 167), // Match your app's theme
        iconTheme: const IconThemeData(color: Colors.white), // For back button icon
        actions: [
          // NEW: Search/Filter button in AppBar
          IconButton(
            icon: const Icon(Icons.calendar_month), // Icon for date filtering
            tooltip: 'Filter by date',
            onPressed: () => _selectFilterDate(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // Color of the selected tab indicator
          labelColor: Colors.white, // Color of the selected tab's text
          unselectedLabelColor: Colors.white70, // Color of unselected tabs' text
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Column( // Use Column to place filter feedback above TabBarView
        children: [
          // NEW: Filter feedback display
          if (_filterDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: Colors.grey.shade100, // Light background for filter info
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing appointments for: ${DateFormat('EEE, MMM d, yyyy').format(_filterDate!)}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  InkWell( // Use InkWell for a clickable clear button
                    onTap: () {
                      setState(() {
                        _filterDate = null; // Clear the filter
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Date filter cleared.')),
                      );
                    },
                    child: const Icon(Icons.close, size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
          Expanded( // Make TabBarView take remaining space
            child: TabBarView(
              controller: _tabController,
              children: [
                // Content for the "Upcoming Appointments" tab
                _upcomingAppointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_note, size: 80, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'No upcoming appointments scheduled!',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap the "+" button to schedule one.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _upcomingAppointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),

                // Content for the "Past Appointments" tab
                _pastAppointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 80, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'No past appointments recorded.',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _pastAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _pastAppointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the form to add a new appointment
          final newAppointment = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AppointmentFormScreen()),
          );
          // If a new appointment was returned from the form, add it to the list
          if (newAppointment != null && newAppointment is Appointment) {
            _addAppointment(newAppointment);
          }
        },
        backgroundColor: const Color.fromARGB(221, 96, 22, 167), // Match your app's theme
        foregroundColor: Colors.white, // Icon color
        child: const Icon(Icons.add), // Plus icon
      ),
    );
  }
}