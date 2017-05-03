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
#    9.  [MAIN LOOP]
#
#   [] INDICATES MADATORY SETUP

require 'handle.rb'

#
#   FLAG CHECKS
#

puts Time.now.to_s + ": " + "Loading flag checks..."

def e(text)
  if flag("-d")
    print Time.now.to_s + ": "
    puts text
    if flag("-s")
      sleep 0.05
    end
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
CHAR-WALL: "#"
CHAR-PLAYER: "0"
CHAR-ENEMY: "&"

#
#   NODE CONSTRUCTION
#
#   USE  [x,y]=>location(text,wall?)
#   OR   [x,y]=>intio(name,hp,text,mode,reflect?)
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

def parse(config,nodeing)
  e "Parsing config..."
  config.split("\n").each do |cache|
    unless cache.split("")[0] == "#" or cache.strip == ""
      d {print "Scanning line: ", cache, "\n"}
      cache.scan(/[a-zA-Z-]+: .+/).each do |e|
        d {print "Found config match: ", e, "\n"}
        e "Formatting..."
        es = e.split(/: /)
        es[1].strip!
        es[1].gsub!(/^"|"$/, "")
        ed
        e "Adding to config..."
        $config.merge!(Hash[[es]])
        ed
      end
      if nodeing
        cache.scan(/\[\d+,\d+\]=>(?:location\("\S+",(?:true|false)\)|intio\("\w+",\d+,"\S+","\S+",(?:true|false)\))/).each do |e|
          d {print "Found node match: ", e, "\n"}
          e "Formatting..."
          $unn = []
          e.gsub!(/\w+/) { |ele| $unn << ele.to_s }
          ed
          e "Adding " + $unn.to_s + " to board..."
          if $unn[2].strip == "location"
            e $board[$unn[0].to_i][$unn[1].to_i] = Node.new(*$unn.drop(3))
          else
            e $board[$unn[0].to_i][$unn[1].to_i] = NPC.new(*$unn.drop(3))
          end
        end
        ed
      end
    else
      d {print "Found blank line. Ignoring.", "\n"}
    end
  end
  ed
end
e "Loaded parse()"

def loadConfig(f=false)
  e "Loading config..."
  resetConfig
  parse($autoParse,f)
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

def bc(val)
  unless val == false or val == true
    if val.upcase.strip == "TRUE"
      return true
    else
      return false
    end
  else
    return val
  end
end

#
#   OBJECT DEFINITIONS
#

class NPC
  attr_accessor :bchar, :name, :hp, :text, :mode, :reflect
  def initialize(name,hp,text,mode,reflect)
    e "Creating NPC..."
    @name = name
    @hp = hp.to_i
    @text = text
    @mode = mode
    @reflect = bc reflect
    @bchar = $config["CHAR-ENEMY"]
    ed
  end
end
e "Loaded NPC class."

class Node
  attr_accessor :bchar, :text, :wall
  def initialize(text,wall)
    e "Creating Node..."
    @text = text
    @wall = bc wall
    if @wall
      @bchar = $config["CHAR-WALL"]
    else
      @bchar = $config["CHAR-SPACE"]
    end
    ed
  end
end
e "Loaded Node class."

#
#   LOOP DEFINITIONS
#

def genBoard
  system "clear"
  e "Genning board..."
  e "Using board : " + $board.to_s
  print $config["CHAR-CORNER"] + " " + (($config["CHAR-HORIZONTAL"]+" ") * $config["BOARD-WIDTH"].to_i) + $config["CHAR-CORNER"] + "\n"
  0.upto($config["BOARD-HEIGHT"].to_i-1) do |height|
    print $config["CHAR-VERTICAL"] + " "
    0.upto($config["BOARD-WIDTH"].to_i-1) do |width|
      print $board[width][height].bchar, " "
    end
    print $config["CHAR-VERTICAL"]
    puts ""
  end
  print $config["CHAR-CORNER"] + " " + (($config["CHAR-HORIZONTAL"]+" ") * $config["BOARD-WIDTH"].to_i) + $config["CHAR-CORNER"]
  puts ""
  ed
  e "Genning text..."
  (system("tput lines").to_i - $config["BOARD-HEIGHT"] - 4).times do puts "" end
  puts "=" * system("tput cols").to_i
  puts $board[$curx][$cury].text
end
e "Loaded genBoard()"

def mainloop
  genboard
  handle = gets.strip!
  HANDLE.handle(handle)
  mainloop
end

#
#   BUILDING
#

def setup
  $curx,$cury = 0,0
  e "Defining empty board..."
  $board = []
  ed
  loadConfig
  e "Building board skeleton with length " + $config["BOARD-WIDTH"] + " and height " + $config["BOARD-HEIGHT"] + "..."
  $board = Array.new($config["BOARD-WIDTH"].to_i) {Array.new($config["BOARD-HEIGHT"].to_i,Node.new("",false))}
  ed
  e "Using board : " + $board.to_s
  e "Reloading config..."
  loadConfig(true)
  ed
  unless flag("-d")
    genBoard
  end
end
e "Loaded setup()"

e "Here we go..."
setup
ed
e "End of File"
