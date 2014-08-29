# Game of Life, Death and Zombies.

  # 1. if a live cell has less then or equal to 1 live neighbor or greater then 4 or more live neighbors the cell dies
  # 2. if a dead cell has exactly 3 live neighbors the cell becomes alive
  # 3. if a zombie cell has 3 or more live cells, zombie cell will die
  # 4. if zombie cell has less then 3 live cells it will convert all live cells around it to a zombie.
  # 5. if zombie cell has no live neighbors the zombie can move in any direction
  # Game ends when:
  #   - Zombies kill all the live cells
  #   - All Zombies are dead
  #   - All Alive cells are dead

# get the screen size
require 'io/console'
$screen = IO.console.winsize

class Cell
  #so we can save a neighbors count attribute to each cell object
  attr_accessor :neighbors

  def initialize(alive_chance)
    #Set cell alive if alive chance is greater then a random number between 0 and 1
    @alive = alive_chance > rand ? :alive : :dead
  end

  def find_status
    #will return the status of the cell. :alive, :dead, :zombie
    @alive
  end

  def to_i
    # will return one only if alive. Good for adding neighbors
    find_status == :alive ? 1 : 0
  end

  def to_s
    # Override the to_s method so when the cell gets put to the screen it will display how we want it to
    # we call methods to make the if statement cleaner.
    case find_status
    when :alive
      'O'.black.bg_green
    when :dead
      ' '.black.bg_green
    when :zombie
      'Z'.bg_red.black
    when :llama
      'L'.magenta.bg_black
    end
  end

  def update_status!(update_to)
    # Update the status of the cell to whatever we pass in as a parameter.
    @alive = update_to
  end

  def update_cell_by_normal_rules
    case find_status
    when :alive
      update_status!(:dead) if @neighbors <= 1 || @neighbors >= 4
    when :dead
      update_status!(:alive) if @neighbors == 3
    when :pending_zombiefication
      update_status!(:zombie)
    end
  end
end

class Game
  NEIGHBORS_POS = [[-1, 0], [1, 0],           # sides
                   [-1, 1], [0, 1], [1, 1],   # top
                   [-1, -1], [0, -1], [1, -1] # bottom
                  ]
  LLAMA_NEIGHBORS_POS = [[-1, 0], [1, 0], [-2, 0], [2, 0],           # sides
                         [-1, 1], [0, 1], [1, 1], [-2, 2], [0, 2], [2, 2],   # top
                         [-1, -1], [0, -1], [1, -1], [-2, -2], [0, -2], [2, -2] # bottom
                        ]
  def initialize(height = 50, width = 75, alive_chance = 0.2, sleep = 0.75, starting_zombies = 2)
    @game_over, @cycle, @count, @height, @width, @sleep = false, 0, (height * width), height, width, sleep #set up default variables
    @world = Array.new(height) { Array.new(width) { Cell.new(alive_chance) } }
    starting_zombies.times do
      @world[rand(0...height)][rand(0...width)].update_status!(:zombie)
    end
    #llama time
    3.times do
      @world[rand(0...height)][rand(0...width)].update_status!(:llama)
    end
  end

  def cycle!
    until @game_over
      check_each_cell!
      update_each_zombie_cell
      update_each_normal_cell
      kill_zombies_around_llama
      display
      update_and_display_stats
    end
  end

  def display
    sleep(@sleep)
    system('clear')
    puts self
  end

  def update_and_display_stats
    @cycle += 1 #add 1 to the cycle every to so we can keep score
    counts = @world.flatten.each_with_object(Hash.new(0)) { |cell,counts| counts[cell.find_status] += 1 }
    alive_count, dead_count, zombie_count = counts[:alive], counts[:dead], counts[:zombie]
    puts "Cycle: #{@cycle}".cyan.bold.bg_black + "   Alive Cells: #{alive_count}".green.bold.bg_black  + "   Zombie Cells: #{zombie_count}".red.bold.bg_black + "   Dead Cells: #{dead_count}".magenta.bold.bg_black + "   Total Cells: #{@count}".blue.bold.bg_black
    #check if game is done
    if zombie_count == 0
      puts "Hurray! All the zombies are dead!!!".black.bg_green
      @game_over = true
    elsif zombie_count + dead_count == @count
      puts "The zombies have killed everyone....".black.bg_red
      @game_over = true
    elsif alive_count == 0
      puts "Everyone is dead...".black.bg_red
      @game_over = true
    end
  end

  def check_each_cell!
    #go through each cell to and send to find neighbors
    @world.each_with_index do |row, row_index|
      row.each_with_index do |cell, cell_index|
        cell.neighbors = count_alive_neighbours(row_index, cell_index)
      end
    end
  end

  def count_alive_neighbours(row, cell)
    NEIGHBORS_POS.inject(0) do |sum, pos|
      sum + @world[(row + pos[0]) % @height][(cell + pos[1]) % @width].to_i
    end
  end

  def update_each_zombie_cell
    @world.each_with_index do |row, row_index|
      row.each_with_index do |cell, cell_index|
        if cell.find_status == :zombie
          if cell.neighbors >= 3
            cell.update_status!(:dead)
          elsif cell.neighbors == 0
            # if no alive cells around a zombie we will make a zombie walk.
            move_to(:zombie, cell, row_index, cell_index)
          else
            #find the live cell around the zombie and turn live cells into pending zombie cells
            NEIGHBORS_POS.each do |pos|
              neighbor_cell = @world[(row_index + pos[0]) % @height][(cell_index + pos[1]) % @width]
              neighbor_cell.update_status!(:pending_zombiefication) if neighbor_cell.to_i == 1
            end
          end
        end
      end
    end
  end

  def kill_zombies_around_llama
    @world.each_with_index do |row, row_index|
      row.each_with_index do |cell, cell_index|
        if cell.find_status == :llama
          LLAMA_NEIGHBORS_POS.each do |pos|
            neighbor_cell = @world[(row_index + pos[0]) % @height][(cell_index + pos[1]) % @width]
            if neighbor_cell.find_status == :zombie
              neighbor_cell.update_status!(:alive)
            end
          end
          move_to(:llama, cell, row_index, cell_index)
        end
      end
    end
  end

  def update_each_normal_cell
    @world.each { |row| row.each { |cell| cell.update_cell_by_normal_rules } }
  end

  def move_to(item_to_move, cell, row_index, cell_index)
    move_to = NEIGHBORS_POS.sample
    neighbor_cell = @world[(row_index + move_to[0]) % @height][(cell_index + move_to[1]) % @width]
    move_chance = item_to_move == :llama ? 0.4 : 0.2
    if neighbor_cell.find_status == :dead && move_chance > rand
      cell.update_status!(:dead)
      neighbor_cell.update_status!(item_to_move)
    end
  end

  def to_s
    @world.map { |row| row.join }.join("\n")
  end
end

class String
  def black; "\033[30m#{self}\033[0m" end; def red; "\033[31m#{self}\033[0m" end; def green; "\033[32m#{self}\033[0m" end; def blue; "\033[34m#{self}\033[0m" end; def magenta; "\033[35m#{self}\033[0m" end; def cyan; "\033[36m#{self}\033[0m" end; def bg_black; "\033[40m#{self}\033[0m" end; def bg_red; "\033[41m#{self}\033[0m" end; def bg_green; "\033[42m#{self}\033[0m" end; def bold; "\033[1m#{self}\033[22m" end
end

#screen hight width, population, sleep, starting zombies.
Game.new($screen.first / 2 , $screen.last / 2, 0.3, 0.1, 1).cycle!
# Game.new( hight, width, % chance of live cell, sleep time, zombies at start of game).cycle!
# Game.new.cycle!

# - hight: Any Integer
# - width: Any Integer
# - % chance of live cell: From 0.1 to 1
# - sleep time: Any Integer or float(higher the number the slower the program)
# - zombies at start of game: Any Integer
