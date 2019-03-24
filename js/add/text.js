import * as PIXI from 'pixi.js';

export default ({ entity }) => {
  const {
    textString, textStyle,
  } = entity;
  const style = new PIXI.TextStyle({
    fill: (textStyle && textStyle.fill) || 'white',
    fontSize: (textStyle && textStyle.fontSize) || 24,
    fontFamily: 'equipment',
  });
  const text = new PIXI.Text(textString, style);
  text.anchor.set(0.5);

  return text;
};
