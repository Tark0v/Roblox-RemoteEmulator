local remoteEmulator = script.Parent.Parent
local packages = remoteEmulator.Packages

local TypeLibrary = require(remoteEmulator.TypeLibrary)

local module = {}

function module.Destroy(remoteMock: TypeLibrary.Remote_Base, ...)
	remoteMock._Props.Emulator.Janitor:CleanObject()

	setmetatable(remoteMock, nil)
	table.clear(remoteMock)
	table.freeze(remoteMock)
end

function module.IsA(remoteMock: TypeLibrary.REMOTE_EVENT_MOCK, class: string&Instance)
	local res = false
	if typeof(class) == "Instance" then
		error("IsA Instance comparisons arent implemented yet")
	else
		res = remoteMock._Props.RemoteType == class
	end
	
	return res 
end

return module
