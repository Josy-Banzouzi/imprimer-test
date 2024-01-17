import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  List<BluetoothDevice> _devices = [];
  String tips = 'no device connect';

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    if (!mounted) return;
    // bool isConnected = await bluetoothPrint.isConnected ?? false;
    bluetoothPrint.scanResults.listen((state) {
      if (!mounted) {
        setState(() {
          _devices = state;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Choisir une impremente"),
          centerTitle: true,
        ),
    body: _devices.isEmpty
    ? Center(
    child: Text(tips),
    )
        : ListView.builder(itemBuilder: (_, index) {
            return ListTile(
                leading: const Icon(Icons.print),
                title: Text(_devices[index].name!),
                subtitle: Text(_devices[index].address!),
                onTap: () async {
                await _startPrint(_devices[index]);
            },
          );
    }));
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device.address != null) {
      await bluetoothPrint.connect(device);
      Map<String, dynamic> config = {};
      config['width'] = 40;
      config['height'] = 70;
      config['gap'] = 2;
      List<LineText> list = [];

      list.add(LineText(type: LineText.TYPE_TEXT, content: "Hello TEST", weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: "REUSSI", weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));

      // here add configuration
      await bluetoothPrint.printReceipt(config, list);
    }
  }

}
