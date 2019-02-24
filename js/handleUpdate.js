import * as PIXI from 'pixi.js';
// import _ from 'lodash/fp';

const PIXI_EVENTS = [
  // 'added',
  'click',
  // 'mousedown',
  // 'mousemove',
  'mouseout',
  'mouseover',
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
      .filter(e => entityMap[e.id])
      .forEach(({
        id, x, y, scale, type, textStyle, text,
      }) => {
        const e = entityMap[id];
        if (type === 'AnimatedSprite') {
          e.x = x;
          e.y = y;
          e.scale.set(scale);
        }
        if (type === 'Text') {
          e.x = x;
          e.y = y;
          e.scale.set(scale);
          if (textStyle && textStyle.fill && textStyle.fill !== e.style.fill) {
            e.style.fill = textStyle.fill;
          }
          if (e.text !== text) {
            e.text = text;
          }
        }
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
        } else if (e.type === 'Sprite') {
          const {
            id, x, y, scale, texture,
          } = e;
          const sprite = new PIXI.Sprite(getTexture(texture));

          sprite.x = x;
          sprite.y = y;
          sprite.scale.set(scale);
          sprite.interactive = true;

          PIXI_EVENTS.forEach((event) => {
            sprite.on(event, () => {
              incoming.send({ id, event });
            });
          });

          addEntity(id, sprite);
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
        } else if (e.type === 'Graphics') {
          const {
            id, x, y, scale, width, height, alpha, color,
          } = e;
          const graphics = new PIXI.Graphics();
          graphics.x = x;
          graphics.y = y;
          graphics.scale.set(scale);
          graphics.interactive = true;
          PIXI_EVENTS.forEach((event) => {
            graphics.on(event, () => {
              incoming.send({ id, event });
            });
          });

          graphics
            .beginFill(0xffff00, alpha)
            .drawRect(0, 0, width, height);
          addEntity(id, graphics);
        }
      });
    Object.keys(entityMap).forEach((id) => {
      const exists = model.map(m => m.id).includes(id);
      if (!exists) {
        removeEntity(id);
      }
    });
  });
};
