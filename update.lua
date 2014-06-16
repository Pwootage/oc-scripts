--Auto update script (will DL this repo)

local shell = require("shell")

shell.execute("./gitrepo Pwootage/oc-scripts /disk/oc-scripts/")

print("Updated cc-scripts (unless there was an error up there)")