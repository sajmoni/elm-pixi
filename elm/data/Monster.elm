module Monster exposing (monster0, monster1, monster2)

import Model exposing (Enemy)


monster0 : Enemy
monster0 =
    { maxHp = 60
    , currentHp = 60
    , damage = 1
    , textures = [ "monster_17", "monster_18" ]
    }


monster1 : Enemy
monster1 =
    { maxHp = 80
    , currentHp = 80
    , damage = 2
    , textures = [ "monster_19", "monster_20" ]
    }


monster2 : Enemy
monster2 =
    { maxHp = 100
    , currentHp = 100
    , damage = 3
    , textures = [ "monster_21", "monster_22" ]
    }
