import addEntities from './add/displayObject';
import updateEntities from './update/displayObject';

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
