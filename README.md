[![Build Status](https://travis-ci.com/hendrikmolder/kalahbot.svg?token=Mof5Gq1xr932bpnQpwj3&branch=master)](https://travis-ci.com/hendrikmolder/kalahbot)

# kalahbot
COMP34120 Project 1

## Running & Developing

The runnable file is `main.lua`. To run the bot, just run that file using `lua main.lua`.

1. Install Lua
2. Install Luarocks using `sudo apt-get install luarocks` or `brew install luarocks` if you have home brew installed.
3. Navigate into the `lua-agent` directory and install dependencies using `luarocks make --local`.

### Project structure

```
. (kalahbot)
├─ lua-agent        (the lua agent that plays the game)
|  └─ spec          (lua tests)
├─ mankalah         (the game engine that was provided)
```

## Testing

 Lua tests are ran using Busted. Please follow these steps. Make sure you have installed all dependencies using `luarocks make --local` inside `lua-agent` directory. Then, run all tests using `busted` inside the `lua-agent` directory.

 NB! You _may_ also have to install busted dependencies manually using the instructions below.

```bash
luarocks install copas
luarocks install lua-ev scm --server=http://luarocks.org/repositories/rocks-scm/
luarocks install moonscript
```
