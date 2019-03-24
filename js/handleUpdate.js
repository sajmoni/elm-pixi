import convertColorHex from './util/convertColorHex';
import addEntities from './add/displayObject';

const updateEntities = ({ entities, entityMap, getTexture }) => {
  entities
    .filter(e => entityMap[e.id])
    .forEach(({
      id, x, y, scale, type, textStyle, textString, shape, color, textures,
    }) => {
      const e = entityMap[id];
      if (type === 'AnimatedSprite') {
        e.x = x;
        e.y = y;
        e.scale.set(scale);
        if (e.textureNames.some(tn => !textures.includes(tn))) {
          console.log('new textures!!');
          e.textureNames = textures;
          e.textures = textures.map(getTexture);
          e.play();
        }
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
    updateEntities({ entities: model, entityMap, getTexture });

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
