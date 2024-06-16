#!/bin/bash

set -euxo pipefail

npm run zig:test
npm run zig:wasm
npm run lib
npm run test
npm run build

zig build -Dtarget=x86_64-windows -Dcpu=x86_64 -Dname=zshogi-windows-x86_64 -Dstrip=true --release=fast --prefix dist --verbose --summary all
zig build -Dtarget=x86_64-windows -Dcpu=x86_64_v2 -Dname=zshogi-windows-x86_64_v2 -Dstrip=true --release=fast --prefix dist --verbose --summary all
zig build -Dtarget=x86_64-windows -Dcpu=x86_64_v3 -Dname=zshogi-windows-x86_64_v3 -Dstrip=true --release=fast --prefix dist --verbose --summary all
zig build -Dtarget=x86_64-windows -Dcpu=x86_64_v4 -Dname=zshogi-windows-x86_64_v4 -Dstrip=true --release=fast --prefix dist --verbose --summary all

tree -s dist
