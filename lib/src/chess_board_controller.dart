import 'package:chess/chess.dart' as chess;
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_chess_board/src/board_model.dart';

enum PieceType { Pawn, Rook, Knight, Bishop, Queen, King }

enum PieceColor {
  White,
  Black,
}

enum GameState {
  nothing,
  captured,
  stalemate,
  threefoldRepetition,
  insufficientMaterial,
  check,
  checkmate,
}

/// Controller for programmatically controlling the board
class ChessBoardController {
  /// The game attached to the controller
  chess.Chess game;

  BoardModel boardModel;

  /// Makes move on the board with San String
  GameState makeMoveSAN(String san) {
    boardModel.stepToFront();
    game?.move(san);
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();

    return _getGameState();
  }

  /// Makes move on the board
  GameState makeMove(String from, String to) {
    boardModel.stepToFront();
    game?.move({"from": from, "to": to});
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();
    return _getGameState();
  }

  /// Makes move and promotes pawn to piece (from is a square like d4, to is also a square like e3, pieceToPromoteTo is a String like "Q".
  /// pieceToPromoteTo String will be changed to enum in a future update and this method will be deprecated in the future
  GameState makeMoveWithPromotion(
      String from, String to, String pieceToPromoteTo) {
    boardModel.stepToFront();
    game?.move({"from": from, "to": to, "promotion": pieceToPromoteTo});
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();
    return _getGameState();
  }

  /// Resets square
  void resetBoard() {
    game?.reset();
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();
  }

  /// Clears board
  void clearBoard() {
    game?.clear();
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();
  }

  /// Puts piece on a square
  void putPiece(PieceType piece, String square, PieceColor color) {
    game?.put(_getPiece(piece, color), square);
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();
  }

  /// Loads a PGN
  void loadPGN(String pgn) {
    game.load_pgn(pgn);
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.refreshBoard();
  }

  /// Exception when a controller is not attached to a board
  void _throwNotAttachedException() {
    throw Exception("Controller not attached to a ChessBoard widget!");
  }

  void stepFirst() {
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.stepFirst();
  }

  void stepBack() {
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.stepBack();
  }

  void stepForward() {
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.stepForward();
  }

  void stepFront() {
    boardModel == null
        ? this._throwNotAttachedException()
        : boardModel.stepToFront();
  }

  GameState undoMove() {
    boardModel == null ? this._throwNotAttachedException() : game.undo_move();
    boardModel.refreshBoard();
    return _getGameState();
  }

  List<String> get history {
    if (boardModel == null) {
      return [];
    }
    return boardModel.history;
  }

  bool get isAtBegining {
    if (boardModel == null) {
      return true;
    }
    return boardModel.history.length == boardModel.stepDifference.length;
  }

  bool get isAtEnding {
    if (boardModel == null) {
      return true;
    }
    return boardModel.isInFront;
  }

  /// Gets respective piece
  chess.Piece _getPiece(PieceType piece, PieceColor color) {
    switch (piece) {
      case PieceType.Bishop:
        return chess.Piece(chess.PieceType.BISHOP, getChessColor(color));
      case PieceType.Queen:
        return chess.Piece(chess.PieceType.QUEEN, getChessColor(color));
      case PieceType.King:
        return chess.Piece(chess.PieceType.KING, getChessColor(color));
      case PieceType.Knight:
        return chess.Piece(chess.PieceType.KNIGHT, getChessColor(color));
      case PieceType.Pawn:
        return chess.Piece(chess.PieceType.PAWN, getChessColor(color));
      case PieceType.Rook:
        return chess.Piece(chess.PieceType.ROOK, getChessColor(color));
    }

    return chess.Piece(chess.PieceType.PAWN, chess.Color.WHITE);
  }

  chess.Color getChessColor(PieceColor color) {
    return color == PieceColor.White ? chess.Color.WHITE : chess.Color.BLACK;
  }

  GameState _getGameState() {
    if (game.in_checkmate) {
      return GameState.checkmate;
    } else if (game.in_stalemate) {
      return GameState.stalemate;
    } else if (game.in_threefold_repetition) {
      return GameState.threefoldRepetition;
    } else if (game.insufficient_material) {
      return GameState.insufficientMaterial;
    } else if (game.in_check) {
      return GameState.check;
    } else if (game.history.isNotEmpty &&
        game.history.last.move.captured != null) {
      return GameState.captured;
    }
    return GameState.nothing;
  }
}
