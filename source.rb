# 
#   SOURCE.RB
#   CENTRAL PROSSESING FILE
#
#   CONTAINS:
#    1.  CONFIG OVERIDE
#    2.  BOARD CONSTRUCTION
#    3.  NODE CONSTRUCTION
#    4.  [CONFIG DECODER]
#    5.  [FLAG CHECKS]
#    6.  [OBJECT DEFINITIONS]
#    7.  [LOOP DEFINITIONS]
#    8.  [BULIDING]
#    9. [MAIN LOOP]
#
#   [] INDICATES MADATORY SETUP

autoParse = <<ENDOFFILE

#
#   CONFIG OVERIDE
#

MANUAL-CONFIG: "false"
MC-FLAG: "-path"

RUN-CHECKS: "false"
RC-FLAG: "-rc"

#
#   BOARD CONSTRUCTION
#

BOARD-HEIGHT: "5"
BOARD-WIDTH: "5"

CHAR-CORNER: "+"
CHAR-VERTICAL: "|"
CHAR-HORIZONTAL: "-"
CHAR-SPACE: " "
CHAR-PLAYER: "0"
CHAR-ENEMY: "&"

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

def resetConfig
  $oldConfig = $config
  $config = {}
end

def parse(config)
  config.split("\n").each do |cache|
    d {puts cache}
    unless cache.split("")[0] == "#"
      cache.scan(/[a-zA-Z-]+: .+/).each do |e|
        d {puts e}
        es = e.split(/: /)
        es[1].strip!
        es[1].gsub!(/^"|"$/, "")
        $config.merge!(Hash[[es]])
      end
    end
  end
end

#
#   FLAG CHECKS
#

def flag(id,chk=false)
  if chk
    return ARGV[ARGV.index(id)+1]
  else
    return ARGV.include? id
  end
end

def fg(id)
  if ARGV.include? id
    yield
  end
end

def d
  if flag("-d")
    print Time.now.to_s + ": "
    yield
  end
end

def rc
  if flag($config["RC-FLAG"]) or $config["RUN-CHECKS"] == "true"
    print Time.now.to_s + ": "
    yield
  end
end

def loadConfig
  resetConfig
  parse(autoParse)
  d {
    print "Loaded default configuation: ", $config, "\n"
  }
  if flag($config["MC-FLAG"]) or $config["MANUAL-CONFIG"] == "true"
    file = File.open(flag($config["MC-FLAG"],true),"rw")
    resetConfig
    parse(file.read)
    file.close
    d {
      print "Loaded alternative configuation: ", $config, "\n"
    }
  end
end

puts ARGV, flag("-d")
