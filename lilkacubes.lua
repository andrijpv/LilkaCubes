--[[
    Гра "Кубики"
    Гра з вибором кількості кубиків для консолі lilka.dev
]]

WHITE = display.color565(255, 255, 255)
BLACK = display.color565(0, 0, 0)
YELLOW = display.color565(255, 255, 0)
RED = display.color565(255, 0, 0)

-------------------------------------------------------------------------------
-- Завантаження ресурсів
-------------------------------------------------------------------------------

-- Звук кидання кубиків
ROLL_SOUND = {
    {440, 8},
    {523, 8},
    {659, 8},
    {784, 8},
    {880, 8},
}

-- Звук вибору
SELECT_SOUND = {
    {660, 8},
    {880, 8},
}

-------------------------------------------------------------------------------
-- Клас кубика
-------------------------------------------------------------------------------

Dice = {
    x = 0,
    y = 0,
    size = 80,
    color = WHITE,
    current_value = 1,
    is_rolling = false,
    roll_start_time = 0,
    roll_duration = 1,
}

function Dice:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Dice:roll()
    if not self.is_rolling then
        self.is_rolling = true
        self.roll_start_time = util.time()
    end
end

function Dice:update()
    if self.is_rolling then
        local time_elapsed = util.time() - self.roll_start_time
        if time_elapsed < self.roll_duration then
            -- Під час анімації швидко змінюємо значення
            self.current_value = math.floor(math.random() * 6) + 1
        else
            -- Зупиняємо анімацію і встановлюємо фінальне значення
            self.current_value = math.floor(math.random() * 6) + 1
            self.is_rolling = false
        end
    end
end

function Dice:draw()
    -- Малюємо квадрат кубика
    display.fill_rect(self.x - self.size/2, self.y - self.size/2, self.size, self.size, self.color)
    
    -- Малюємо крапки відповідно до значення
    local dot_size = 8
    local padding = 18
    
    if self.current_value == 1 then
        -- Центральна крапка
        display.fill_circle(self.x, self.y, dot_size, BLACK)
    
    elseif self.current_value == 2 then
        -- Дві крапки по діагоналі
        display.fill_circle(self.x - padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y + padding, dot_size, BLACK)
    
    elseif self.current_value == 3 then
        -- Три крапки по діагоналі
        display.fill_circle(self.x - padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x, self.y, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y + padding, dot_size, BLACK)
    
    elseif self.current_value == 4 then
        -- Чотири крапки по кутах
        display.fill_circle(self.x - padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x - padding, self.y + padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y + padding, dot_size, BLACK)
    
    elseif self.current_value == 5 then
        -- П'ять крапок
        display.fill_circle(self.x - padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x, self.y, dot_size, BLACK)
        display.fill_circle(self.x - padding, self.y + padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y + padding, dot_size, BLACK)
    
    elseif self.current_value == 6 then
        -- Шість крапок
        display.fill_circle(self.x - padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y - padding, dot_size, BLACK)
        display.fill_circle(self.x - padding, self.y, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y, dot_size, BLACK)
        display.fill_circle(self.x - padding, self.y + padding, dot_size, BLACK)
        display.fill_circle(self.x + padding, self.y + padding, dot_size, BLACK)
    end
end

-------------------------------------------------------------------------------
-- Стани гри
-------------------------------------------------------------------------------

STATES = {
    HELLO = 0,     -- Початковий екран
    SELECT = 1,    -- Вибір кількості кубиків
    IN_GAME = 2,   -- Гра
}

-------------------------------------------------------------------------------
-- Змінні стану гри
-------------------------------------------------------------------------------

local game_state = STATES.HELLO
local selected_dice_count = 1  -- Вибрана кількість кубиків
local dice1 = nil
local dice2 = nil

-------------------------------------------------------------------------------
-- Головні цикли гри
-------------------------------------------------------------------------------

function setup_dice(count)
    if count == 1 then
        dice1 = Dice:new({
            x = display.width/2,
            y = display.height/2 - 50,
            color = WHITE
        })
        dice2 = nil
    else
        dice1 = Dice:new({
            x = display.width/2 - 70,
            y = display.height/2 - 50,
            color = WHITE
        })
        dice2 = Dice:new({
            x = display.width/2 + 70,
            y = display.height/2 - 50,
            color = YELLOW
        })
    end
end

function lilka.update(delta)
    local state = controller.get_state()
    
    if game_state == STATES.HELLO then
        if state.start.just_pressed then
            game_state = STATES.SELECT
        end
    elseif game_state == STATES.SELECT then
        -- Вибір кількості кубиків
        if state.left.just_pressed or state.right.just_pressed then
            selected_dice_count = selected_dice_count == 1 and 2 or 1
            buzzer.play_melody(SELECT_SOUND, 400)
        end
        
        if state.start.just_pressed then
            setup_dice(selected_dice_count)
            game_state = STATES.IN_GAME
        end
    else
        -- Оновлюємо стан кубиків
        dice1:update()
        if dice2 then 
            dice2:update()
        end
        
        -- Якщо натиснута кнопка A і кубики не крутяться
        if state.a.just_pressed then
            local can_roll = not dice1.is_rolling
            if dice2 then
                can_roll = can_roll and not dice2.is_rolling
            end
            
            if can_roll then
                dice1:roll()
                if dice2 then
                    dice2:roll()
                end
                buzzer.play_melody(ROLL_SOUND, 400)
            end
        end
        
        -- Повернення до вибору кількості кубиків
        if state.b.just_pressed then
            game_state = STATES.SELECT
        end
        
        -- Вихід з гри
        if state.start.just_pressed then
            util.exit()
        end
    end
end


function lilka.draw()
    if game_state == STATES.HELLO then
        display.fill_screen(BLACK)
        display.set_cursor(display.width/2 - 50, display.height/2 - 20)
        display.print("ГРА КУБИКИ")
        display.set_cursor(display.width/2 - 80, display.height/2 + 20)
        display.print("Натисніть START")
    
    elseif game_state == STATES.SELECT then
        display.fill_screen(BLACK)
        display.set_cursor(display.width/2 - 100, 30)
        display.print("Оберіть кількість")
        display.set_cursor(display.width/2 - 45, 50)
        display.print("кубиків:")
        
        -- Малюємо варіанти вибору
        local y = display.height/2
        
        -- Перший кубик
        if selected_dice_count == 1 then
            display.fill_rect(display.width/2 - 80, y - 15, 30, 30, RED)
        else
            display.fill_rect(display.width/2 - 80, y - 15, 30, 30, WHITE)
        end
        display.set_cursor(display.width/2 - 70, y + 30)
        display.print("1")
        
        -- Два кубики
        if selected_dice_count == 2 then
            display.fill_rect(display.width/2 + 50, y - 15, 30, 30, RED)
        else
            display.fill_rect(display.width/2 + 50, y - 15, 30, 30, WHITE)
        end
        display.set_cursor(display.width/2 + 60, y + 30)
        display.print("2")
        
        display.set_cursor(10, display.height - 60)
        display.print("Ліво/Право - для вибору")
        display.set_cursor(10, display.height - 40)
        display.print("START - для підтвердження")
        
    else
        display.fill_screen(BLACK)
        -- Малюємо кубики
        dice1:draw()
        if dice2 then
            dice2:draw()
        end
        local instructions_y = display.height - 80 
        
        display.set_cursor(10, instructions_y)
        if not dice1.is_rolling and (not dice2 or not dice2.is_rolling) then
            local sum = dice1.current_value
            if dice2 then
                sum = sum + dice2.current_value
            end
            display.print("Сума: " .. sum)
        else
            display.print("Сума: --")
        end

        display.set_cursor(10, instructions_y + 20)
        display.print("A - кинути кубики")
        display.set_cursor(10, instructions_y + 40)
        display.print("B - змінити кількість")
        display.set_cursor(10, instructions_y + 60)
        display.print("START - вихід")
    end
end