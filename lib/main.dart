
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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
          onPressed: () {Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PatternScreen()),
          );},
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
  final patternController = TextEditingController();

  void onTextInput(String newInput) {
    setState(() {
      _patternLength = int.parse(newInput);
    });
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    patternController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: const Text("Pattern Length"),
      ),
      body: Column(
          children: <Widget>[
            UserInput(onTextInput: onTextInput),
              const Text('the current pattern length is'),

              Text(
                '$_patternLength',
                style: Theme.of(context).textTheme.headline4,
              ),
          ],
      ),
    );
  }
}
 class UserInput extends StatelessWidget {
   const UserInput({Key? key, required this.onTextInput}) : super(key: key);
   final void Function(String) onTextInput;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onTextInput,
      decoration: const InputDecoration(labelText: "Enter the pattern length"),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        FilteringTextInputFormatter.digitsOnly
      ],

    );
  }



}