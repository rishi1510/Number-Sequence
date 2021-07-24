import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _difficulty = 4;
  List<int> _n = new List(50);
  int _count = 1, _reset = 0;
  List<bool> _visible = List.filled(50, true);
  List<String> _highScore = new List(8);

  String displayTime = "00:00";
  var sWatch = Stopwatch();
  final dur = const Duration(seconds: 1);

  void startTimer() {
    Timer(dur, keeprunning);
  }

  void keeprunning() {
    if (sWatch.isRunning) {
      startTimer();
    }
    setState(() {
      displayTime = (sWatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
          ":" +
          (sWatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
    });
  }

  void startStopWatch() {
    sWatch.start();
    startTimer();
  }

  void _rng() {
    int grid = _difficulty * _difficulty;
    List list = List.generate(grid, (i) => i);

    list.shuffle();
    for (int i = 0; i < grid; i++) {
      _n[i] = (list[i] + 1);
    }
  }

  void _toggle(int no) {
    int grid = _difficulty * _difficulty;
    if (_n[no] == _count) {
      if (_count == 1) {
        startStopWatch();
      }
      setState(() {
        _count++;
        _visible[no] = !_visible[no];
      });
      if (_count == grid + 1) {
        sWatch.stop();
        if (_highScore[_difficulty] == null ||
            _highScore[_difficulty].compareTo(displayTime) == 1) {
          _highScore[_difficulty] = displayTime;
          showNewHS(context);
        } else {
          showAlertDialog(context);
        }
      }
    }
  }

  void _restart() {
    int grid = _difficulty * _difficulty;
    _reset = 0;
    _count = 1;
    for (int i = 0; i < grid; i++) {
      _visible[i] = true;
    }
    sWatch.stop();
    sWatch.reset();
    displayTime = "00:00";
    setState(() {});
  }

  showNewHS(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(fontSize: 20.0)),
      onPressed: () {
        _restart();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('New Best Time!'),
      content: Text(
        "Finished in $displayTime",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 25.0),
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(fontSize: 20.0)),
      onPressed: () {
        _restart();
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(''),
      content: Text(
        "Finished in $displayTime",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget timer() {
    double topMargin = 20.0;
    if (_difficulty >= 6) {
      topMargin = 0.0;
    }
    return Container(
        child: Padding(
            padding: EdgeInsets.only(top: topMargin),
            child: Text(displayTime,
                style:
                    TextStyle(fontSize: 50.0, fontWeight: FontWeight.w400))));
  }

  Widget score() {
    String score = '';
    if (_highScore[_difficulty] != null) {
      score = 'Best Time: ' + _highScore[_difficulty];
    }

    return Container(
        margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: Text(score, style: TextStyle(fontSize: 30.0)));
  }

  Widget button(int no) {
    double topMargin = 8.0;
    if (no < _difficulty) {
      topMargin = 20.0;
    }
    return Container(
        width: MediaQuery.of(context).size.width / _difficulty,
        child: Padding(
            padding: EdgeInsets.only(top: topMargin, bottom: 8.0),
            child: Visibility(
              child: TextButton(
                style: TextButton.styleFrom(primary: Colors.black),
                onPressed: () => {_toggle(no)},
                child: Text(_n[no].toString() + ' ',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.w400)),
              ),
              visible: _visible[no],
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
            )));
  }

  Widget colButtons(int start) {
    return Row(
      children: [for (int i = 0; i < _difficulty; i++) button(start + i)],
    );
  }

  void handleClick(String value) {
    switch (value) {
      case '3x3':
        _difficulty = 3;
        break;
      case '4x4':
        _difficulty = 4;
        break;
      case '5x5':
        _difficulty = 5;
        break;
      case '6x6':
        _difficulty = 6;
        break;
      case '7x7':
        _difficulty = 7;
        break;
    }
    _restart();
  }

  @override
  Widget build(BuildContext context) {
    if (_reset == 0) {
      _rng();
      _reset++;
    }

    int grid = _difficulty * _difficulty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            offset: Offset(0, 400),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                "Select Difficulty",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
              ),
            ),
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'3x3', '4x4', '5x5', '6x6', '7x7'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: InkWell(
        child: Column(
          children: [
            for (int i = 0; i < grid; i += _difficulty) colButtons(i),
            Spacer(),
            timer(),
            score()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _restart,
        child: Text('Reset'),
      ),
    );
  }
}
