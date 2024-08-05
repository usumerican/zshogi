const BLACK = 0;
const WHITE = 1;
export const COLOR_NB = 2;

export function colorTurn(c) {
  return c ^ 1;
}

function colorToUsi(c) {
  return 'bw'[c];
}

function colorFromUsi(usi) {
  return usi == 'w' ? WHITE : BLACK;
}

export const FILE_NB = 9;

export function fileToUsi(f) {
  return '123456789'[f];
}

function fileFromUsi(usi) {
  return usi.charCodeAt(0) - 0x31;
}

export const RANK_NB = 9;

export function rankToUsi(r) {
  return 'abcdefghi'[r];
}

function rankFromUsi(usi) {
  return usi.charCodeAt(0) - 0x61;
}

export const SQUARE_NB = RANK_NB * FILE_NB;

export function squareInit(f, r) {
  return RANK_NB * f + r;
}

export function squareGetFile(sq) {
  return Math.floor(sq / RANK_NB);
}

export function squareGetRank(sq) {
  return sq % RANK_NB;
}

function squareToUsi(sq) {
  return fileToUsi(squareGetFile(sq)) + rankToUsi(squareGetRank(sq));
}

function squareFromUsi(usi) {
  return squareInit(fileFromUsi(usi[0]), rankFromUsi(usi[1]));
}

const PIECE_NONE = 0;
const PAWN = 1;
const LANCE = 2;
const KNIGHT = 3;
const SILVER = 4;
const BISHOP = 5;
const ROOK = 6;
const GOLD = 7;

function pieceInit(c, pt) {
  return (c << 4) + pt;
}

export function pieceGetColor(pc) {
  return (pc & 0b10000) >> 4;
}

export function pieceGetPieceRaw(pc) {
  return pc & 0b00111;
}

export function pieceGetPieceType(pc) {
  return pc & 0b01111;
}

function piecePromote(pc) {
  return pc | 0b01000;
}

function pieceDemote(pc) {
  return pc & ~0b01000;
}

const PIECE_TO_USI = [
  '',
  'P',
  'L',
  'N',
  'S',
  'B',
  'R',
  'G',
  'K',
  '+P',
  '+L',
  '+N',
  '+S',
  '+B',
  '+R',
  '',
  '',
  'p',
  'l',
  'n',
  's',
  'b',
  'r',
  'g',
  'k',
  '+p',
  '+l',
  '+n',
  '+s',
  '+b',
  '+r',
];

function pieceToUsi(pc) {
  return PIECE_TO_USI[pc];
}

const PIECE_FROM_USI = PIECE_TO_USI.reduce((map, usi, pc) => map.set(usi, pc), new Map());

function pieceFromUsi(usi) {
  return PIECE_FROM_USI.get(usi);
}

const HAND_EMPTY = 0;
const HAND_SHIFT = [0, 0, 8, 12, 16, 20, 24, 28];
const HAND_MASK = [
  0, 0b00000000_00000000_00000000_11111111, 0b00000000_00000000_00001111_00000000,
  0b00000000_00000000_11110000_00000000, 0b00000000_00001111_00000000_00000000, 0b00000000_11110000_00000000_00000000,
  0b00001111_00000000_00000000_00000000, 0b11110000_00000000_00000000_00000000,
];
const HAND_ONE = [
  0, 0b00000000_00000000_00000000_00000001, 0b00000000_00000000_00000001_00000000,
  0b00000000_00000000_00010000_00000000, 0b00000000_00000001_00000000_00000000, 0b00000000_00010000_00000000_00000000,
  0b00000001_00000000_00000000_00000000, 0b00010000_00000000_00000000_00000000,
];
export const HAND_PIECE_RAWS = [ROOK, BISHOP, GOLD, SILVER, KNIGHT, LANCE, PAWN];

function handCount(h, pr) {
  return (h & HAND_MASK[pr]) >> HAND_SHIFT[pr];
}

function handDiff(pr, d) {
  return HAND_ONE[pr] * d;
}

const MOVE_NONE = 0;
const MOVE_DROPPED = 1 << 14;
const MOVE_PROMOTED = 1 << 15;

export function moveInit(from, to) {
  return to + (from << 7);
}

export function moveInitPromote(from, to) {
  return to + (from << 7) + MOVE_PROMOTED;
}

export function moveInitDrop(pr, to) {
  return to + (pr << 7) + MOVE_DROPPED;
}

export function moveGetTo(m) {
  return m & 0x7f;
}

export function moveGetFrom(m) {
  return (m >> 7) & 0x7f;
}

export function moveIsDropped(m) {
  return m & MOVE_DROPPED;
}

export function moveIsPromoted(m) {
  return m & MOVE_PROMOTED;
}

export function moveToUsi(m) {
  return moveIsDropped(m)
    ? pieceToUsi(moveGetFrom(m)) + '*' + squareToUsi(moveGetTo(m))
    : moveIsPromoted(m)
      ? squareToUsi(moveGetFrom(m)) + squareToUsi(moveGetTo(m)) + '+'
      : squareToUsi(moveGetFrom(m)) + squareToUsi(moveGetTo(m));
}

export function moveFromUsi(usi) {
  const found = usi.match(/^(?:([A-Z])\*|([1-9][a-i]))([1-9][a-i])(\+)?$/);
  if (!found) {
    return MOVE_NONE;
  }
  const [, prUsi, fromUsi, toUsi, promoted] = found;
  const to = squareFromUsi(toUsi);
  if (prUsi) {
    return moveInitDrop(pieceFromUsi(prUsi), to);
  }
  if (promoted) {
    return moveInitPromote(squareFromUsi(fromUsi), to);
  }
  return moveInit(squareFromUsi(fromUsi), to);
}

class StateInfo {
  constructor(previous, lastMove, capturedPiece) {
    this.previous = previous;
    this.lastMove = lastMove;
    this.capturedPiece = capturedPiece;
  }
}

export class Position {
  constructor() {
    this.board = Array(SQUARE_NB).fill(PIECE_NONE);
    this.hands = Array(COLOR_NB).fill(HAND_EMPTY);
    this.sideToMove = BLACK;
    this.gamePly = 0;
    this.state = new StateInfo();
  }

  getPiece(sq) {
    return this.board[sq];
  }

  putPiece(sq, pc) {
    this.board[sq] = pc;
  }

  removePiece(sq) {
    this.board[sq] = PIECE_NONE;
  }

  getHandCount(c, pr) {
    return handCount(this.hands[c], pr);
  }

  addHandCount(c, pr, d) {
    this.hands[c] += handDiff(pr, d);
  }

  static fromSfen(sfen) {
    const found = sfen.trim().match(/^([+a-zA-Z\d/]+)\s+([bw])\s+(?:-|([a-zA-Z\d]+))\s+(\d+)$/);
    if (!found) {
      return null;
    }
    const [, boardUsi, colorUsi, handsUsi, gamePlyUsi] = found;
    const self = new Position();
    let r = 0;
    for (const rankUsi of boardUsi.split('/')) {
      let f = FILE_NB - 1;
      for (const [, emptyUsi, pieceUsi] of rankUsi.matchAll(/(\d)|(\+?[a-zA-Z])/g)) {
        if (emptyUsi) {
          f -= +emptyUsi;
          continue;
        }
        const pc = pieceFromUsi(pieceUsi);
        if (pc != PIECE_NONE) {
          self.putPiece(squareInit(f, r), pc);
        }
        f--;
      }
      r++;
    }
    if (handsUsi) {
      for (const [, countUsi, pieceUsi] of handsUsi.matchAll(/(\d*)([a-zA-Z])/g)) {
        const pc = pieceFromUsi(pieceUsi);
        if (pc) {
          self.addHandCount(pieceGetColor(pc), pieceGetPieceRaw(pc), +countUsi || 1);
        }
      }
    }
    self.sideToMove = colorFromUsi(colorUsi);
    self.gamePly = +gamePlyUsi || 1;
    return self;
  }

  toSfen() {
    let sfen = '';
    for (let r = 0; r < RANK_NB; r++) {
      if (r) {
        sfen += '/';
      }
      let emptyCount = 0;
      for (let f = FILE_NB - 1; f >= 0; f--) {
        const pc = this.getPiece(squareInit(f, r));
        if (pc) {
          if (emptyCount) {
            sfen += emptyCount;
            emptyCount = 0;
          }
          sfen += pieceToUsi(pc);
        } else {
          emptyCount++;
        }
      }
      if (emptyCount) {
        sfen += emptyCount;
      }
    }
    sfen += ' ' + colorToUsi(this.sideToMove) + ' ';
    if (this.hands.every((h) => h == HAND_EMPTY)) {
      sfen += '-';
    } else {
      for (let c = 0; c < COLOR_NB; c++) {
        for (const pr of HAND_PIECE_RAWS) {
          const n = this.getHandCount(c, pr);
          if (n) {
            if (n > 1) {
              sfen += n;
            }
            sfen += pieceToUsi(pieceInit(c, pr));
          }
        }
      }
    }
    return sfen + ' ' + this.gamePly;
  }

  doMove(m) {
    let capturedPiece = PIECE_NONE;
    const to = moveGetTo(m);
    if (moveIsDropped(m)) {
      const pr = moveGetFrom(m);
      this.addHandCount(this.sideToMove, pr, -1);
      this.putPiece(to, pieceInit(this.sideToMove, pr));
    } else {
      capturedPiece = this.getPiece(to);
      if (capturedPiece) {
        this.removePiece(to);
        this.addHandCount(this.sideToMove, pieceGetPieceRaw(capturedPiece), 1);
      }
      const from = moveGetFrom(m);
      const pc = this.getPiece(from);
      this.removePiece(from);
      this.putPiece(to, moveIsPromoted(m) ? piecePromote(pc) : pc);
    }
    this.sideToMove = colorTurn(this.sideToMove);
    this.gamePly++;
    this.state = new StateInfo(this.state, m, capturedPiece);
    return capturedPiece;
  }

  undoMove() {
    if (this.state.previous) {
      this.sideToMove = colorTurn(this.sideToMove);
      const to = moveGetTo(this.state.lastMove);
      const from = moveGetFrom(this.state.lastMove);
      if (moveIsDropped(this.state.lastMove)) {
        this.removePiece(to);
        this.addHandCount(this.sideToMove, from, 1);
      } else {
        const pc = this.getPiece(to);
        this.removePiece(to);
        this.putPiece(from, moveIsPromoted(this.state.lastMove) ? pieceDemote(pc) : pc);
        if (this.state.capturedPiece) {
          this.addHandCount(this.sideToMove, pieceGetPieceRaw(this.state.capturedPiece), -1);
          this.putPiece(to, this.state.capturedPiece);
        }
      }
      this.gamePly--;
      this.state = this.state.previous;
    }
  }
}

export const SFEN_STARTPOS = 'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1';
export const SFEN_MATSURI = 'l6nl/5+P1gk/2np1S3/p1p4Pp/3P2Sp1/1PPb2P1P/P5GS1/R8/LN4bKL w RGgsn5p 1';
