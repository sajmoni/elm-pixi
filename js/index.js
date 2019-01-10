import { settings, Application, SCALE_MODES } from 'pixi.js'

settings.SCALE_MODE = SCALE_MODES.NEAREST
// settings.RESOLUTION = window.devicePixelRatio
settings.RESOLUTION = 2
const app = new Application({
  width: 800,
  height: 600,
  backgroundColor: 0xffffff,
})

document.getElementById('game').appendChild(app.view)

// app.loader.add('assets/spritesheet.json')

app.loader.load(() => { 
  console.log('pixi loaded!')
})
