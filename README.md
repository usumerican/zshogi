# Z Shogi

A simple USI shogi engine implemented in Zig

## 概要

Z Shogi は、[Zig](https://ziglang.org/) で実装されたシンプルな将棋エンジンです。

USI 対応の将棋 GUI ソフトで利用できる実行可能ファイル、
JavaScript から利用できる WebAssembly 版ライブラリ、
動作確認用の Web アプリを提供しています。

将棋プログラミングについては、[やねうら王](https://github.com/yaneurao/YaneuraOu)を参考にしました。

評価関数については、やねうら王の[NNUE-K-P-256-32-32用評価関数バイナリその2](https://github.com/yaneurao/YaneuraOu/releases/tag/20190212_k-p-256-32-32)を使っています。

## ライブラリの使い方

```
npm install zshogi
```

```js
import { Engine } from 'zshogi';

(async () => {
  const engine = await Engine.init();
  for (const request of [
    'usi',
    'setoption name DepthLimit value 5',
    'getoption',
    'isready',
    'usinewgame',
    'd',
    'go',
    'position startpos moves 1g1f',
    'd',
    'go',
    'matsuri',
    'd',
    'moves',
    'checks',
  ]) {
    console.log('> ' + request);
    console.log(engine.run(request));
  }
})();
```

## 開発

実行可能ファイルのビルドには、Zig が必要です。

```
zig build test
```

```
zig build --release=fast
```

```
./zig-out/bin/zshogi <<EOF
usi
isready
usinewgame
d
moves
go
EOF
```

合法手生成の性能を計測します。

```
echo "usi\nisready\nmatsuri\nperft 4" | zig build run --release=fast
```

WebAssembly 版ライブラリと Web アプリのビルドには、Node.js も必要です。

```
npm ci
```

```
npm run zig:test
```

```
npm run zig:wasm
```

```
npm run lib
```

```
npm run test
```

```
npm run build
```

```
npm run preview
```
