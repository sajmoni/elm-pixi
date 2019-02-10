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
    model
      .entities
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
      .entities
      .filter(e => e.pixiType === 'Text')
      .forEach((e) => {
        const text = new PIXI.Text('Elm Roguelike');

        app.stage.addChild(text);
      });
  });

  elmApp.ports.updatePort.subscribe((model) => {
    model
      .entities
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
  });
};

app.loader.load(init);
