import * as PIXI from 'pixi.js';
import makeGetTexture from './util/getTexture';

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;
// settings.RESOLUTION = window.devicePixelRatio
PIXI.settings.RESOLUTION = 2;

const app = new PIXI.Application({
  height: 1136,
  width: 640,
  backgroundColor: 0x000000,
});

document.getElementById('game').appendChild(app.view);

// TODO: Auto-load all spritesheets
app.loader.add('spritesheet/food.json');
app.loader.add('spritesheet/monster.json');

const getTexture = makeGetTexture(app);

const entityMap = {};

const add = (id, entity) => {
  app.stage.addChild(entity);

  entityMap[id] = entity;
};

const init = () => {
  const {
    ports: {
      initPort,
      incomingPort,
      updatePort,
    },
  } = Elm.Main.init({
    node: document.getElementById('elm'),
  });

  initPort.subscribe((model) => {
    console.log({ model });
    model
      .filter(e => e.pixiType === 'Graphics')
      .forEach(({ id }) => {
        const food = new PIXI.Sprite(getTexture('Food_24'));
        food.interactive = true;
        food.on('mousedown', () => {
          incomingPort.send(id);
        });
        add(id, food);
      });
    // .forEach(({ id }) => {
    //   const graphics = new PIXI.Graphics();
    //   graphics.interactive = true;
    //   graphics.on('mousedown', () => {
    //     updateSquare(id);
    //   });

    //   app.stage.addChild(graphics);

    //   entity[id] = graphics;
    // });

    model
      .filter(e => e.pixiType === 'Text')
      .forEach(({ id, x, y }) => {
        const style = new PIXI.TextStyle({ fill: 'white', fontSize: 48 });
        const text = new PIXI.Text('Elm Roguelike', style);
        text.anchor.set(0.5);
        text.x = x;
        text.y = y;
        add(id, text);
      });

    model
      .filter(e => e.pixiType === 'AnimatedSprite')
      .forEach(({
        id, x, y, scale,
      }) => {
        const monster = new PIXI.extras.AnimatedSprite(['monster_01', 'monster_02'].map(getTexture));

        monster.x = x;
        monster.y = y;
        monster.scale.set(scale);
        monster.play();
        monster.animationSpeed = 0.05;

        add(id, monster);
      });
  });

  updatePort.subscribe((model) => {
    model
      .filter(e => e.pixiType === 'Graphics')
      .forEach(({
        id, x, y, scale = 1,
      }) => {
        const e = entityMap[id];
        e.x = x;
        e.y = y;
        e.scale.set(scale);
      });
    // .forEach(({
    //   id, x, y, scale = 1,
    // }) => {
    //   entity[id]
    //     .clear()
    //     .beginFill(0xffffff)
    //     .drawRect(x, y, 100, 100)
    //     .endFill()
    //     .scale.set(scale);
    // });
    model
      .filter(e => e.pixiType === 'Text')
      .forEach(({ id, scale }) => {
        entityMap[id].scale.set(scale);
      });
  });
};

app.loader.load(init);
