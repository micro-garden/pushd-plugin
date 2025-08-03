VERSION = "0.0.0"

local micro = import("micro")
local config = import("micro/config")
local os = import("os")
local filepath = import("path/filepath")

local function isWindows()
	return os.Getenv("windir") ~= ""
end

local function getCurrentDir()
	local command = isWindows() and "cd" or "pwd"

	local handle = io.popen(command)
	if not handle then
		return nil
	end

	local result = handle:read("*l")
	handle:close()
	return result
end

local function setCurrentDir(path)
	local ok, err = pcall(os.Chdir, path)

	if not ok then
		micro.InfoBar():Error("os.Chdir failed: " .. err)
	else
		micro.InfoBar():Message("Changed directory to " .. path)
	end
end

local dirStack = {}

function pushd(bp, args)
	if #args == 0 then
		if #dirStack == 0 then
			micro.InfoBar():Error("Directory stack is empty")
			return
		else
			local dir = dirStack[1]
			dirStack[1] = getCurrentDir()
			setCurrentDir(dir)
			return
		end
	end

	if #args == 1 then
		table.insert(dirStack, 1, getCurrentDir())
		setCurrentDir(filepath.Abs(args[1]))
		return
	end

	micro.InfoBar():Error("Too many arguments")
end

function popd(bp)
	if #dirStack == 0 then
		micro.InfoBar():Error("Directory stack is empty")
		return
	end

	setCurrentDir(table.remove(dirStack, 1))
end

function dirs(bp, args)
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
			setCurrentDir(v)
			return
		end
	end
	micro.InfoBar():Error("No such directory in stack: " .. match)
end

function dirsComplete(bp)
	local completions = {}
	local descriptions = {}

	for i, dir in ipairs(dirStack) do
		table.insert(completions, dir)
		table.insert(descriptions, "No. " .. i .. " directory in stack")
	end

	return completions, descriptions
end

function init()
	config.MakeCommand("pushd", pushd, config.FileComplete)
	config.MakeCommand("popd", popd, config.NoComplete)
	config.MakeCommand("dirs", dirs, dirsComplete)
	config.AddRuntimeFile("pushd", config.RTHelp, "help/pushd.md")
end
