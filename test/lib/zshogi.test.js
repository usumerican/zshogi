import { describe, expect, test } from 'vitest';
import { Engine } from '../../dist/lib/zshogi';

describe('zshogi', () => {
  test('run', async () => {
    const engine = await Engine.init();
    expect(await engine.run('usi')).toMatch(/usiok\n$/);
    expect(await engine.run('isready')).toMatch(/readyok\n$/);
    expect(await engine.run('usinewgame')).toEqual('');
  });
});
