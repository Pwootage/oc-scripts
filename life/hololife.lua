--Holographic Game of Life projection in 3d

local component = require("component")
local Life = require("life")

local holo = component.hologram

local gol = new Life()
gol.initMap(true)

local ticks = 0;
while true do
    ticks = ticks + 1
    gol.update()
    gol.renderHolo(holo)
    os.sleep(0.1)
end