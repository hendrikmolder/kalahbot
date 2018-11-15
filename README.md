# kalahbot
COMP34120 Project 1

## Project Plan:

1. Build game engine in Lua, first with MCTS and then with RL if possible.
2. Try reinforcement learning. Start[here.](https://medium.com/emergent-future/simple-reinforcement-learning-with-tensorflow-part-0-q-learning-with-tables-and-neural-networks-d195264329d0)


## Reference Documents:

1. [Monte Carlo Tree Search for Kalah](http://www.cs.du.edu/~sturtevant/papers/im-mcts.pdf)

## Deadlines:


- [ ] 14/10/2018 
    - Get template code for game playing agent setup locally.
    - Finish reading MCTS [1] paper for Kalah.
- [ ] 1/11/2018
    - Finish MCTS implementation.
- [ ] 13/12/2018
    - Final project submission.

## Testing

 Lua tests are ran using Busted. Please follow these steps.

 1. Install Luarocks using `sudo apt-get install luarocks` or `brew install luarocks` if you have home brew installed.
 2. Install busted using `luarocks install busted`.
 3. Run all tests using `busted` inside the `lua-agent` directory.

 NB! You _may_ also have to install busted dependencies manually using the instructions below.

```bash
luarocks install copas
luarocks install lua-ev scm --server=http://luarocks.org/repositories/rocks-scm/
luarocks install moonscript
```
