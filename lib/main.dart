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
  String tips = "";


  Future<void> initBluetooth() async {

    bluetoothPrint.startScan(timeout: const Duration(seconds: 2));

    if (!mounted) return;
    // bool isConnected = await bluetoothPrint.isConnected ?? false;
    bluetoothPrint.scanResults.listen((val) {
      if (!mounted) return;
        setState(() {
          _devices = val;
        });
      if(_devices.isEmpty){
        setState(() {
          tips = "No devices";
        });
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
        await initBluetooth();
    });
    super.initState();
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
        : ListView.builder(
         itemCount: _devices.length,
         itemBuilder: (_, index) {
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

      bool isConnected = await bluetoothPrint.isConnected ?? false;

      if(!isConnected){
         await bluetoothPrint.connect(device);
      }


      print(isConnected);

      Map<String, dynamic> config = Map();
      List<LineText> list = [];
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Maitre Josy', weight: 1, align: LineText.ALIGN_CENTER,linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent left', weight: 0, align: LineText.ALIGN_LEFT,linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'this is conent right', align: LineText.ALIGN_RIGHT,linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_BARCODE, content: 'A12312112', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_QRCODE, content: 'qrcode i', size:10, align: LineText.ALIGN_CENTER, linefeed: 1));
      list.add(LineText(linefeed: 1));

      // here add configuration
      await bluetoothPrint.printReceipt(config, list);

    }
  }

}
