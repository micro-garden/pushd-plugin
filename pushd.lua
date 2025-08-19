VERSION = "0.0.2"

local micro = import("micro")
local config = import("micro/config")
local os = import("os")

local function getCurrentDir()
	local wd, err = os.Getwd()
	if err ~= nil then
		micro.InfoBar:Error("Getwd failed")
		return nil
	else
		return wd
	end
end

local function setCurrentDir(bp, path)
	bp:CdCmd({ path })
	micro.InfoBar():Message("Changed directory to " .. path)
end

local dirStack = {}

function Pushd(bp, args)
	if #args == 0 then
		if #dirStack == 0 then
			micro.InfoBar():Error("Directory stack is empty")
			return
		else
			local dir = dirStack[1]
			dirStack[1] = getCurrentDir()
			setCurrentDir(bp, dir)
			return
		end
	end

	if #args == 1 then
		table.insert(dirStack, 1, getCurrentDir())
		setCurrentDir(bp, args[1])
		return
	end

	micro.InfoBar():Error("Too many arguments")
end

function Popd(bp)
	if #dirStack == 0 then
		micro.InfoBar():Error("Directory stack is empty")
		return
	end

	setCurrentDir(bp, table.remove(dirStack, 1))
end

function Dirs(bp, args)
	if #args == 0 then
		local buf = {}
		table.insert(buf, 0 .. " " .. getCurrentDir())
		for i, v in ipairs(dirStack) do
			table.insert(buf, i .. " " .. v)
		end
		micro.TermMessage(table.concat(buf, "\n"))
		return
	end

	local match = args[1]
	for i, v in ipairs(dirStack) do
		if v == match then
			table.remove(dirStack, i)
			table.insert(dirStack, 1, getCurrentDir())
			setCurrentDir(bp, v)
			return
		end
	end
	micro.InfoBar():Error("No such directory in stack: " .. match)
end

function DirsComplete(bp)
	local completions = {}
	local descriptions = {}

	for i, dir in ipairs(dirStack) do
		table.insert(completions, dir)
		table.insert(descriptions, "No. " .. i .. " directory in stack")
	end

	return completions, descriptions
end

function init()
	config.MakeCommand("pushd", Pushd, config.FileComplete)
	config.MakeCommand("popd", Popd, config.NoComplete)
	config.MakeCommand("dirs", Dirs, DirsComplete)
	config.AddRuntimeFile("pushd", config.RTHelp, "help/pushd.md")
end
