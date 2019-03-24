import * as PIXI from 'pixi.js';

export default ({
  entity, getTexture,
}) => {
  const {
    textures, animationSpeed, on,
  } = entity;
  const animatedSprite = new PIXI.extras.AnimatedSprite(textures.map(getTexture));

  animatedSprite.animationSpeed = animationSpeed;
  animatedSprite.textureNames = textures;
  animatedSprite.play();
  if (on && on.length) {
    animatedSprite.interactive = true;
  }
  return animatedSprite;
};
