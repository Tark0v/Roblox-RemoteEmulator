local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")

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

local RUN_EMULATOR = RunService:IsStudio() and not RunService:IsRunning()
local REMOTE_EVENT_STRING = "RemoteEvent"
local REMOTE_FUNCTION_STRING = "RemoteFunction"

Registration.RegisterContainer(REMOTE_EVENT_STRING)
Registration.RegisterContainer(REMOTE_FUNCTION_STRING)

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

function emulator.newRemoteEvent(remoteID: string): TypeLibrary.REMOTE_EVENT_MOCK
	return Registration.GetFromRegistry(REMOTE_EVENT_STRING, remoteID) 
		or Registration.AddToRegistry(
			REMOTE_EVENT_STRING, 
			remoteID, 
			remoteTypes.RemoteEvent.new(remoteID, newEmulatorMock())
		)
end

function emulator.newRemoteFunction(remoteID: string): TypeLibrary.REMOTE_FUNCTION_MOCK
	return Registration.GetFromRegistry(REMOTE_FUNCTION_STRING, remoteID) 
		or Registration.AddToRegistry(
			REMOTE_FUNCTION_STRING, 
			remoteID, 
			remoteTypes.RemoteFunction.new(remoteID, newEmulatorMock())
		)
end

--//Event Wrappers

function emulator.WrapRemoteEvent(remote: RemoteEvent): RemoteEvent
	if RUN_EMULATOR then
		remote = emulator.newRemoteEvent(remote.Name)
	end
	
	return remote
end

function emulator.WrapRemoteFunction(remote: RemoteFunction): RemoteFunction
	if RUN_EMULATOR then
		remote = emulator.newRemoteFunction(remote.Name)
	end

	return remote
end

function emulator.GetRegistration()
	return Registration
end


return emulator
