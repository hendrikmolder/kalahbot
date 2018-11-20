package = "kalahbot"
version = "1.0-2"
source = {
   url = "https://github.com/hendrikmolder/kalahbot"
}
description = {
   summary = "*** please specify description summary ***",
   detailed = "*** please enter a detailed description ***",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.1, < 5.4", "busted", "penlight"
}
build = {
   type = "builtin",
   modules = {
      protocol = "protocol.lua",
      ['spec.protocol_spec'] = "spec/protocol_spec.lua",
      board = "board.lua",
      ['spec.board_spec'] = "spec/board_spec.lua"
   }
}
