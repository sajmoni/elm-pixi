import getAnimatedSprite from './animatedSprite';
import getSprite from './sprite';
import getText from './text';
import getGraphics from './graphics';
import handleOn from './handleOn';

export default ({
  entities, entityMap, addEntity, getTexture, incoming,
}) => {
  entities
    .forEach((entity) => {
      if (entityMap[entity.id]) {
        return;
      }
      let displayObject;
      if (entity.type === 'AnimatedSprite') {
        displayObject = getAnimatedSprite({
          entity,
          getTexture,
        });
      } else if (entity.type === 'Sprite') {
        displayObject = getSprite({
          entity,
          getTexture,
        });
      } else if (entity.type === 'Text') {
        displayObject = getText({
          entity,
        });
      } else if (entity.type === 'Graphics') {
        displayObject = getGraphics({
          entity, incoming, addEntity,
        });
      } else if (entity.type === 'Container') {
        const {
          id, x, y, scale, alpha, on,
        } = entity;
        console.error('Implement container!');
        // const container = new PIXI.Container();
        // container.x = x;
        // container.y = y;
        // container.alpha = alpha;
        // container.scale.set(scale);
        // container.interactive = true;

        // handleOn({ on, entity: container, incoming });

        // addEntity(id, container, parent);
      } else if (entity.type === 'Empty') {
        return;
      }
      if (entity.x) {
        displayObject.x = entity.x;
      }
      if (entity.y) {
        displayObject.y = entity.y;
      }
      if (entity.scale) {
        displayObject.scale.set(entity.scale);
      }
      if (entity.alpha) {
        displayObject.alpha = entity.alpha;
      }

      if (entity.on) {
        displayObject.interactive = true;
      }

      handleOn({ on: entity.on, displayObject, incoming });
      addEntity(entity.id, displayObject);
    });
};
