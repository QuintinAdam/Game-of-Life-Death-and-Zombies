#Game of Life, Death and Zombies

## and llamas

My modified version of Conway's game of life.

###Rules are simple:

  1. if a live cell has less then or equal to 1 live neighbor or greater then 4 or more live neighbors the cell dies
  2. if a dead cell has exactly 3 live neighbors the cell becomes alive
  3. if a zombie cell has 3 or more live cells, zombie cell will die
  4. if zombie cell has less then 3 live cells it will convert all live cells around it to a zombie.
  5. if zombie cell has no live neighbors the zombie can move in any direction
  6. llamas can kill zombies and have double the radius as other cells.

Game ends when:

  - Zombies kill all the live cells
  - All Zombies are dead
  - All Alive cells are dead

###Setup:

Simply clone this repository and run the ruby file.

`ruby goz.rb`

####Customize:

In goz.rb at the bottom of the file you can pass in different parameters to change how the game is runs.

```
Game.new($screen.first / 2 , $screen.last / 2, 0.2, 0.1, 1).cycle!
# You can customize this however you like
# Game.new( hight, width, % chance of live cell, sleep time, zombies at start of game).cycle!
```

- hight: Any Integer
- width: Any Integer
- % chance of live cell: From 0.1 to 1
- sleep time: Any Integer or float(higher the number the slower the program)
- zombies at start of game: Any Integer

###Suggestions

If you have other ideas for zombies let me know.
