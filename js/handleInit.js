import * as PIXI from 'pixi.js';

export default (init, add, getTexture) => {
  init.subscribe((model) => {
    console.log({ model });
    model
      .filter(e => e.pixiType === 'Graphics')
      .forEach(({ id }) => {
        const food = new PIXI.Sprite(getTexture('Food_24'));
        food.interactive = true;
        // food.on('mousedown', () => {
        //   incoming.send(id);
        // });
        add(id, food);
      });
    // .forEach(({ id }) => {
    //   const graphics = new PIXI.Graphics();
    //   graphics.interactive = true;
    //   graphics.on('mousedown', () => {
    //     updateSquare(id);
    //   });

    //   app.stage.addChild(graphics);

    //   entity[id] = graphics;
    // });
    model
      .filter(e => e.pixiType === 'Text')
      .forEach(({ id, x, y }) => {
        const style = new PIXI.TextStyle({ fill: 'white', fontSize: 48 });
        const text = new PIXI.Text('ElmQuest', style);
        text.anchor.set(0.5);
        text.x = x;
        text.y = y;
        add(id, text);
      });
  });
};
