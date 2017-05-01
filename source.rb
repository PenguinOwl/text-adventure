# 
#   SOURCE.RB
#   CENTRAL PROSSESING FILE
#
#   CONTAINS:
#    1. CONFIG OVERIDE
#    2. BOARD CONSTRUCTION
#    3. NODE CONSTRUCTION
#    4. [FLAG CHECKS]
#    5. [OBJECT DEFINITIONS]
#    6. [LOOP DEFINITIONS]
#    7. [CONFIG DECODER]
#    8. [BULIDING]
#    9. [MAIN LOOP]
#
#   [] INDICATES MADATORY SETUP

autoParse = <<ENDOFFILE

#
#   CONFIG OVERIDE
#

MANUAL-CONFIG: FALSE
FLAG: "-path"

RUN-CHECKS: FALSE
FLAG: "-rc"

#
#   BOARD CONSTRUCTION
#

BOARD-HEIGHT: 5
BOARD-WIDTH: 5

CHAR-CORNER: '+'
CHAR-VERTICAL: '|'
CHAR-HORIZONTAL: '-'
CHAR-SPACE: ' '
CHAR-PLAYER: '0'
CHAR-ENEMY: '&'

#
#   NODE CONSTRUCTION
#
#   USE  [x,y]=>location(text,wall?)
#   OR   [x,y]=>enemy(name,hp,text,mode,reflect)
#
#   MODES:
#    npc - shows (text) on encounter
#    battle - triggers battle on encounter
#    
#   If (reflect) is active, you will be returned to the last location after showing text/battle
#

[0,0]=>location("TEST",true)

ENDOFFILE

#
#   CONFIG DECODER
#

def parse(config)
  $config = {}
  config.eachline do |cache|
    unless cache.split("")[0] == "#"
      
    end
  end
end
