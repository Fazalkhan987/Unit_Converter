import 'package:flutter/material.dart';

class P1 extends StatelessWidget {
  const P1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        title: const Text("Temperature Converter"),
        backgroundColor: const Color(0xFF4A55A2),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: PP1()
      ),
    );
  }
}













class PP1 extends StatefulWidget {
  const PP1({super.key});

  @override
  State<PP1> createState() => _PP1State();
}

class _PP1State extends State<PP1> {
    final TextEditingController inputController = TextEditingController();

  String inputValue = "";

  double result = 0;

  List<String> units = [
    "Celsius",
    "Fahrenheit",
    "Kelvin",
  ];

  String fromUnit = "Celsius";
  String toUnit = "Fahrenheit";

  ////////////////////////////////////////////////////////////////////
  /// CONVERSION FUNCTION
  ////////////////////////////////////////////////////////////////////

  void convertTemperature() {
    if (inputValue.isEmpty) {
      setState(() {
        result = 0;
      });
      return;
    }

    double value = double.tryParse(inputValue) ?? 0;

    double tempInCelsius = 0;

    /// Convert FROM selected unit TO Celsius
    if (fromUnit == "Celsius") {
      tempInCelsius = value;
    } else if (fromUnit == "Fahrenheit") {
      tempInCelsius = (value - 32) * 5 / 9;
    } else if (fromUnit == "Kelvin") {
      tempInCelsius = value - 273.15;
    }

    /// Convert Celsius TO selected output unit
    if (toUnit == "Celsius") {
      result = tempInCelsius;
    } else if (toUnit == "Fahrenheit") {
      result = (tempInCelsius * 9 / 5) + 32;
    } else if (toUnit == "Kelvin") {
      result = tempInCelsius + 273.15;
    }

    setState(() {});
  }


  Widget keyboardButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (text == "🔙") {
              if (inputValue.isNotEmpty) {
                inputValue =
                    inputValue.substring(0, inputValue.length - 1);
              }
            } else {
              inputValue += text;
            }

            inputController.text = inputValue;

            convertTemperature();

            setState(() {});
          },
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Container(
              color: const Color(0xFFF4F5FA),
              height: MediaQuery.of(context).size.height * 0.45,
              child: Column(children: [
              
            TextField(
              controller: inputController,
              readOnly: true,

              decoration: InputDecoration(
                hintText: "Enter Temperature",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A55A2), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 40,
              child: DropdownButtonFormField(
                value: fromUnit,
                decoration: const InputDecoration(
                  labelText: "From",
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
                items: units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  fromUnit = value!;
                  convertTemperature();
                  setState(() {});
                },
              ),
            ),

            // const SizedBox(height: 5),

            ////////////////////////////////////////////////////////////
            /// SWITCH BUTTON
            ////////////////////////////////////////////////////////////

            IconButton(
              onPressed: () {
                String temp = fromUnit;
                fromUnit = toUnit;
                toUnit = temp;

                convertTemperature();

                setState(() {});
              },
              icon: const Icon(
                Icons.swap_vert,
                size: 35,
                color: Color(0xFF4A55A2),
              ),
            ),

            // const SizedBox(height: 5),

            ////////////////////////////////////////////////////////////
            /// TO UNIT
            ////////////////////////////////////////////////////////////

            SizedBox(
              height: 40,
              child: DropdownButtonFormField(
                value: toUnit,
                decoration: const InputDecoration(
                  labelText: "To",
                    contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
                items: units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  toUnit = value!;
                  convertTemperature();
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 5),

            ////////////////////////////////////////////////////////////
            /// OUTPUT
            ////////////////////////////////////////////////////////////

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A55A2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // const Text(
                  //   "Converted Temperature",
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //   ),
                  // ),

                  // const SizedBox(height: 10),

                  Text(
                    result.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    toUnit,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // const Spacer(),

            ],),),
            ////////////////////////////////////////////////////////////
            /// CUSTOM KEYBOARD
            ////////////////////////////////////////////////////////////

            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        keyboardButton("1"),
                        keyboardButton("2"),
                        keyboardButton("3"),
                      ],
                    ),
                
                    Row(
                      children: [
                        keyboardButton("4"),
                        keyboardButton("5"),
                        keyboardButton("6"),
                      ],
                    ),
                
                    Row(
                      children: [
                        keyboardButton("7"),
                        keyboardButton("8"),
                        keyboardButton("9"),
                      ],
                    ),
                
                    Row(
                      children: [
                        keyboardButton("."),
                        keyboardButton("0"),
                        keyboardButton("🔙"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // var ic = TextEditingController();
  // String iv = "";
  // double r = 0;
  // List<String> ts = ["C", "F", "K"];
  // String f = "C";
  // String t = "F";
  // @override
  // Widget build(BuildContext context) {
  //   return Container(child: Column(
  //     children: [
  //       TextField(controller: ic),
  //       ElevatedButton(onPressed: (){
  //         print(ic.text);
  //       }, child: Text("data"))
  //     ],
  //   ));
  // }
}
