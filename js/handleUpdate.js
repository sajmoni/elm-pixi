import * as PIXI from 'pixi.js';

export default (update, entityMap, addEntity, getTexture) => {
  update.subscribe((model) => {
    model
      .filter(e => e.pixiType === 'Graphics')
      .forEach(({
        id, x, y, scale = 1,
      }) => {
        const e = entityMap[id];

        e.clear()
          .beginFill(0xffffff)
          .drawRect(x, y, 100, 100)
          .endFill()
          .scale.set(scale);
      });

    model
      .filter(e => e.type === 'Text' || e.type === 'AnimatedType')
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
      .filter(e => !entityMap[e.id])
      .forEach((e) => {
        model
          .forEach(() => {
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

              addEntity(id, animatedSprite);
            }
          });
      });
  });
};
