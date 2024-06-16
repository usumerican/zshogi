import EngineWorker from './zshogi-worker.js?worker';

export class EngineAsync {
  constructor() {
    this.map = new Map();
    this.nextId = 1;
  }

  run(request) {
    return new Promise((resolve, reject) => {
      if (!this.worker) {
        this.worker = new EngineWorker();
        this.worker.onmessage = (ev) => {
          const { id, error, response } = ev.data;
          if (error) {
            this.map.get(id).reject(error);
          } else {
            this.map.get(id).resolve(response);
          }
          this.map.delete(id);
        };
      }
      const id = this.nextId++;
      this.map.set(id, { resolve, reject });
      this.worker.postMessage({ id, request });
    });
  }

  terminate() {
    if (this.worker) {
      this.worker.terminate();
      this.worker = null;
      for (const { resolve } of this.map.values()) {
        resolve('terminated\n');
      }
      this.map.clear();
    }
  }
}
