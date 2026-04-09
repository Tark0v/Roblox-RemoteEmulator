--[[
	local remoteEvent: RemoteEvent = nil
	remoteEvent.OnServerEvent
	remoteEvent.OnClientEvent

	remoteEvent:FireServer()
	remoteEvent:FireClient()
	remoteEvent:FireAllClients()
]]

local PlayerService = game:GetService("Players")
local localPlayer = PlayerService.LocalPlayer

local remoteEmulator = script.Parent.Parent
local packages = remoteEmulator.Packages

local TypeLibrary = require(remoteEmulator.TypeLibrary)
local Signal = require(packages.Signal)

local remoteEvent = {}
remoteEvent.__index = remoteEvent

function remoteEvent.new(remoteID: string, emulatorMock: TypeLibrary.EMULATOR_MOCK): TypeLibrary.REMOTE_EVENT_MOCK
	local remoteMock = {
		_Props = {
			Emulator = emulatorMock,
			RemoteID = remoteID,
			RemoteType = "RemoteEvent",
		},
		OnServerEvent = emulatorMock.ServerContext,
		OnClientEvent = emulatorMock.ClientContext
	}
	
	return setmetatable(remoteMock, remoteEvent)
end

function remoteEvent.FireServer(remoteMock: TypeLibrary.REMOTE_EVENT_MOCK, ...)
	remoteMock.OnServerEvent:Fire(localPlayer, ...)
end

function remoteEvent.FireClient(remoteMock: TypeLibrary.REMOTE_EVENT_MOCK, ...)
	--assert(player:IsDescendantOf(PlayerService), "FireClient: player argument must be a Player object")
	
	remoteMock.OnClientEvent:Fire(...)
end

function remoteEvent.FireAllClients(remoteMock: TypeLibrary.REMOTE_EVENT_MOCK, ...)
	remoteMock.OnClientEvent:Fire(...)
end

return remoteEvent
