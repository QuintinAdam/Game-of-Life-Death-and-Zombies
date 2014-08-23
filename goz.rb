# Game of Life, Death and Zombies.

# if a live cell has less of equal to 1 live neighbors or greater then 4 or more live neighbors the cell dies

# if a dead cell has exactly 3 live neighbors the cell becomes alive

# if a zombie cell has 4 or more live cells, zombie cell will die.

# if zombie cell has less then 3 live cells it will convert all live cells around it to a zombie.

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
    find_status == :alive ? 1 : 0
  end

  def to_s
    # Override the to_s method so when the cell gets put to the screen it will display how we want it to
    # we call methods to make the if statement cleaner.
    case find_status
    when :alive
      'o'
    when :dead
      ' '
    else 
      'z'
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

  def initialize(height = 25, width = 50, alive_chance = 0.2, sleep = 0.75)
    @game_over, @cycle, @count, @height, @width, @sleep = false, 0, height * width, height, width, sleep #set up default variables
    
    # @world = Array.new(10) { Array.new(10) { Cell.new(0.5) } } 
    @world = Array.new(height) { Array.new(width) { Cell.new(alive_chance) } }
    #make 1 zombie cell
    #could make this random and do it x.times if you wanted more zombies
    3.times do
      @world[rand(0...height)][rand(0...width)].update_status!(:zombie)
    end
  end

  def cycle!
    until @game_over
      #display world
      display
      #check each cell neighbors
      check_each_cell!
      #check if cell is a zombie and update it based on the zombie rules
      update_each_zombie_cell
      #after updating all the cells to be zombies go through each cell and update based of normal rules
      update_each_normal_cell
      #update and put stats also check if game is over
      update_and_display_stats
    end
  end

  def display
    system('clear')
    puts self
  end

  def update_and_display_stats
    @cycle += 1 #add 1 to the cycle every to so we can keep score
    alive_count, dead_count, zombie_count = 0, 0, 0
    flat_world = @world.flatten
    flat_world.each do |cell|
      case cell.find_status
      when :alive
        alive_count += 1
      when :dead
        dead_count += 1
      when :zombie
        zombie_count += 1
      end
    end

    puts "Cycle: #{@cycle}   Alive Cells: #{alive_count}   Zombie Cells: #{zombie_count}   Dead Count: #{dead_count}   Total Cells: #{@count}"
    #check if game is done
    if zombie_count == 0
      puts "Hurray! All the zombies are dead!!!"
      @game_over = true
    elsif zombie_count + dead_count == @count
      puts "The zombies have killed everyone..."
      @game_over = true
    elsif alive_count == 0
      puts "Everyone is dead..."
      @game_over = true
    end
    if @sleep
      sleep(@sleep)
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
    [[-1, 0], [1, 0],           # sides
     [-1, 1], [0, 1], [1, 1],   # top
     [-1, -1], [0, -1], [1, -1] # bottom
    ].inject(0) do |sum, pos|
      sum + @world[(row + pos[0]) % @height][(cell + pos[1]) % @width].to_i
    end
  end
  
  def update_each_zombie_cell
    @world.each_with_index do |row, row_index|
      row.each_with_index do |cell, cell_index|
        if cell.find_status == :zombie
          if cell.neighbors >= 3
            cell.update_status!(:dead)
          else
            #find the live cell around the zombie and turn live cells into pending zombie cells
            [[-1, 0], [1, 0],           # sides
             [-1, 1], [0, 1], [1, 1],   # top
             [-1, -1], [0, -1], [1, -1] # bottom
            ].each do |pos|
              neighbor_cell = @world[(row_index + pos[0]) % @height][(cell_index + pos[1]) % @width]
              neighbor_cell.update_status!(:pending_zombiefication) if neighbor_cell.to_i == 1
            end
          end
        end
      end
    end
  end

  def  update_each_normal_cell
    @world.each { |row| row.each { |cell| cell.update_cell_by_normal_rules } }
  end

  def to_s
    # Override the to_s method so when we puts @world it will display how we need it. 
    # Also uses the cell.to_s method to convert cell into better strings to display on the screen ('o', ' ', 'z')
    @world.map { |row| row.join }.join("\n")
  end
end

Game.new($screen.first - 2, $screen.last, 0.4, 0.1).cycle!
# Game.new(10, 10, 0.2)