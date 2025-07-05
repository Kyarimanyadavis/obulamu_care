import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:obulamucare/add_baby.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final String userName = "User"; // Replace or fetch the real user name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 96, 22, 167),
        leading: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(70.0),
            child: Image.asset(
              'assets/images/logo-.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          "Welcome, $userName",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
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

          // Blur & gradient overlay
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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BabyScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/baby.png',
                                  width: 40,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                                const FaIcon(
                                  FontAwesomeIcons.syringe,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "NEW BABY",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Grid items
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDashboardGridItem(
                          icon: FontAwesomeIcons.userDoctor,
                          label: "Doctors",
                          color: Colors.deepPurple,
                        ),
                        _buildDashboardGridItem(
                          icon: FontAwesomeIcons.syringe,
                          label: "Immunizations",
                          color: Colors.teal,
                        ),
                        _buildDashboardGridItem(
                          icon: FontAwesomeIcons.calendarCheck,
                          label: "Appointments",
                          color: Colors.orange,
                        ),
                        _buildDashboardGridItem(
                          icon: FontAwesomeIcons.notesMedical,
                          label: "Records",
                          color: Colors.pink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGridItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle tap
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
