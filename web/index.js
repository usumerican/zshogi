import { EngineAsync } from './zshogi-async.js';
import {
  COLOR_NB,
  FILE_NB,
  HAND_PIECE_RAWS,
  moveFromUsi,
  moveGetFrom,
  moveGetTo,
  moveInit,
  moveInitDrop,
  moveInitPromote,
  moveIsDropped,
  moveIsPromoted,
  pieceGetColor,
  pieceGetPieceType,
  Position,
  RANK_NB,
  SFEN_MATSURI,
  SFEN_STARTPOS,
  SQUARE_NB,
  squareGetFile,
  squareGetRank,
  squareInit,
} from './shogi.js';

onload = () => {
  const engineAsync = new EngineAsync();
  const canvas = document.getElementById('mainCanvas');
  const matrix = [1, 0, 0, 1, 0, 0];
  const squareW = 100;
  const squareH = 100;
  const boardW = squareW * FILE_NB;
  const boardH = squareH * RANK_NB;
  const boardX = -boardW / 2;
  const boardY = -boardH / 2;
  const handW = squareW * HAND_PIECE_RAWS.length;
  const handRects = [
    [boardX + squareW, boardY + boardH + squareW / 2, handW, squareH],
    [boardX + squareW, boardY - squareH / 2 - squareH, handW, squareH],
  ];
  const handPoints = handRects.map((rect) => HAND_PIECE_RAWS.map((_, i) => [rect[0] + squareW * i, rect[1]]));
  const colorPoints = [
    [boardX + boardW - squareW, handRects[0][1]],
    [boardX, handRects[1][1]],
  ];
  const stageW = squareW * (FILE_NB + 1);
  const stageH = squareH * (RANK_NB + 4);
  const squarePoints = [...Array(SQUARE_NB).keys()].map((sq) => [
    boardX + squareW * (FILE_NB - 1 - squareGetFile(sq)),
    boardY + squareH * squareGetRank(sq),
  ]);
  const PIECE_TYPE_CHARS = ['', '歩', '香', '桂', '銀', '角', '飛', '金', '玉', 'と', '杏', '圭', '全', '馬', '龍'];
  const COLOR_CHARS = ['☗', '☖'];
  const pieceFont = Math.floor(squareW * 0.8) + 'px serif';
  const countFont = Math.floor(squareW * 0.4) + 'px sans-serif';
  const engineOutput = document.getElementById('engineOutput');
  const colorSelects = [...Array(COLOR_NB).keys()].map((c) => {
    const colorSelect = document.getElementById('colorSelect' + c);
    colorSelect.replaceChildren(
      ...[...Array(10).keys()].map((i) => i + 1).map((d) => new Option(COLOR_CHARS[c] + '深さ' + d, d)),
    );
    return colorSelect;
  });
  const startSelect = document.getElementById('startSelect');
  startSelect.replaceChildren(
    ...[
      ['平手', SFEN_STARTPOS],
      ['祭り', SFEN_MATSURI],
    ].map(([name, sfen]) => new Option(name, sfen)),
  );
  let pos = new Position();
  const nextMoveMap = new Map();
  let nextMove;

  function renderPiece(context, c, name, x, y, count) {
    context.save();
    try {
      const cos = c ? -1 : 1;
      context.transform(cos, 0, 0, cos, x + squareW / 2, y + squareH / 2);
      context.font = pieceFont;
      context.fillText(name, 0, 0);
      if (count > 1) {
        context.font = countFont;
        context.fillText(count, 0, squareH * 0.75);
      }
    } finally {
      context.restore();
    }
  }

  function renderCanvas(context) {
    context.strokeRect(-stageW / 2, -stageH / 2, stageW, stageH);
    context.beginPath();
    for (let f = 1; f < FILE_NB; f++) {
      const x = boardX + squareW * f;
      context.moveTo(x, boardY);
      context.lineTo(x, boardY + boardH);
    }
    for (let r = 1; r < RANK_NB; r++) {
      const y = boardY + squareH * r;
      context.moveTo(boardX, y);
      context.lineTo(boardX + boardH, y);
    }
    context.stroke();
    context.lineWidth = 4;
    context.strokeRect(boardX, boardY, boardW, boardH);
    for (let c = 0; c < COLOR_NB; c++) {
      context.strokeRect(...handRects[c]);
    }
    context.textAlign = 'center';
    context.textBaseline = 'middle';
    for (let sq = 0; sq < SQUARE_NB; sq++) {
      const pc = pos.getPiece(sq);
      if (pc) {
        renderPiece(context, pieceGetColor(pc), PIECE_TYPE_CHARS[pieceGetPieceType(pc)], ...squarePoints[sq]);
      }
    }
    for (let c = 0; c < COLOR_NB; c++) {
      renderPiece(context, c, COLOR_CHARS[c], ...colorPoints[c]);
      for (let i = 0; i < HAND_PIECE_RAWS.length; i++) {
        const pr = HAND_PIECE_RAWS[i];
        const handCount = pos.getHandCount(c, pr);
        if (handCount) {
          renderPiece(context, c, PIECE_TYPE_CHARS[pr], ...handPoints[c][i], handCount);
        }
      }
    }
    if (pos.state.lastMove) {
      context.fillStyle = 'rgba(0,0,0,.1)';
      context.fillRect(...squarePoints[moveGetTo(pos.state.lastMove)], squareW, squareH);
    }
    context.fillStyle = 'rgba(0,0,0,.2)';
    context.fillRect(...colorPoints[pos.sideToMove], squareW, squareH);
    if (nextMove) {
      const from = moveGetFrom(nextMove);
      context.fillRect(
        ...(moveIsDropped(nextMove) ? handPoints[pos.sideToMove][HAND_PIECE_RAWS.indexOf(from)] : squarePoints[from]),
        squareW,
        squareH,
      );
      const toMap = nextMoveMap.get(nextMove);
      if (toMap) {
        for (const to of toMap.keys()) {
          const [x, y] = squarePoints[to];
          context.fillRect(x + squareW / 4, y + squareW / 4, squareW / 2, squareH / 2);
        }
      }
    }
  }

  function updateCanvas() {
    requestAnimationFrame(() => {
      const canvasRect = canvas.getBoundingClientRect();
      canvas.width = canvasRect.width * devicePixelRatio;
      canvas.height = canvasRect.height * devicePixelRatio;
      matrix[0] = matrix[3] = Math.min(canvas.width / stageW, canvas.height / stageH);
      matrix[4] = canvas.width / 2;
      matrix[5] = canvas.height / 2;
      const context = canvas.getContext('2d');
      context.save();
      try {
        context.clearRect(0, 0, canvas.width, canvas.height);
        context.setTransform(...matrix);
        renderCanvas(context);
      } finally {
        context.restore();
      }
    });
  }

  new ResizeObserver(() => {
    updateCanvas();
  }).observe(canvas);

  function appendEngineOutput(text) {
    engineOutput.textContent += text;
    engineOutput.scrollTo({ top: engineOutput.scrollHeight, behavior: 'smooth' });
  }

  async function runEngineImpl(req) {
    console.log('usi> ' + req);
    const res = await engineAsync.run(req);
    if (res) {
      console.log('usi< ' + res);
    }
    return res;
  }

  async function runEngine(req) {
    if (engineAsync.worker == null) {
      await runEngineImpl('usi');
      await runEngineImpl('isready');
    }
    return await runEngineImpl(req);
  }

  async function updatePosition() {
    nextMove = 0;
    nextMoveMap.clear();
    await runEngine('position sfen ' + pos.toSfen());
    const movesUsi = await runEngine('moves');
    for (const m of movesUsi.split(/\s+/).map(moveFromUsi)) {
      if (m) {
        const from = moveGetFrom(m);
        const key = moveIsDropped(m) ? moveInitDrop(from, SQUARE_NB) : moveInit(from, SQUARE_NB);
        let toMap = nextMoveMap.get(key);
        if (!toMap) {
          toMap = new Map();
          nextMoveMap.set(key, toMap);
        }
        const to = moveGetTo(m);
        toMap.set(to, (toMap.get(to) || 0) | (moveIsPromoted(m) ? 2 : 1));
      }
    }
    updateCanvas();
  }

  async function doMove(m) {
    pos.doMove(m);
    await updatePosition();
    if (!nextMoveMap.size) {
      setTimeout(() => alert('詰みです。'), 100);
    }
  }

  document.getElementById('thinkButton').onclick = async () => {
    await runEngine('position sfen ' + pos.toSfen());
    await runEngine('setoption name DepthLimit value ' + colorSelects[pos.sideToMove].value);
    const res = await runEngine('go');
    appendEngineOutput(res);
    const found = res.match(/bestmove (.+)\n$/);
    if (found) {
      const m = moveFromUsi(found[1]);
      if (m) {
        doMove(m);
      }
    }
  };

  async function doStart() {
    engineOutput.textContent = '';
    pos = Position.fromSfen(startSelect.value);
    await updatePosition();
  }

  document.getElementById('startButton').onclick = () => doStart();

  document.getElementById('stopButton').onclick = () => engineAsync.terminate();

  document.getElementById('undoButton').onclick = async () => {
    pos.undoMove();
    await updatePosition();
  };

  function getSquareAt(x, y) {
    const f = FILE_NB - 1 - Math.floor((x - boardX) / squareW);
    if (f >= 0 && f < FILE_NB) {
      const r = Math.floor((y - boardY) / squareH);
      if (r >= 0 && r < RANK_NB) {
        return squareInit(f, r);
      }
    }
    return SQUARE_NB;
  }

  function getHandIndexAt(x, y, c) {
    const [rx, ry, , rh] = handRects[c];
    if (y >= ry && y < ry + rh) {
      const i = Math.floor((x - rx) / squareW);
      if (i >= 0 && i < HAND_PIECE_RAWS.length) {
        return i;
      }
    }
    return HAND_PIECE_RAWS.length;
  }

  canvas.onpointerdown = async (ev) => {
    const canvasRect = canvas.getBoundingClientRect();
    const x = ((ev.clientX - canvasRect.left) * devicePixelRatio - matrix[4]) / matrix[0];
    const y = ((ev.clientY - canvasRect.top) * devicePixelRatio - matrix[5]) / matrix[3];
    const sq = getSquareAt(x, y);
    if (sq < SQUARE_NB) {
      if (nextMoveMap.has(nextMove)) {
        const toMap = nextMoveMap.get(nextMove);
        if (toMap && toMap.has(sq)) {
          let m;
          const from = moveGetFrom(nextMove);
          if (moveIsDropped(nextMove)) {
            m = moveInitDrop(from, sq);
          } else {
            let promoted = toMap.get(sq) - 1;
            if (promoted === 2) {
              promoted = confirm('成りますか?');
            }
            m = promoted ? moveInitPromote(from, sq) : moveInit(from, sq);
          }
          doMove(m);
          return;
        }
      }
      if (nextMove && moveGetFrom(nextMove) === sq) {
        nextMove = 0;
      } else {
        const pc = pos.getPiece(sq);
        if (pc) {
          if (pieceGetColor(pc) === pos.sideToMove) {
            nextMove = moveInit(sq, SQUARE_NB);
          }
        }
      }
    } else {
      const i = getHandIndexAt(x, y, pos.sideToMove);
      if (i < HAND_PIECE_RAWS.length) {
        const pr = HAND_PIECE_RAWS[i];
        if (nextMove && moveGetFrom(nextMove) === pr) {
          nextMove = 0;
        } else if (pos.getHandCount(pos.sideToMove, pr)) {
          nextMove = moveInitDrop(pr, SQUARE_NB);
        }
      }
    }
    updateCanvas();
  };

  doStart();
};
