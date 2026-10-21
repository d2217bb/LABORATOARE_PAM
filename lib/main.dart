import 'package:flutter/material.dart';

void main() {
  runApp(const DiscountApp());
}

class DiscountApp extends StatelessWidget {
  const DiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const DiscountPage(),
    );
  }
}

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  // controllers for user inputs
  final TextEditingController priceController = TextEditingController();
  final TextEditingController customPercentController = TextEditingController();

  double selectedPercent = 10;
  bool isCustomSelected = false;

  // variables for step-by-step breakdown
  double initialPrice = 0;
  double appliedPercent = 0;
  double discountAmount = 0;
  double finalPrice = 0;
  bool showResults = false;

  @override
  void dispose() {
    // clean up controllers
    priceController.dispose();
    customPercentController.dispose();
    super.dispose();
  }

  void calculate() {
    // parse price input
    double price = double.tryParse(priceController.text) ?? 0;
    double percent = selectedPercent;

    // use custom percentage if selected
    if (isCustomSelected) {
      percent = double.tryParse(customPercentController.text) ?? 0;
    }

    // calculate discount and total
    double discount = price * percent / 100;
    double total = price - discount;

    setState(() {
      initialPrice = price;
      appliedPercent = percent;
      discountAmount = discount;
      finalPrice = total;
      showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // step 1: enter price
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Step 1: Initial Price (MDL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),

            // step 2: pick discount percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Step 2: Select discount:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                DropdownButton<double>(
                  value: isCustomSelected ? -1.0 : selectedPercent,
                  items: const [
                    DropdownMenuItem(value: 5.0, child: Text('5%')),
                    DropdownMenuItem(value: 10.0, child: Text('10%')),
                    DropdownMenuItem(value: 15.0, child: Text('15%')),
                    DropdownMenuItem(value: 20.0, child: Text('20%')),
                    DropdownMenuItem(value: 25.0, child: Text('25%')),
                    DropdownMenuItem(value: 30.0, child: Text('30%')),
                    DropdownMenuItem(value: 40.0, child: Text('40%')),
                    DropdownMenuItem(value: 50.0, child: Text('50%')),
                    DropdownMenuItem(value: -1.0, child: Text('Custom %')),
                  ],
                  onChanged: (double? value) {
                    if (value != null) {
                      setState(() {
                        if (value == -1.0) {
                          isCustomSelected = true;
                        } else {
                          isCustomSelected = false;
                          selectedPercent = value;
                        }
                      });
                    }
                  },
                ),
              ],
            ),

            // optional field for custom discount %
            if (isCustomSelected) ...[
              const SizedBox(height: 10),
              TextField(
                controller: customPercentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Enter custom percentage (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
              ),
            ],

            const SizedBox(height: 25),

            // calculate button
            ElevatedButton(
              onPressed: calculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Calculate Breakdown', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 30),

            // step 3: display breakdown results
            if (showResults)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculation Breakdown:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('• Initial Price: ${initialPrice.toStringAsFixed(2)} MDL'),
                      const SizedBox(height: 5),
                      Text('• Discount Applied: ${appliedPercent.toStringAsFixed(1)}%'),
                      const SizedBox(height: 5),
                      Text(
                        '• Saved Amount: ${discountAmount.toStringAsFixed(2)} MDL',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      Text(
                        'Final Price: ${finalPrice.toStringAsFixed(2)} MDL',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
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
}