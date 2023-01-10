import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
/*
* notes/ ToDO:
*         on nodd/ Y = 0 or Y <0 increase counter?
*         on moving head close to shoulder via Z -axis
*
*         max abs = 35
*
* */
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'knitting help',
      theme: ThemeData(
        // This is the theme of your application.

        primarySwatch: Colors.green,
      ),
      home: const StartPage(title: 'Knitting help'),
    );
  }
}

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

  void _incrementCounter() {
    setState(() {
      _counter =  _counter % _patternLength;
      _counter++;

    });
  }
  void changePattern() async{
    final newpattern = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PatternScreen(),));
    setState(() {
      _patternLength = newpattern;
      _counter =  1;
    });
  }
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
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
        actions: <Widget>[
          TextButton(
            style: style,
          onPressed: changePattern,
          child: const Text('change Pattern'),
          ),
        ],
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
              //sensor data display
              const Text('Accelerometer X: '),
              Text('$_accX'),
              const Text('Accelerometer Y: '),
              Text('$_accY'),
              const Text('Accelerometer Z: '),
              Text('$_accZ'),
            ElevatedButton(
                child: const Text('disconnect',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: (){
                  //disconect();
                }

            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),*/
      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: Visibility(visible: !_isConnected,
        child: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Increment',
          child: const Icon(Icons.bluetooth_searching_sharp),
        ),
      ),
    );
  }

  // headphone part
  // the base code has been copied from https://github.com/teco-kit/cosinuss-flutter since I'm working with the Cosinuss One headphones

  String _connectionStatus = "Disconnected";

  String _accX = "-";
  String _accY = "-";
  String _accZ = "-";
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
    if (acc_y > 0 && accy <= 0) {
      _incrementCounter();
    }

    setState(() {
      accx = acc_x;
      accy = acc_y;
      accz = acc_z;
      _accX = acc_x.toString() + " (unknown unit)";
      _accY = acc_y.toString() + " (unknown unit)";
      _accZ = acc_z.toString() + " (unknown unit)";
    });
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }
  FlutterBlue flutterBlue = FlutterBlue.instance;
  void _connect() {


    // start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) async {

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

class PatternScreen extends StatefulWidget{
  const PatternScreen({super.key});

  @override
  State<PatternScreen> createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  int _patternLength = 8;
  TextEditingController patternController = TextEditingController();

//input
  void onTextInput(String newInput) {
    setState(() {
      _patternLength = int.parse(newInput);
    });
    Navigator.pop(context, _patternLength);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    patternController.dispose();
    super.dispose();
  }

  void _sendDataBack(BuildContext context) {
    String textToSendBack = patternController.text;
    var string = int.tryParse(textToSendBack);
    if ( string != null){
      setState(() {
        _patternLength = int.parse(textToSendBack);
      });
    }
    Navigator.pop(context, _patternLength);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: const Text("Pattern Length"),
      ),
      body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(32.0),
            child: const Text('the current pattern length is'),
            ),


              Text(
                '$_patternLength',
                style: Theme.of(context).textTheme.headline4,
              ),
              TextField(
              onSubmitted: onTextInput,
              controller: patternController,
              decoration: const InputDecoration(labelText: "Enter the pattern length"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
            ElevatedButton(
                child: const Text('change pattern',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: (){ _sendDataBack(context);}

            ),
          ],

      ),


    );
  }
}
