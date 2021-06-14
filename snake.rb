require 'ruby2d'

set background: 'black'
set fps_cap: 15

GRID = 15
GRID_WIDTH = Window.width / GRID
GRID_HEIGHT = Window.height / GRID 

class Snake
    attr_writer :direction
    def initialize
        @places = [[2, 0], [2, 1], [2, 2], [2, 3]]
        @direction = 'down'
        @growth = false
    end

    def snk
        @places.each do |place|
            Square.new(x: place[0] * GRID, y: place[1] * GRID, size: GRID - 1, color: 'white')
        end
    end

    def move
        if !@growth
            @places.shift
        end
        
        case @direction
        when 'down'
            @places.push(new_coordinates(head[0], head[1]+1))
        when 'up'
            @places.push(new_coordinates(head[0], head[1]-1))
        when 'left'
            @places.push(new_coordinates(head[0]-1, head[1]))
        when 'right'
            @places.push(new_coordinates(head[0]+1, head[1]))
        end

        @growth = false
    end

    def change_direction?(new_direction)
        case @direction
        when 'up' then new_direction != 'down'    
        when 'down' then new_direction != 'up' 
        when 'right' then new_direction != 'left' 
        when 'left' then new_direction != 'right' 
        end
    end

    def x
        head[0]
    end

    def y
        head[1]
    end

    def grow
        @growth = true
    end

    def itself?
        @places.uniq.length != @places.length
    end

    private

    def new_coordinates(x, y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def head
        @places.last
    end
end

class Game
    def initialize
        @score = 0
        @apple_x = rand(GRID_WIDTH)
        @apple_y = rand(GRID_HEIGHT)
        @game_over = false
    end

    def draw
        unless game_over?
            Square.new(x: @apple_x * GRID, y: @apple_y * GRID, size: GRID, color: 'aqua')
        end
        Text.new(message, color: 'green', x: 10, y: 10, size: 20)
    end

    def hit_apple?(x, y)
        @apple_x == x && @apple_y == y 
    end

    def add_score
        @score += 1
        @apple_x = rand(GRID_WIDTH)
        @apple_y = rand(GRID_HEIGHT)
    end

    def over
        @game_over = true
    end

    def game_over?
        @game_over
    end

    def message
        if game_over?
            "Game Over. Score: #{@score}. R to restart."
        else
            "Score: #{@score}"
        end
    end
end

snake = Snake.new
game = Game.new


update do
    clear

    unless game.game_over?
        snake.move
    end 
    
    snake.snk
    game.draw

    if game.hit_apple?(snake.x, snake.y)
        game.add_score
        snake.grow
    end

    if snake.itself?
        game.over
    end
end

on :key_down do |event|
    if ['up', 'down', 'left', 'right'].include?(event.key)
        if snake.change_direction?(event.key)
            snake.direction = event.key
        end
    elsif event.key == "r"
        snake = Snake.new
        game = Game.new
    end
end

show 