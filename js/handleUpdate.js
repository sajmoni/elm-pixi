import * as PIXI from 'pixi.js';
import convertColorHex from './util/convertColorHex';

const handleOn = ({ on, entity, incoming }) => {
  if (on) {
    on.forEach(({ event, msg, value }) => {
      entity.on(event, () => {
        const toSend = { msg, value };
        incoming.send(toSend);
      });
    });
  }
};

const updateEntities = ({ entities, entityMap }) => {
  entities
    .filter(e => entityMap[e.id])
    .forEach(({
      id, x, y, scale, type, textStyle, textString, shape, color,
    }) => {
      const e = entityMap[id];
      if (type === 'AnimatedSprite') {
        e.x = x;
        e.y = y;
        e.scale.set(scale);
      }
      if (type === 'Text') {
        if (x) {
          e.x = x;
        }
        if (y) {
          e.y = y;
        }
        if (scale) {
          e.scale.set(scale);
        }
        if (textStyle && textStyle.fill && textStyle.fill !== e.style.fill) {
          e.style.fill = textStyle.fill;
        }
        if (e.text !== textString) {
          e.text = textString;
        }
      }
      if (type === 'Sprite') {
        e.x = x;
        e.y = y;
        e.scale.set(scale);
      } else if (type === 'Graphics') {
        if (x) {
          e.x = x;
        }
        if (y) {
          e.y = y;
        }
        if (scale) {
          e.scale.set(scale);
        }

        e
          .clear()
          .beginFill(convertColorHex(color), 1)
          .drawRect(0, 0, shape.width, shape.height)
          .endFill();
      }
    });
};

const addAnimatedSprite = ({
  entity, getTexture, incoming, addEntity,
}) => {
  const {
    id, x, y, scale, textures, animationSpeed, on,
  } = entity;
  const animatedSprite = new PIXI.extras.AnimatedSprite(textures.map(getTexture));

  animatedSprite.x = x;
  animatedSprite.y = y;
  animatedSprite.scale.set(scale);
  animatedSprite.play();
  animatedSprite.animationSpeed = animationSpeed;
  animatedSprite.interactive = true;

  handleOn({ on, entity: animatedSprite, incoming });
  addEntity(id, animatedSprite);
};

const addEntities = ({
  entities, entityMap, addEntity, getTexture, incoming,
}) => {
  entities
    .forEach((entity) => {
      if (entityMap[entity.id]) {
        return;
      }
      if (entity.type === 'AnimatedSprite') {
        addAnimatedSprite({
          entity,
          getTexture,
          incoming,
          addEntity,
        });
      } else if (entity.type === 'Sprite') {
        const {
          id, x, y, scale, texture, on,
        } = entity;
        const sprite = new PIXI.Sprite(getTexture(texture));

        sprite.x = x;
        sprite.y = y;
        sprite.scale.set(scale);
        sprite.interactive = true;

        handleOn({ on, entity: sprite, incoming });

        addEntity(id, sprite);
      } else if (entity.type === 'Text') {
        const {
          id, x, y, scale, textString, on, textStyle,
        } = entity;
        const style = new PIXI.TextStyle({
          fill: (textStyle && textStyle.fill) || 'white',
          fontSize: (textStyle && textStyle.fontSize) || 24,
          fontFamily: 'equipment',
        });
        const text = new PIXI.Text(textString, style);
        text.anchor.set(0.5);

        if (x) {
          text.x = x;
        }
        if (y) {
          text.y = y;
        }
        if (scale) {
          text.scale.set(scale);
        }
        text.interactive = true;
        handleOn({ on, entity: text, incoming });

        addEntity(id, text);
      } else if (entity.type === 'Graphics') {
        const {
          id, x, y, scale, shape, alpha, color, parent, on,
        } = entity;
        const graphics = new PIXI.Graphics();
        if (x) {
          graphics.x = x;
        }
        if (y) {
          graphics.y = y;
        }
        if (scale) {
          graphics.scale.set(scale);
        }
        graphics.interactive = true;

        handleOn({ on, entity: graphics, incoming });
        if (!color) {
          throw new Error(`Graphics with id: ${id} is missing color property`);
        }
        graphics
          .beginFill(convertColorHex(color), 1)
          .drawRect(0, 0, shape.width, shape.height)
          .endFill();
        addEntity(id, graphics);
      } else if (entity.type === 'Container') {
        const {
          id, x, y, scale, alpha, on,
        } = entity;
        const container = new PIXI.Container();
        container.x = x;
        container.y = y;
        container.alpha = alpha;
        container.scale.set(scale);
        container.interactive = true;

        handleOn({ on, entity: container, incoming });

        addEntity(id, container, parent);
      }
    });
};


let flag = true;
export default ({
  update, entityMap, addEntity, getTexture, incoming, removeEntity,
}) => {
  update.subscribe((model) => {
    if (flag) {
      console.log(model);
      flag = false;
    }
    // Update entity
    updateEntities({ entities: model, entityMap });

    // ADD Entities that are new
    addEntities({
      entities: model, entityMap, addEntity, getTexture, incoming,
    });

    // Remove entity if it doesn't exist in Elm anymore
    Object.keys(entityMap).forEach((id) => {
      const exists = model.map(m => m.id).includes(id);
      if (!exists) {
        removeEntity(id);
      }
    });
  });
};
