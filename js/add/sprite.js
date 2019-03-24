import * as PIXI from 'pixi.js';

export default ({
  entity, getTexture,
}) => {
  const {
    texture,
  } = entity;
  const sprite = new PIXI.Sprite(getTexture(texture));

  return sprite;
};
