import convertColorHex from '../util/convertColorHex';

export default ({ entities, entityMap, getTexture }) => {
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
