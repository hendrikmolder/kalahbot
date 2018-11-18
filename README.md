# kalahbot
COMP34120 Project 1

## Project Plan:

1. Build game engine in Lua, first with MCTS and then with RL if possible.
2. Try reinforcement learning. Start[here.](https://medium.com/emergent-future/simple-reinforcement-learning-with-tensorflow-part-0-q-learning-with-tables-and-neural-networks-d195264329d0)


## Reference Documents:

1. [Monte Carlo Tree Search for Kalah](http://www.cs.du.edu/~sturtevant/papers/im-mcts.pdf)

## Deadlines:

-[ ] 14/10/2018
    - Get template code for game playing agent setup locally.
    - Finish reading MCTS [1] paper for Kalah.
-[ ] 1/11/2018
    - Finish MCTS implementation.
-[ ] 13/12/2018
    - Final project submission.

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