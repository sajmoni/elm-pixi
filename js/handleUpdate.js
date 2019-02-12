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
      .filter(e => entityMap[e.id])
      .filter(e => e.type === 'Text' || e.type === 'AnimatedSprite')
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
              addEntity(id, text);
            }
            // console.log({ newS: e });
            // console.log({ em: entityMap });
          });
      });
  });
};
