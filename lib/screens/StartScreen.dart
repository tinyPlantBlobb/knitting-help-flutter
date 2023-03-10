import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'secondScreen.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}

//State of the counter
class _StartPageState extends State<StartPage> {
  int _counter = 1;
  int _patternLength = 8;
  final key = 'count';
  final key2 = 'pattern';
  @override
  void initState(){
    super.initState();
    _read();
  }
  //load values with shared preferences plugin
  _read() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      //if no saved count exists return 1 as the next row
      _counter = prefs.getInt(key) ?? 1;
      _patternLength = prefs.getInt(key2) ?? 8;

    });
  }
  void _incrementCounter() {
    setState(() {
      _counter =  _counter % _patternLength;
      _counter++;

    });
    _save();
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _counter--;
      _counter =  _counter % _patternLength;
      _counter++;

    });
  }
  void decrement(){
    _decrementCounter();
    Navigator.pop(context);
  }

  void changePattern() async{
    final newpattern = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PatternScreen(_patternLength),));

    setState(() {
      _patternLength = newpattern;
      _counter =  1;
    });
    _save();
  }

  void resetCount(){
    setState(() {
      _counter = 1;
    });
    _save();
    Navigator.pop(context);
  }


  //save data with shared preferences plugin
  _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, _counter);
    prefs.setInt(key2, _patternLength);;
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),

      endDrawer: Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: Text('Options'),
              ),
              ListTile(
                onTap: changePattern,
                title: const Text('change Pattern'),
              ),


              ListTile(
                onTap: resetCount,
                title: const Text('reset counter'),
              ),
              
              ListTile(
                onTap:
                decrement,
                title: const Text('decrease counter'),
              ),
              
              ListTile(
                leading: const Icon(Icons.bluetooth_disabled),
                onTap: _disconnect,
                title: const Text('disconnect all devices'),
              )
            ]
        ),


      ),

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'The next row is:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            const Text('The earable is currently'),
            Text(' $_connectionStatus'),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: const Text('Increment manually',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),


      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Visibility(
            visible: !_isConnected,
            child: FloatingActionButton(
              onPressed: _connect,
              tooltip: 'connect',
              child: const Icon(Icons.bluetooth_searching_sharp),
            ),

          ),
          Visibility(
            visible: _isConnected,
            child: FloatingActionButton(
              onPressed: _disconnect,
              tooltip: 'disconnect',
              child: const Icon(Icons.bluetooth_disabled),
            ),
          ),
        ],
      ),
    );
  }



  // headphone part
  // the base code has been copied from https://github.com/teco-kit/cosinuss-flutter
  // since I'm working with the Cosinuss One headphones

  String _connectionStatus = "Disconnected";

  int accx = 0;
  int accy = 0;
  int accz = 0;

  bool _isConnected = false;

  bool earConnectFound = false;

  void updateAccelerometer(rawData) {
    Int8List bytes = Int8List.fromList(rawData);

    // description based on placing the earable into your right ear canal
    int acc_x = bytes[14];
    int acc_y = bytes[16];
    int acc_z = bytes[18];
    //s_acc_y =  stc.add(acc_y);
    if (acc_y > 0 && accy <= 0) {
      _incrementCounter();
    }
    //not tested with the earable
    if(accz.abs() > 20 &&  acc_z.abs()<= 20){
      _decrementCounter();
    }

    setState(() {
      accx = acc_x;
      accy = acc_y;
      accz = acc_z;

    });
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }

  FlutterBlue flutterBlue = FlutterBlue.instance;
  //not tested with the earable
  void _disconnect(){
    flutterBlue.connectedDevices.then((devices) async {
      for(BluetoothDevice d in devices){
        if (d.name == "earconnect" && earConnectFound){
          earConnectFound = false;
          await d.disconnect();
        }

      }
    });
  }

  void _connect() {

    // start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // listen to scan results
    flutterBlue.scanResults.listen((results) async {

      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.name == "earconnect" && !earConnectFound) {
          earConnectFound = true; // avoid multiple connects attempts to same device

          await flutterBlue.stopScan();

          r.device.state.listen((state) { // listen for connection state changes
            setState(() {
              _isConnected = state == BluetoothDeviceState.connected;
              _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
            });
          });
          await r.device.connect();

          var services = await r.device.discoverServices();

          for (var service in services) { // iterate over services
            for (var characteristic in service.characteristics) { // iterate over characterstics
              if(characteristic.uuid.toString() == "0000a001-1212-efde-1523-785feabcd123") {
                print("Starting sampling ...");
                await characteristic.write([0x32, 0x31, 0x39, 0x32, 0x37, 0x34, 0x31, 0x30, 0x35, 0x39, 0x35, 0x35, 0x30, 0x32, 0x34, 0x35]);
                await Future.delayed(new Duration(seconds: 2)); // short delay before next bluetooth operation otherwise BLE crashes
                characteristic.value.listen((rawData) => {
                  updateAccelerometer(rawData),

                });
                await characteristic.setNotifyValue(true);
                await Future.delayed(new Duration(seconds: 2));
                break;

              }
            };
          };
        }

      }
    }
    );

  }

}