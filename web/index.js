import { EngineAsync } from './zshogi-async.js';

onload = async () => {
  const engineAsync = new EngineAsync();
  const responseOutput = document.getElementById('responseOutput');
  const requestInput = document.getElementById('requestInput');

  function appendResponseText(text) {
    responseOutput.textContent += text;
    responseOutput.scrollTo({ top: responseOutput.scrollHeight, behavior: 'smooth' });
  }

  async function run(request) {
    appendResponseText(`> ${request}\n`);
    appendResponseText(await engineAsync.run(request));
  }

  document.getElementById('runButton').onclick = async () => {
    const requests = requestInput.value
      .trim()
      .split('\n')
      .map((l) => l.trim())
      .filter((l) => l);
    for (const request of requests) {
      await run(request);
    }
  };

  document.getElementById('terminateButton').onclick = () => {
    appendResponseText('> terminate\n');
    engineAsync.terminate();
  };
};
