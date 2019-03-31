# elm-pixi

- All logic is handled by Elm.
- Rendering is done in JavaScript with pixi.js.
- Elm communicates with pixi through ports.

This library intends to use the best parts of Elm and Pixi. It enables you to write code that takes advantage
of Elms compiler and type system. It does not do anything to guarantee good performance though. Use at your own risk.

All graphics done by 7Soul. Check them out on GameDev Market!

## How to run

Open three terminal windows and run:

`yarn start`

`yarn watch`

`yarn elm`

TODO:

- Lost game when player health is 0 (2)
- Animations when spells are used (3)
- Virtual Stage (8)
- Handle children (8)
- Fade in/out (Add parabola to Juice) (2)

## Virtual Stage

With `elm-pixi`, every render we need to check if any properties on the view elements have been updated. Accessing the Pixi.js objects themselves is expensive though. Therefore `elm-pixi` keeps a representation of Pixi.js's `stage` in memory, and uses that instead to check when properties are updated. Think of it the same way as the `virtual DOM` in `react` or `elm/html`.

## Benefits

## Drawbacks

Elm will own all state of the game. This means that everything has to originate from within Elm. For example Physics.


