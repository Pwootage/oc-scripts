--Holographic Game of Life projection in 3d

local component = require("component")
local life = require("life")

local holo = component.hologram

local gol = life.Life()
gol:initMap(true)

local ticks = 0;
while true do
    ticks = ticks + 1
    gol:update()
    gol:renderHolo(holo)
    os.sleep(0.1)

    if ticks > 500 then
        ticks = 0
        gol:initMap(true)
    end
end