import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/board_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'package:chess/chess.dart' as chess;

/// A single square on the chessboard
class BoardSquare extends StatelessWidget {
  /// The square name (a2, d3, e4, etc.)
  final String squareName;
  final double size;

  BoardSquare({
    @required this.squareName,
    @required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BoardModel>(
      builder: (context, _, model) {
        return Expanded(
          flex: 1,
          child: DragTarget(
            builder: (context, accepted, rejected) {
              final piece = model.game.get(squareName);

              bool isAccepted = false;

              if (accepted.isNotEmpty &&
                  (accepted.first as List).first != squareName) {
                isAccepted = true;
              }

              /// Dont make dragable if:
              /// Color of piece is not on turn
              /// user moves are disabled
              ///
              if (model.game.turn != piece?.color ||
                  !model.isInFront ||
                  !model.enableUserMoves) {
                return getSquare(
                  model: model,
                  isAccepted: isAccepted,
                );
              }
              return Draggable(
                child: getSquare(
                  model: model,
                  isAccepted: isAccepted,
                ),
                childWhenDragging: getSquare(
                  model: model,
                  showPiece: false,
                  isAccepted: isAccepted,
                ),
                feedback: getSquare(
                  model: model,
                  isDraging: true,
                  isAccepted: isAccepted,
                ),
                onDragCompleted: () {},
                data: [
                  squareName,
                  model.game.get(squareName).type.toUpperCase(),
                  model.game.get(squareName).color,
                ],
              );
            },
            onWillAccept: (List<dynamic> willAccept) {
              return model.enableUserMoves ? true : false;
            },
            onAccept: (List moveInfo) async {
              bool moveAccepted = false;
              if (pawnReachesOtherSide(moveInfo)) {
                final promotion = await _promotionDialog(context);
                moveAccepted = model.game.move(
                  {
                    "from": moveInfo[0],
                    "to": squareName,
                    "promotion": promotion,
                  },
                );
              } else {
                moveAccepted =
                    model.game.move({"from": moveInfo[0], "to": squareName});
              }
              if (moveAccepted) {
                final history = model.game.getHistory();
                final move = (history as List).last;
                if (model.movesOnlyThroughController) {
                  model.game.undo_move();
                }
                model.onMove(move);
                model.refreshBoard();
              } else {
                model.onMoveDeclined?.call();
              }
            },
          ),
        );
      },
    );
  }

  bool pawnReachesOtherSide(List moveInfo) {
    return moveInfo[1] == "P" &&
        ((moveInfo[0][1] == "7" &&
                squareName[1] == "8" &&
                moveInfo[2] == chess.Color.WHITE) ||
            (moveInfo[0][1] == "2" &&
                squareName[1] == "1" &&
                moveInfo[2] == chess.Color.BLACK));
  }

  /// Show dialog when pawn reaches last square
  Future<String> _promotionDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Choose promotion'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: WhiteQueen(),
                onTap: () {
                  Navigator.of(context).pop("q");
                },
              ),
              InkWell(
                child: WhiteRook(),
                onTap: () {
                  Navigator.of(context).pop("r");
                },
              ),
              InkWell(
                child: WhiteBishop(),
                onTap: () {
                  Navigator.of(context).pop("b");
                },
              ),
              InkWell(
                child: WhiteKnight(),
                onTap: () {
                  Navigator.of(context).pop("n");
                },
              ),
            ],
          ),
        );
      },
    ).then((value) {
      return value;
    });
  }

  Widget getSquare({
    @required BoardModel model,
    bool isDraging = false,
    bool showPiece = true,
    bool isAccepted,
  }) {
    final piece = model.game.get(squareName);

    final squareNumber =
        chess.Chess.SQUARES[squareName] + int.parse(squareName[1]);

    Color squareColor = model.boardBlack;
    if (squareNumber % 2 == 0) {
      squareColor = model.boardWhite;
    }

    Color lastMoveColor = Colors.transparent;
    if (showPiece == false || isAccepted || lastMoveInvolvedSquare(model)) {
      lastMoveColor = model.lastMoveColor ?? Colors.green.withOpacity(0.5);
    }

    return Stack(
      children: [
        Container(color: squareColor),
        Container(color: lastMoveColor),
        showPiece
            ? _getImageToDisplay(
                piece: piece,
                size: isDraging ? 1.5 * size : size,
              )
            : Container(),
      ],
    );
  }

  bool lastMoveInvolvedSquare(BoardModel model) {
    return model.game.history.isNotEmpty &&
        (model.game.history.last.move.fromAlgebraic == squareName ||
            model.game.history.last.move.toAlgebraic == squareName);
  }

  /// Get image to display on square
  Widget _getImageToDisplay({
    @required chess.Piece piece,
    @required double size,
  }) {
    if (piece == null) {
      return Container();
    }

    if (piece.color == chess.Color.WHITE) {
      switch (piece.type) {
        case chess.PieceType.PAWN:
          return WhitePawn(size: size);
        case chess.PieceType.ROOK:
          return WhiteRook(size: size);
        case chess.PieceType.KNIGHT:
          return WhiteKnight(size: size);
        case chess.PieceType.BISHOP:
          return WhiteBishop(size: size);
        case chess.PieceType.QUEEN:
          return WhiteQueen(size: size);
        case chess.PieceType.KING:
          return WhiteKing(size: size);
      }
    } else if (piece.color == chess.Color.BLACK) {
      switch (piece.type) {
        case chess.PieceType.PAWN:
          return BlackPawn(size: size);
        case chess.PieceType.ROOK:
          return BlackRook(size: size);
        case chess.PieceType.KNIGHT:
          return BlackKnight(size: size);
        case chess.PieceType.BISHOP:
          return BlackBishop(size: size);
        case chess.PieceType.QUEEN:
          return BlackQueen(size: size);
        case chess.PieceType.KING:
          return BlackKing(size: size);
      }
    }

    throw UnimplementedError();
  }
}
