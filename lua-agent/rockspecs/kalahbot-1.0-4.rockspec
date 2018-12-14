package = "kalahbot"
version = "1.0-4"
source = {
   url = "git://github.com/hendrikmolder/kalahbot"
}
description = {
   summary = "*** please specify description summary ***",
   detailed = "*** please enter a detailed description ***",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.1, < 5.4",
   "busted",
   "penlight",
   "luacov",
   "luacov-coveralls"
}
build = {
   type = "builtin",
   modules = {
      board = "board.lua",
      main = "main.lua",
      move = "move.lua",
      protocol = "protocol.lua",
      kalah = "kalah.lua",
      side = "side.lua",
      ["spec.board_spec"] = "spec/board_spec.lua",
      ["spec.move_spec"] = "spec/move_spec.lua",
      ["spec.protocol_spec"] = "spec/protocol_spec.lua",
      ["spec.side_spec"] = "spec/side_spec.lua"
   }
}
