import instatiate from '../dist/bin/zshogi.wasm?init';

export class Engine {
  constructor(memory, instance) {
    this.memory = memory;
    this.instance = instance;
  }

  static async init() {
    const memory = new WebAssembly.Memory({ initial: 128 });
    const instance = await instatiate({ env: { memory, dateNow: () => BigInt(Date.now()) } });
    return new Engine(memory, instance);
  }

  sliceAddr(slice) {
    return this.instance.exports.sliceAddr(slice) >>> 0;
  }

  sliceLen(slice) {
    return this.instance.exports.sliceLen(slice) >>> 0;
  }

  static encoder = new TextEncoder();
  static decoder = new TextDecoder();

  sliceEncode(str) {
    const arr = Engine.encoder.encode(str);
    const slice = this.instance.exports.sliceAlloc(arr.length);
    const addr = this.sliceAddr(slice);
    if (!addr) {
      throw new Error('Null addr in encode');
    }
    const len = this.sliceLen(slice);
    if (len) {
      new Uint8Array(this.memory.buffer, addr, len).set(arr);
    }
    return slice;
  }

  sliceDecode(slice) {
    const addr = this.sliceAddr(slice);
    if (!addr) {
      throw new Error('Null addr in decode');
    }
    const len = this.sliceLen(slice);
    return len ? Engine.decoder.decode(new Uint8Array(this.memory.buffer, addr, len)) : '';
  }

  sliceFree(slice) {
    this.instance.exports.sliceFree(slice);
  }

  run(request) {
    const request_slice = this.sliceEncode(request);
    try {
      const response_slice = this.instance.exports.run(request_slice);
      try {
        return this.sliceDecode(response_slice);
      } finally {
        this.sliceFree(response_slice);
      }
    } finally {
      this.sliceFree(request_slice);
    }
  }
}
