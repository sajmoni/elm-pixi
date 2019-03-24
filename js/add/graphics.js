import * as PIXI from 'pixi.js';
import convertColorHex from '../util/convertColorHex';

export default ({ entity }) => {
  const {
    id, shape, color, parent,
  } = entity;
  const graphics = new PIXI.Graphics();

  if (!color) {
    throw new Error(`Graphics with id: ${id} is missing color property`);
  }
  graphics
    .beginFill(convertColorHex(color), 1)
    .drawRect(0, 0, shape.width, shape.height)
    .endFill();

  return graphics;
};
