import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/board_model.dart';
import 'package:flutter_chess_board/src/board_rank.dart';
import 'package:scoped_model/scoped_model.dart';
import 'chess_board_controller.dart';

enum DrawType {
  stalemate,
  threefoldRepetition,
  insufficienMaterial,
  unknown,
}

var whiteSquareList = [
  [
    "a8",
    "b8",
    "c8",
    "d8",
    "e8",
    "f8",
    "g8",
    "h8",
  ],
  [
    "a7",
    "b7",
    "c7",
    "d7",
    "e7",
    "f7",
    "g7",
    "h7",
  ],
  [
    "a6",
    "b6",
    "c6",
    "d6",
    "e6",
    "f6",
    "g6",
    "h6",
  ],
  [
    "a5",
    "b5",
    "c5",
    "d5",
    "e5",
    "f5",
    "g5",
    "h5",
  ],
  [
    "a4",
    "b4",
    "c4",
    "d4",
    "e4",
    "f4",
    "g4",
    "h4",
  ],
  [
    "a3",
    "b3",
    "c3",
    "d3",
    "e3",
    "f3",
    "g3",
    "h3",
  ],
  [
    "a2",
    "b2",
    "c2",
    "d2",
    "e2",
    "f2",
    "g2",
    "h2",
  ],
  [
    "a1",
    "b1",
    "c1",
    "d1",
    "e1",
    "f1",
    "g1",
    "h1",
  ],
];

/// The Chessboard Widget
class ChessBoard extends StatefulWidget {
  /// Callback for when move is made
  final MoveCallback onMove;

  /// Callback for when a player is checkmated
  final CheckMateCallback onCheckMate;

  /// Callback for when a player is in check
  final CheckCallback onCheck;

  /// Callback for when the game is a draw
  final DrawCallback onDraw;

  /// A boolean which notes if white board side is towards users
  final bool whiteSideTowardsUser;

  /// A controller to programmatically control the chess board
  final ChessBoardController chessBoardController;

  /// A boolean which checks if the user should be allowed to make moves
  final bool enableUserMoves;

  /// Moves can only be done through the controller
  final bool movesOnlyThroughController;

  final Color boardBlack;

  final Color boardWhite;

  final Color borderColor;

  ChessBoard({
    this.whiteSideTowardsUser = true,
    @required this.onMove,
    @required this.onCheckMate,
    @required this.onCheck,
    @required this.onDraw,
    this.chessBoardController,
    this.enableUserMoves = true,
    this.movesOnlyThroughController = false,
    this.boardWhite = Colors.white,
    this.boardBlack = Colors.brown,
    this.borderColor = Colors.black,
  });

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  BoardModel boardModel;

  static const double width = 3;

  @override
  void initState() {
    boardModel = BoardModel(
      widget.onMove,
      widget.onCheckMate,
      widget.onCheck,
      widget.onDraw,
      widget.whiteSideTowardsUser,
      widget.chessBoardController,
      widget.enableUserMoves,
      widget.movesOnlyThroughController,
      widget.boardWhite,
      widget.boardBlack,
      widget.borderColor,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(ChessBoard oldWidget) {
    boardModel.onMove = widget.onMove;
    boardModel.onCheckMate = widget.onCheckMate;
    boardModel.onCheck = widget.onCheck;
    boardModel.onDraw = widget.onDraw;
    boardModel.whiteSideTowardsUser = widget.whiteSideTowardsUser;
    boardModel.enableUserMoves = widget.enableUserMoves;
    boardModel.movesOnlyThroughController = widget.movesOnlyThroughController;
    boardModel.boardWhite = widget.boardWhite;
    boardModel.boardBlack = widget.boardBlack;
    boardModel.borderColor = widget.borderColor;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: boardModel,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: boardModel.borderColor,
              width: width,
            ),
          ),
          padding: EdgeInsets.all(width),
          child: Column(
            children: widget.whiteSideTowardsUser
                ? whiteSquareList.map((row) {
                    return ChessBoardRank(
                      children: row,
                    );
                  }).toList()
                : whiteSquareList.reversed.map((row) {
                    return ChessBoardRank(
                      children: row.reversed.toList(),
                    );
                  }).toList(),
          ),
        ),
      ),
    );
  }
}
