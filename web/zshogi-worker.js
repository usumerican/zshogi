import { Engine } from './zshogi';

let engine;

self.onmessage = async (ev) => {
  const { id, request } = ev.data;
  try {
    if (!engine) {
      engine = await Engine.init();
    }
    const response = engine.run(request);
    self.postMessage({ id, response });
  } catch (error) {
    self.postMessage({ id, error });
  }
};
