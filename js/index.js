import * as PIXI from 'pixi.js';
import makeGetTexture from './util/getTexture';
import handleUpdate from './handleUpdate';

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

const addEntity = (id, entity) => {
  entityMap[id] = entity;
  app.stage.addChild(entity);
};

const removeEntity = (id) => {
  const entity = entityMap[id];
  entity.parent.removeChild(entity);
  entity.destroy({ children: true });
  delete entityMap[id];
};

const init = () => {
  const {
    ports: {
      // init: initPort,
      incoming,
      update,
    },
  } = Elm.Main.init({
    node: document.getElementById('elm'),
  });

  // handleInit(initPort, addEntity, getTexture);

  handleUpdate({
    update, entityMap, addEntity, getTexture, incoming, removeEntity,
  });
};

app.loader.load(init);
