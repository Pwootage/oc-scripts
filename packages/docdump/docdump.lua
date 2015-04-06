-- Documentation dumper for OC components

local shell = require("shell")
local component = require("component")

local args, options = shell.parse(...)

if #args < 1 then
    print("docdump <component name> <output file>")
    print("Available components:")
    for name, id in pairs(component.list()) do
        print(name .. "\t" .. id)
    end
    return
end

local compName = args[1]
local outFileName = args[2] or (compName .. ".lua")

local c = component[compName]

if not c then
    print("Unknown component " .. compName)
    return
end

local out = io.open(outFileName, "w")

out:write("-- Auto-generated bindings for component '" .. compName .. "'\n")
out:write("component = component or {}\n")
out:write(compName .. " = " .. compName .. " or {}\n")
out:write("component." .. compName .. " = " .. compName .. "\n")
out:write(compName .. ".type = \"" .. c.type .. "\"\n")
out:write(compName .. ".address = \"" .. c.address:gsub("[^-]", "0") .. "\"\n")
out:write(compName .. ".slot = 0\n")
out:write("\n\n\n")


local functions = 0
for name, method in pairs(c) do
    local methodStr = tostring(method)

    if methodStr:find("function") == 1 then
        --Parse args
        local params, retType = methodStr:match("function[(]([^()]*)[)]:?(.*)")
        local descr
        if retType and retType:match("- ?-") then
            retType, descr = retType:match("(.*)%s*- ?-%s*(.*)")
        end
        functions = functions + 1
        local def = "function " .. compName .. "." .. name .. "("
        local doc = "---\n"

        if descr then
            doc = doc .. "-- " .. descr .. "\n"
        end

        if retType then
            doc = doc .. "-- Returns " .. retType .. "\n"
        end

        if params then
            local tmp = params:gsub("[%[%]]", "")
            while true do
                local ind = tmp:find(",") or tmp:len()
                local param = tmp:sub(1, ind):gsub("[, ]", "")
                tmp = tmp:sub(ind + 1)
                if param:find(":") then
                    local n, t = param:match("(.*):(.*)")
                    def = def .. n
                    doc = doc .. "-- @param " .. n .. " " .. t .. "\n"
                else
                    def = def .. param
                end
                if tmp:len() > 0 then
                    def = def .. ","
                else
                    break
                end
            end
        end
        def = def .. ")"

        def = def .. " return "
        if retType then
            local rtRepl = retType
            rtRepl = rtRepl:gsub("table", "{}")
            rtRepl = rtRepl:gsub("number", "0")
            rtRepl = rtRepl:gsub("string", "\"\"")
            rtRepl = rtRepl:gsub("boolean", "false")
            def = def .. rtRepl
            doc = doc .. "-- @return " .. retType .. "\n"
        end
        def = def .. " end"

        def = doc .. def
        --        print(def)
        out:write(def .. "\n\n")
        --        print(string.rep("-", 30))
    elseif name == "type" then
    elseif name == "slot" then
    elseif name == "address" then
        -- Do nothing for the previous entries (they are handled elsewhere)
    else
        local msg = "Unable to process entry: " .. name .. "/" .. methodStr;
        print(msg)
        out:write("-- " .. msg .. "\n\n")
    end
end

out:flush()
out:close()

print("Done! Written to '" .. outFileName .. "'")
print("Functions: " .. functions)
