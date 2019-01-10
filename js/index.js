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

const elmApp = Elm.Main.init({
  node: document.getElementById('elm')
});

const testAction = () => {
  elmApp.ports.setModel.send('new message 2')
}

elmApp.ports.getModel.subscribe((model) => {
  console.log('model logged: ', model);
})

testAction()
