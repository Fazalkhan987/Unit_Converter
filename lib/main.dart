import "package:flutter/material.dart";
import "package:unit_converter/pages/calculator.dart";
import "package:unit_converter/pages/date_time_calculator.dart";
import "package:unit_converter/pages/area.dart";
import "package:unit_converter/pages/length.dart";
import "package:unit_converter/pages/mass.dart";
import "package:unit_converter/pages/temprature.dart";
import "package:unit_converter/pages/programming.dart";
import "package:unit_converter/pages/time_converter.dart";
import "package:unit_converter/pages/volume.dart";
import "package:unit_converter/pages/speed.dart";
import "package:unit_converter/pages/energy.dart";
import "package:unit_converter/pages/power.dart";
import "package:unit_converter/pages/pressure.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Unit", 
    debugShowCheckedModeBanner: false,
    home: const MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> as = [
    {"icon": Icons.home, "label": "Time"},
    {"icon": Icons.calendar_month, "label": "Date"},
    {"icon": Icons.straighten, "label": "Length"},
    {"icon": Icons.scale, "label": "Mass"},
    {"icon": Icons.code, "label": "Computer"},
    {"icon": Icons.thermostat, "label": "Temperature"},
    {"icon": Icons.crop, "label": "Area"},
    {"icon": Icons.bubble_chart, "label": "Volume"},
    {"icon": Icons.speed, "label": "Speed"},
    {"icon": Icons.electric_bolt, "label": "Energy"},
    {"icon": Icons.watch_later, "label": "Power"},
    {"icon": Icons.air, "label": "Pressure"},
    {"icon": Icons.calculate, "label": "Calculator"},
  ];
  List<Widget> screens = [
    const Time_Converter(),
    const DateConverterPage(),
    const LengthConverterPage(),
    const MassConverterPage(),
    const ProgrammingConverterPage(),
    const P1(),
    const AreaConverterPage(),
    const VolumeConverterPage(),
    const SpeedConverterPage(),
    const EnergyConverterPage(),
    const PowerConverterPage(),
    const PressureConverterPage(),
    const Calculator(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 18, 24),
      appBar: AppBar(title: Text("Home"), backgroundColor: Color(0xFF4A55A2)),
      body: Container(
        padding: EdgeInsets.only(top: 20, left: 10, right: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
          ),
          itemCount: as.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screens[index]),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 79, 78, 78),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 40, 40, 40),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(as[index]["icon"], color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      as[index]["label"],
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
