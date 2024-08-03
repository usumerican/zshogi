import { describe, expect, test } from 'vitest';
import {
  moveFromUsi,
  moveInit,
  moveInitDrop,
  moveInitPromote,
  moveToUsi,
  Position,
  SFEN_MATSURI,
  SFEN_STARTPOS,
  squareInit,
} from '../../web/shogi';

describe('shogi', () => {
  test('Position', () => {
    const pos = new Position();
    expect(pos.toSfen()).toEqual('9/9/9/9/9/9/9/9/9 b - 0');
    expect(Position.fromSfen(SFEN_STARTPOS).toSfen()).toEqual(SFEN_STARTPOS);
    expect(Position.fromSfen(SFEN_MATSURI).toSfen()).toEqual(SFEN_MATSURI);
  });

  test('moveToUsi', () => {
    expect(moveToUsi(moveInit(squareInit(0, 0), squareInit(0, 1)))).toEqual('1a1b');
    expect(moveToUsi(moveInitPromote(squareInit(0, 0), squareInit(0, 1)))).toEqual('1a1b+');
    expect(moveToUsi(moveInitDrop(1, squareInit(0, 1)))).toEqual('P*1b');
  });

  test('moveFromUsi', () => {
    expect(moveFromUsi('1a1b')).toEqual(moveInit(squareInit(0, 0), squareInit(0, 1)));
    expect(moveFromUsi('1a1b+')).toEqual(moveInitPromote(squareInit(0, 0), squareInit(0, 1)));
    expect(moveFromUsi('P*1b')).toEqual(moveInitDrop(1, squareInit(0, 1)));
  });

  test('doMove', () => {
    const pos = Position.fromSfen(SFEN_STARTPOS);
    expect(pos.toSfen()).toEqual(SFEN_STARTPOS);
    for (const [moveUsi, sfen] of [
      ['7g7f', 'lnsgkgsnl/1r5b1/ppppppppp/9/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL w - 2'],
      ['3c3d', 'lnsgkgsnl/1r5b1/pppppp1pp/6p2/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL b - 3'],
      ['8h2b+', 'lnsgkgsnl/1r5+B1/pppppp1pp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w B 4'],
      ['3a2b', 'lnsgkg1nl/1r5s1/pppppp1pp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b Bb 5'],
      ['B*3c', 'lnsgkg1nl/1r5s1/ppppppBpp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w b 6'],
      ['B*4b', 'lnsgkg1nl/1r3b1s1/ppppppBpp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b - 7'],
    ]) {
      pos.doMove(moveFromUsi(moveUsi));
      expect(pos.toSfen()).toEqual(sfen);
    }
    while (pos.state.previous) {
      pos.undoMove();
    }
    expect(pos.toSfen()).toEqual(SFEN_STARTPOS);
  });
});
