import 'dart:ui';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_chess_board/src/chess_board_controller.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chess/chess.dart' as chess;

typedef void MoveCallback(String moveNotation);
typedef void CheckMateCallback(PieceColor color);
typedef void CheckCallback(PieceColor color);
typedef void DrawCallback(DrawType drawType);

class BoardModel extends Model {
  /// The size of the board (The board is a square)
  double size;

  /// Callback for when a move is made
  MoveCallback onMove;

  /// Callback for when a player is checkmated
  CheckMateCallback onCheckMate;

  ///Callback for when a player is in check
  CheckCallback onCheck;

  /// Callback for when the game is a draw (Example: K v K)
  DrawCallback onDraw;

  /// If the white side of the board is towards the user
  bool whiteSideTowardsUser;

  /// The controller for programmatically making moves
  ChessBoardController chessBoardController;

  /// User moves can be enabled or disabled by this property
  bool enableUserMoves;

  /// Moves can only be done through the controller
  bool movesOnlyThroughController;

  Color boardBlack;

  Color boardWhite;

  Color borderColor;

  /// Creates a logical game
  chess.Chess game = chess.Chess();

  /// Refreshes board
  void refreshBoard() {
    if (game.in_checkmate) {
      onCheckMate(
          game.turn == chess.Color.WHITE ? PieceColor.White : PieceColor.Black);
    } else if (game.in_stalemate) {
      onDraw(DrawType.stalemate);
    } else if (game.in_threefold_repetition) {
      onDraw(DrawType.threefoldRepetition);
    } else if (game.insufficient_material) {
      onDraw(DrawType.insufficienMaterial);
    } else if (game.in_draw) {
      onDraw(DrawType.unknown);
    } else if (game.in_check) {
      onCheck(
          game.turn == chess.Color.WHITE ? PieceColor.White : PieceColor.Black);
    }
    notifyListeners();
  }

  List<String> stepDifference = [];

  List<String> get history {
    final history = List<String>.from(game.getHistory());
    return history..addAll(stepDifference);
  }

  bool get isFirst => history.isEmpty;
  bool get isInFront => stepDifference.isEmpty;

  /// step back until first
  void stepFirst() {
    while (!isFirst) {
      stepBack();
    }
  }

  /// if it was not possible to step back
  bool stepBack() {
    final history = List<String>.from(game.getHistory());
    if (history.isEmpty) {
      return false;
    }
    stepDifference.insert(0, history.last);
    game.undo_move();
    refreshBoard();
    return true;
  }

  /// if it was not possible to step forward
  bool stepForward() {
    if (isInFront) {
      return false;
    }
    game.move(stepDifference.removeAt(0));
    refreshBoard();
    return true;
  }

  /// step forwart till is in front
  void stepToFront() {
    while (!isInFront) {
      stepForward();
    }
  }

  BoardModel(
    this.size,
    this.onMove,
    this.onCheckMate,
    this.onCheck,
    this.onDraw,
    this.whiteSideTowardsUser,
    this.chessBoardController,
    this.enableUserMoves,
    this.movesOnlyThroughController,
    this.boardWhite,
    this.boardBlack,
    this.borderColor,
  ) {
    chessBoardController?.game = game;
    chessBoardController?.boardModel = this;
  }
}
