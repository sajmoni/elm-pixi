import * as PIXI from 'pixi.js';

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;
// settings.RESOLUTION = window.devicePixelRatio
PIXI.settings.RESOLUTION = 2;

const app = new PIXI.Application({
  height: 1136,
  width: 640,
  backgroundColor: 0x000000,
});

document.getElementById('game').appendChild(app.view);

// app.loader.add('assets/spritesheet.json')

const entity = {};

const init = () => {
  const elmApp = Elm.Main.init({
    node: document.getElementById('elm'),
  });

  const updateSquare = (id) => {
    elmApp.ports.incomingPort.send(id);
  };

  elmApp.ports.initPort.subscribe((model) => {
    console.log({ model });
    model
      .filter(e => e.pixiType === 'Graphics')
      .forEach(({ id }) => {
        const graphics = new PIXI.Graphics();
        graphics.interactive = true;
        graphics.on('mousedown', () => {
          updateSquare(id);
        });

        app.stage.addChild(graphics);

        entity[id] = graphics;
      });

    model
      .filter(e => e.pixiType === 'Text')
      .forEach(({ id, x, y }) => {
        const style = new PIXI.TextStyle({ fill: 'white' });
        const text = new PIXI.Text('Elm Roguelike', style);
        text.anchor.set(0.5);
        text.x = x;
        text.y = y;
        app.stage.addChild(text);

        entity[id] = text;
      });
  });

  elmApp.ports.updatePort.subscribe((model) => {
    model
      .filter(e => e.pixiType === 'Graphics')
      .forEach(({
        id, x, y, scale = 1,
      }) => {
        entity[id]
          .clear()
          .beginFill(0xffffff)
          .drawRect(x, y, 100, 100)
          .endFill()
          .scale.set(scale);
      });
    model
      .filter(e => e.pixiType === 'Text')
      .forEach(({ id, scale }) => {
        entity[id].scale.set(scale);
      });
  });
};

app.loader.load(init);
