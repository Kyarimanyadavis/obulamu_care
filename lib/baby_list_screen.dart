import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'edit_baby_screen.dart';

class BabyListScreen extends StatelessWidget {
  const BabyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Babies'),
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('babies').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No baby records found.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final timestamp = data['birthDate'] as Timestamp;
                  final birthDate = timestamp.toDate();
                  final formattedBirthDate = DateFormat.yMMMMd().format(
                    birthDate,
                  );

                  final vaccineScheduleMap = Map<String, dynamic>.from(
                    data['vaccineSchedule'],
                  );
                  final vaccineSchedule = vaccineScheduleMap.map(
                    (key, value) => MapEntry(DateTime.parse(key), value),
                  );

                  final firstVaccineDate = vaccineSchedule.keys.first;
                  final firstVaccineName = vaccineSchedule[firstVaccineDate];
                  final formattedVaccineDate = DateFormat.yMMMMd().format(
                    firstVaccineDate,
                  );

                  return Card(
                    color: Colors.white10.withAlpha((0.2 * 255).toInt()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(
                        Icons.child_care,
                        color: Colors.white,
                        size: 36,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['babyName'] ?? 'Unnamed Baby',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Gender: ${data['gender']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Mother: ${data['motherName']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Father: ${data['fatherName']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Birth Date: $formattedBirthDate",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "1st Vaccine: $firstVaccineName",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            "Due Date: $formattedVaccineDate",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Location: ${data['district']}, ${data['county']}, ${data['subcounty']}, ${data['parish']}, ${data['village']}",
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => EditBabyScreen(
                                        documentId: doc.id,
                                        existingData: data,
                                      ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.print, color: Colors.white),
                            onPressed: () {
                              generateAndPrintReport(data);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void generateAndPrintReport(Map<String, dynamic> babyData) async {
    final pdf = pw.Document();
    final birthDate = (babyData['birthDate'] as Timestamp).toDate();
    final vaccineSchedule = Map<String, dynamic>.from(
      babyData['vaccineSchedule'],
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Baby Vaccination Report",
                style: pw.TextStyle(fontSize: 24),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Name: ${babyData['babyName']}"),
              pw.Text("Gender: ${babyData['gender']}"),
              pw.Text("Mother: ${babyData['motherName']}"),
              pw.Text("Father: ${babyData['fatherName']}"),
              pw.Text("Birth Date: ${DateFormat.yMMMMd().format(birthDate)}"),
              pw.SizedBox(height: 10),
              pw.Text("Location:"),
              pw.Text("  District: ${babyData['district']}"),
              pw.Text("  County: ${babyData['county']}"),
              pw.Text("  Subcounty: ${babyData['subcounty']}"),
              pw.Text("  Parish: ${babyData['parish']}"),
              pw.Text("  Village: ${babyData['village']}"),
              pw.SizedBox(height: 10),
              pw.Text("Vaccine Schedule:"),
              ...vaccineSchedule.entries.map((entry) {
                final date = DateFormat.yMMMMd().format(
                  DateTime.parse(entry.key),
                );
                return pw.Text("  $date: ${entry.value}");
              }),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
