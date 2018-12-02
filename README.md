[![Build Status](https://travis-ci.com/hendrikmolder/kalahbot.svg?token=Mof5Gq1xr932bpnQpwj3&branch=master)](https://travis-ci.com/hendrikmolder/kalahbot)

# kalahbot
COMP34120 Project 1

## Running & Developing

The runnable file is `main.lua`. To run the bot, just run that file using `lua main.lua`.

1. Install Lua
2. Install Luarocks using `sudo apt-get install luarocks` or `brew install luarocks` if you have home brew installed.
3. Navigate into the `lua-agent` directory and install dependencies using `luarocks make --local rockspecks/<choose the latest rockspec>`.
4. You may need to add luarocks path to your lua path by using `eval $(luarocks path --bin)` on UNIX systems.

### Logs

Logs are stored in `logs` subfolder. If it doesn't exist, you may have to create it under `lua-agent`. Logfiles are named by the system date. Reccommended way to see logs is using `tail -f <logfile>`.

### Project structure

```
. (kalahbot)
├─ lua-agent        (the lua agent that plays the game)
|  └─ logs          (logs directory, logfiles ignored by git)
|  └─ rockspecks    (luarocks rockspecs)
|  └─ spec          (lua tests)
|  └─ utils         (util functions)
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
