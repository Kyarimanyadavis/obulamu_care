import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:obulamucare/add_baby.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final String userName = "User"; // Replace "User" with the actual user name or fetch dynamically

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 96, 22, 167),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Image.asset(
              'assets/images/eye.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          "Welcome, $userName",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 49, 3, 26), Color.fromARGB(255, 76, 123, 146), Color.fromARGB(255, 138, 6, 116)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(96, 125, 139, 1),
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
                            IconButton(
  icon: Icon(FontAwesomeIcons.syringe),
  onPressed: () {
    Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const BabyScreen(),
                                  ),
                                );
  },
)
                          ],
                        ),
                        SizedBox(height: 20),
      Text(
        "NEW BABY",
        style: TextStyle(color: const Color.fromARGB(255, 255, 254, 252), fontSize: 26),
      ),
                       
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    physics: NeverScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildDashboardGridItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle tap if needed
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, color: Colors.white, size: 36),
              SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}