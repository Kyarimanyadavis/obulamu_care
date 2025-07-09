import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:obulamucare/appointments_screen.dart';

class AppointmentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'appointments';

  // Get all appointments as a stream
  static Stream<List<Appointment>> getAppointmentsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Appointment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get appointments for a specific date
  static Stream<List<Appointment>> getAppointmentsByDateStream(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where(
          'dateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Appointment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Add a new appointment
  static Future<String> addAppointment(Appointment appointment) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(appointment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add appointment: $e');
    }
  }

  // Update an existing appointment
  static Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Delete an appointment
  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Get upcoming appointments
  static Stream<List<Appointment>> getUpcomingAppointmentsStream() {
    return _firestore
        .collection(_collection)
        .where('dateTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .where('status', isEqualTo: 'Upcoming')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Appointment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get past appointments
  static Stream<List<Appointment>> getPastAppointmentsStream() {
    return _firestore
        .collection(_collection)
        .where('dateTime', isLessThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Appointment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get appointments by status
  static Stream<List<Appointment>> getAppointmentsByStatusStream(
    String status,
  ) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Appointment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get appointments for a specific child
  static Stream<List<Appointment>> getAppointmentsByChildStream(
    String childName,
  ) {
    return _firestore
        .collection(_collection)
        .where('childName', isEqualTo: childName)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Appointment.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
