package = "kalahbot"
version = "1.0-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   summary = "*** please specify description summary ***",
   detailed = "*** please enter a detailed description ***",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
    "lua >= 5.1, <= 5.4",
    "busted",
    "penlight"
}
build = {
   type = "builtin",
   modules = {
      Main = "Main.lua",
      protocol = "protocol.lua",
      ['spec.protocol_spec'] = "spec/protocol_spec.lua"
   }
}
