# 
#   SOURCE.RB
#   CENTRAL PROSSESING FILE
#
#   CONTAINS:
#    1.  [FLAG CHECKS]
#    2.  CONFIG OVERIDE
#    3.  BOARD CONSTRUCTION
#    4.  NODE CONSTRUCTION
#    5.  [CONFIG DECODER]
#    6.  [OBJECT DEFINITIONS]
#    7.  [LOOP DEFINITIONS]
#    8.  [BULIDING]
#    9. [MAIN LOOP]
#
#   [] INDICATES MADATORY SETUP


#
#   FLAG CHECKS
#

puts Time.now.to_s + ": " + "Loading flag checks..."

def e(text)
  if flag("-d")
    print Time.now.to_s + ": "
    puts text
  end
end

def flag(id,chk=false)
  if chk
    return ARGV[ARGV.index(id)+1]
  else
    return ARGV.include? id
  end
end
e "Loaded e()"
e "Loaded flag()"

def fg(id)
  if ARGV.include? id
    yield
  end
end
e "Loaded fg()"

def d
  if flag("-d")
    print Time.now.to_s + ": "
    yield
  end
end
e "Loaded d()"

def ed
  if flag("-d")
    print Time.now.to_s + ": "
    puts "Done!"
  end
end
e "Loaded ed()"

def rc
  if flag($config["RC-FLAG"]) or $config["RUN-CHECKS"] == "true"
    print Time.now.to_s + ": "
    yield
  end
end
e "Loaded rc()"

e "Flag checks loaded."

e "Starting."

e "Loading default configuration..."

$autoParse = <<ENDOFFILE

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
ed

#
#   CONFIG DECODER
#

e "Loading config managment..."
def resetConfig
  e "Reseting config..."
  $oldConfig = $config
  $config = {}
  ed
end
e "Loaded resetConfig()"

def parse(config)
  e "Parsing config..."
  config.split("\n").each do |cache|
    unless cache.split("")[0] == "#" or cache.strip == ""
      d {print "Scanning config line: ", cache, "\n"}
      cache.scan(/[a-zA-Z-]+: .+/).each do |e|
        d {print "Found match: ", e, "\n"}
        e "Formatting..."
        es = e.split(/: /)
        es[1].strip!
        es[1].gsub!(/^"|"$/, "")
        ed
        e "Adding to config..."
        $config.merge!(Hash[[es]])
        ed
      end
    else
      d {print "Found blank line. Ignoring.", "\n"}
    end
  end
  ed
end
e "Loaded parse()"

def loadConfig
  e "Loading config..."
  resetConfig
  parse($autoParse)
  d {
    print "Loaded default configuation: ", $config, "\n"
  }
  if flag($config["MC-FLAG"]) or $config["MANUAL-CONFIG"] == "true"
    e "Alternate config given. Attempting to open file."
    file = File.open(flag($config["MC-FLAG"],true),"rw")
    e "File opened."
    e "Alternate config found. Loading..."
    resetConfig
    parse(file.read)
    ed
    file.close
    e "File closed."
    d {
      print "Loaded alternative configuation: ", $config, "\n"
    }
  end
end
e "Loaded loadConfig()"
ed

loadConfig
