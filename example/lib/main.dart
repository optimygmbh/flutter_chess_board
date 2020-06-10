import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ChessBoardController chessBoardController;

  final movesOnlyThroughController = true;

  @override
  void initState() {
    chessBoardController = ChessBoardController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.access_alarm),
            onPressed: () => chessBoardController.makeMoveSAN('d5'),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() => {}),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ChessBoard(
              onMove: (move) {
                if (movesOnlyThroughController) {
                  chessBoardController.makeMoveSAN(move);
                }
                print(move);
              },
              onCheck: (color) {
                print(color);
              },
              onCheckMate: (color) {
                print(color);
              },
              onDraw: () {},
              size: MediaQuery.of(context).size.width,
              enableUserMoves: true,
              boardType: BoardType.green,
              chessBoardController: chessBoardController,
              movesOnlyThroughController: movesOnlyThroughController,
            ),
            Row(
              children: [
                RaisedButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () =>
                      setState(() => chessBoardController.stepBack()),
                ),
                RaisedButton(
                  child: Icon(Icons.arrow_forward),
                  onPressed: () =>
                      setState(() => chessBoardController.stepForward()),
                ),
                RaisedButton(
                  child: Icon(Icons.subdirectory_arrow_right),
                  onPressed: () =>
                      setState(() => chessBoardController.stepFront()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
