import { describe, expect, test } from 'vitest';
import { Engine } from '../../dist/lib/zshogi';

describe('zshogi', () => {
  test('run', async () => {
    const engine = await Engine.init();
    expect(engine.run('usi')).toMatch(/usiok\n$/);
    expect(engine.run('isready')).toMatch(/readyok\n$/);
    expect(engine.run('usinewgame')).toEqual('');
  });
});
