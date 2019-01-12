import * as PIXI from 'pixi.js'

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST
// settings.RESOLUTION = window.devicePixelRatio
PIXI.settings.RESOLUTION = 2

const app = new PIXI.Application({
  width: 800,
  height: 600,
  backgroundColor: 0x000000,
})

document.getElementById('game').appendChild(app.view)

// app.loader.add('assets/spritesheet.json')

const entity = {}

app.loader.load(() => { 
  
  const elmApp = Elm.Main.init({
    node: document.getElementById('elm')
  })
    
  const updateSquare = ({id}) => {
    elmApp.ports.updateSquare.send(id)
  }

  elmApp.ports.initPort.subscribe((model) => {
    model.forEach(({ id, x, y }) => {
      const graphics = new PIXI.Graphics()
      graphics.interactive = true
      graphics.on('mousedown', () => {
        updateSquare({id})
      })

      app.stage.addChild(graphics)
      
      entity[id] = graphics
    })
  })
  
  elmApp.ports.updatePort.subscribe((model) => {
    model.forEach(({id, x, y}) => {
      entity[id]
        .clear()
        .beginFill(0xffffff)
        .drawRect(x, y, 100, 100)
        .endFill()
    })
  })
})


// testAction()
