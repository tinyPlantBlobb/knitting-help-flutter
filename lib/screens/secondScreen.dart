import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class PatternScreen extends StatefulWidget{
  const PatternScreen(this.patternLength, {super.key});
  final int patternLength;

  @override
  State<PatternScreen> createState() => _PatternScreenState();
}

class _PatternScreenState extends State<PatternScreen> {
  int _patternLength = 8;
  TextEditingController patternController = TextEditingController();

//input over in build function
  void onTextInput(String newInput) {
    var string = int.tryParse(newInput)??0;
    if (string ==0){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xccd60000),
              behavior: SnackBarBehavior.floating,
            content: Text('please enter a valid Number'),
            duration: Duration(seconds: 10),
          ),
      );
    } else {
      setState(() {
        _patternLength = int.parse(newInput);
      });
      Navigator.pop(context, _patternLength);
      Navigator.pop(context);
    }

  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    patternController.dispose();
    super.dispose();
  }

  //send input back over button
  void _sendDataBack(BuildContext context) {
    String textToSendBack = patternController.text;
    onTextInput(textToSendBack);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: const Text("Pattern Length"),
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('the current pattern length is'),
          ),


          Text(
            '${widget.patternLength}',
            style: Theme.of(context).textTheme.headline4,
          ),
          TextField(
            onSubmitted: onTextInput,
            controller: patternController,
            decoration: const InputDecoration(labelText: "Enter the pattern length"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
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