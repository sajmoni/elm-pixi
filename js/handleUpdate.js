import * as PIXI from 'pixi.js';
import _ from 'lodash/fp';

const PIXI_EVENTS = [
  // 'added',
  'click',
  // 'mousedown',
  // 'mousemove',
  // 'mouseout',
  // 'mouseover',
  // 'mouseup',
  // 'mouseupoutside',
  // 'pointercancel',
  // 'pointerdown',
  // 'pointermove',
  // 'pointerout',
  // 'pointerover',
  // 'pointertap',
  // 'pointerup',
  // 'pointerupoutside',
  // 'removed',
  // 'rightclick',
  // 'rightdown',
  // 'rightup',
  // 'rightupoutside',
  // 'tap',
  // 'touchcancel',
  // 'touchend',
  // 'touchendoutside',
  // 'touchmove',
  // 'touchstart',
];

export default ({
  update, entityMap, addEntity, getTexture, incoming, removeEntity,
}) => {
  update.subscribe((model) => {
    // model
    //   .filter(e => e.pixiType === 'Graphics')
    //   .forEach(({
    //     id, x, y, scale = 1,
    //   }) => {
    //     const e = entityMap[id];

    //     e.clear()
    //       .beginFill(0xffffff)
    //       .drawRect(x, y, 100, 100)
    //       .endFill()
    //       .scale.set(scale);
    //   });

    // Update entity
    model
      .filter(e => entityMap[e.id] && (e.type === 'Text' || e.type === 'AnimatedSprite'))
      .forEach(({
        id, x, y, scale,
      }) => {
        const e = entityMap[id];
        e.x = x;
        e.y = y;
        e.scale.set(scale);
      });

    // Add Entities that are new
    model
      .forEach((e) => {
        if (entityMap[e.id]) {
          return;
        }
        if (e.type === 'AnimatedSprite') {
          const {
            id, x, y, scale, textures, animationSpeed,
          } = e;
          const animatedSprite = new PIXI.extras.AnimatedSprite(textures.map(getTexture));

          animatedSprite.x = x;
          animatedSprite.y = y;
          animatedSprite.scale.set(scale);
          animatedSprite.play();
          animatedSprite.animationSpeed = animationSpeed;
          animatedSprite.interactive = true;

          PIXI_EVENTS.forEach((event) => {
            animatedSprite.on(event, () => {
              incoming.send({ id, event });
            });
          });

          addEntity(id, animatedSprite);
        } else if (e.type === 'Text') {
          const {
            id, x, y, scale, text: textString,
          } = e;
          const style = new PIXI.TextStyle({ fill: 'white', fontSize: 24 });
          const text = new PIXI.Text(textString, style);
          text.anchor.set(0.5);
          text.x = x;
          text.y = y;
          text.scale.set(scale);
          text.interactive = true;
          PIXI_EVENTS.forEach((event) => {
            text.on(event, () => {
              incoming.send({ id, event });
            });
          });
          addEntity(id, text);
        }
      });
    // TODO: Remove Entities
    Object.keys(entityMap).forEach((id) => {
      const exists = model.map(m => m.id).includes(id);
      if (!exists) {
        removeEntity(id);
      }
    });
  });
};
