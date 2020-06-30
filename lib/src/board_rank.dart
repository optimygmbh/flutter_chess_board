import 'package:flutter/material.dart';
import 'package:flutter_chess_board/src/board_square.dart';

/// Creates a rank(row) on the chessboard
class ChessBoardRank extends StatelessWidget {
  /// The list of squares in the rank
  final List<String> children;

  ChessBoardRank({this.children});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            children: children
                .map(
                  (squareName) => BoardSquare(
                    squareName: squareName,
                    size: constraints.maxHeight,
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
