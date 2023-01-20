--[[
 This it the tutorial I used. 
 https://www.youtube.com/watch?v=I549C6SmUnk&t=4161s
]]

--imports functions from enemy.lua
local enemy = require "enemy"
--imports functions from button.lua
local button = require "button"
math.randomseed(os.time())
 
--creates the "game object and assigns inheritance"
local game = {
        difficulty = 1,
        state = {
            menu = true,
            paused= false,
            running = false,
            ended = false
        },
        points = 0,
        levels = {15, 30, 60, 120}
    }
--creates the "fonts" object and assigns inheritance"
    local fonts = {
        medium = {
            font = love.graphics.newFont(16),
            size = 16
        },
        large = {
            font = love.graphics.newFont(24),
            size = 24
        },
        massive = {
            font = love.graphics.newFont(60),
            size = 60
        }
    }
--creates the "player" object and assigns inheritance"
    local player = {
        radius = 20,
        x = 30,
        y = 30
    }
--creates the "buttons" object and assigns inheritance"
    local buttons = {
        menu_state = {},
        ended_state = {}
    }
    
    
    local enemies = {}
--Sets the various state of the game
    local function changedGameState(state)
        game.state["menu"] = state == "menu"
        game.state["paused"] = state == "paused"
        game.state["running"] = state == "running"
        game.state["ended"] = state == "ended"
    end

    local function startNewGame()
        changedGameState("running")
        
        game.points = 0

        enemies = {
            enemy(1)
        }
    end

    function love.mousepressed(x, y, button, istouch, presses)
        if not game.state['running'] then
            if button == 1 then
                if game.state["menu"] then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(x, y, player.radius)
              end
            elseif game.state["ended"] then
                for index in pairs(buttons.ended_state) do
                    buttons.ended_state[index]:checkPressed(x, y, player.radius)
              end
            end
          end
        end
    end
    

function love.load()
    love.mouse.setVisible(false)
--Sets the buttons on the start screen
    buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
    buttons.menu_state.settings = button("Settings", nil, nil, 120, 40)
    buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 120, 40)
--Sets the buttons on the end screen
    buttons.ended_state.replay_game = button("Replay", startNewGame, nil, 100, 50)
    buttons.ended_state.menu = button("Menu", changedGameState, "menu", 100, 50)
    buttons.ended_state.exit_game = button("Quit", love.event.quit, nil, 100, 50)
   end

function love.update(dt)
    player.x,  player.y = love.mouse.getPosition()                                          

    if game.state["running"] then
        for i = 1, #enemies do
            if not enemies[i]:checkTouched(player.x, player.y, player.radius) then
                enemies[i]:move(player.x, player.y)

                for i = 1, #game.levels do
                    if math.floor(game.points) == game.levels[i] then
                        table.insert(enemies, 1, enemy(game.difficulty * (i + 1)))

                        game.points = game.points + 1
                    end
                end
            else
                changedGameState("ended")
            end
            
        end
        game.points = game.points + dt
    end
end

function love.draw()
    love.graphics.setFont(fonts.medium.font)
    love.graphics.printf("FPS: " .. love.timer.getFPS(), fonts.medium.font, 10, love.graphics.getHeight() - 30, love.graphics.getWidth())

    if game.state["running"] then 
        love.graphics.printf(math.floor(game.points), fonts.large.font, 0, 10, love.graphics.getWidth(), "center")

        for i = 1, #enemies do
            enemies[i]:draw()
    end

         love.graphics.circle("fill", player.x, player.y, player.radius)
    elseif game.state["menu"] then
        buttons.menu_state.play_game:draw(10, 20, 17, 10)
        buttons.menu_state.settings:draw(10, 70, 17, 10)
        buttons.menu_state.exit_game:draw(10, 120, 17, 10)
    elseif game.state["ended"] then
        love.graphics.setFont(fonts.large.font)

        buttons.ended_state.replay_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.8, 10, 10)
        buttons.ended_state.menu:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.53, 17, 10)
        buttons.ended_state.exit_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.33, 22, 10)

        love.graphics.printf(math.floor(game.points), fonts.massive.font, 0, love.graphics.getHeight() / 2 - fonts.massive.size, love.graphics.getWidth(), "center")
    end

    if not game.state["running"] then 
        love.graphics.circle("fill", player.x, player.y, player.radius / 2)
   end
end