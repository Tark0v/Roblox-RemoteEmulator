local packages = script.Packages
local builtin = script.builtin

local TypeLibrary = require(script.TypeLibrary)
local Signal = require(packages.Signal)
local Janitor = require(packages.Janitor)

local emulator = {}
local remoteTypes = {
	RemoteEvent = require(builtin.EmulatedRemoteEvent),
	RemoteFunction = require(builtin.EmulatedRemoteFunction)
}
local InstanceMethods = require(builtin.InstanceMethods)
local Registration = require(builtin.Registration)

for methodID, methodFn in InstanceMethods do
	remoteTypes.RemoteEvent.__index[methodID] = methodFn	
	remoteTypes.RemoteFunction.__index[methodID] = methodFn	
end

Registration.RegisterContainer("RemoteFunctions")
Registration.RegisterContainer("RemoteEvents")

local function newEmulatorMock()
	local remoteJanitor = Janitor.New()
	local emulatorMock = {
		ClientContext = Signal.new(),
		ServerContext = Signal.new(),
		Janitor = remoteJanitor
	}
	
	remoteJanitor:AddObject(function()
		emulatorMock.ClientContext:Destroy()
		emulatorMock.ServerContext:Destroy()
	end)
	
	return emulatorMock
end

function emulator.newRemoteEvent(remoteID: string)
	return Registration.AddToRegistry(
		"RemoteEvents", 
		remoteID, 
		remoteTypes.RemoteEvent.new(remoteID, newEmulatorMock())
	)
end

function emulator.newRemoteFunction(remoteID: string)
	return Registration.AddToRegistry(
		"RemoteFunctions", 
		remoteID, 
		remoteTypes.RemoteFunction.new(remoteID, newEmulatorMock())
	)
end

return emulator
