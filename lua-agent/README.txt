## Group 18 bot ##

## Requirements ##
- The machine needs to have Lua installed.
- The machine needs to have tar installed.
- If the .tar.gz archive is unpacked (see next section) into a directory, please navigate into that directory.
  Please ensure that you are in the same directory where main.lua file is.

## How to unpack ##
1.  Download the .tar.gz file.
2.  Navigate into the directory where the .tar.gz file is.
3.  Create a directory for the where the contents of the archive will be extracted.
    `mkdir lua-bot` (you can use any directory name instead of lua-bot)
4.  Extract the archive into lua-bot. `tar -xvf kalahbot.tar.gz -C lua-bot/`
    (make sure to replace "kalahbot" with the name of the .tar.gz file and "lua-bot" with dir name)

## Running the bot ##
Navigate into the directory where main.lua is (if you followed unpacking instructions, this would be lua-bot).

NB! Due to how Lua sets its paths (and this might be different in every machine), to run our bot, you must execute the command
    from *inside the lua-bot directory*, where main.lua is. This is very important. If the agent breaks before playing any moves,
    this is the most likely cause.

- The command to run the bot is `lua -l utils.init main.lua`.
- For example, to play agains itself, you would run the command:
    `java -jar [path to ManKalah.jar] "lua -l utils.init main.lua" "lua -l utils.init main.lua"`

## Help ##
If you are unable to run the bot, please contact hendrik@molder.eu.