--Conway's Game of Life simulator!
--48x48, history keeping, toroidal array.
--Designed to run in 3d. TO render in 2d, use only first bit.
--Also, OOP is wierd in lua.

local Life = {}
Life.__index = Life

Life.CURR = 0x80000000
Life.LAST = 0x40000000

setmetatable(Life, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})

function Life.new()
    local self = setmetatable({}, Life)
    self.map = {}
    --self:initMap(false)
    return self
end

function Life:initMap(random)
    random = random or false
    for x = 1, 48 do
        self.map[x] = {}
        for z = 1, 48 do
            if random and math.random(0, 1) == 1 then
                self.map[x][z] = Life.CURR
            else
                self.map[x][z] = 0
            end
        end
    end
end

local function wrap(num)
    if num < 1 then
        return 48
    elseif num > 48 then
        return 1
    else
        return num
    end
end

function Life:check(x, z)
    return bit32.band(Life.LAST, self.map[x][z]) > 0
end

function Life:update()
    for x = 1, 48 do
        for z = 1, 48 do
            --Shift all existing data down one bit
            self.map[x][z] = bit32.rshift(self.map[x][z], 1)
        end
    end
    for x = 1, 48 do
        for z = 1, 48 do
            local me = bit32.band(Life.LAST, self.map[x][z])
            local neighbors = 0
            if self:check(wrap(x - 1), z) then neighbors = neighbors + 1 end
            if self:check(wrap(x + 1), z) then neighbors = neighbors + 1 end
            if self:check(x, wrap(z - 1)) then neighbors = neighbors + 1 end
            if self:check(x, wrap(z + 1)) then neighbors = neighbors + 1 end
            if neighbors == 2 then
                --BORN/live
                self.map[x][z] = bit32.bor(Life.CURR, self.map[x][z])
            elseif neighbors == 3 then
                --Same as before
                if self:check(x, z) then
                    self.map[x][z] = bit32.bor(Life.CURR, self.map[x][z])
                end
            else
                --Dead by default
            end
        end
    end
end

function Life:renderHolo(holo, singleRow)
    singleRow = singleRow or false
    for x = 1, 48 do
        for z = 1, 48 do
            if singleRow then
                if self:check(x, z) then
                    holo.set(x, z, 1)
                else
                    holo.set(x, z, 0)
                end
            else
                holo.set(x, z, self.map[x][z])
            end
        end
    end
end

function Life:renderScreen(screen)
end


local life = {}
life.Life = Life
return life