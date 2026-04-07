--[[
	local remoteFunction: RemoteFunction = nil
	remoteFunction.OnServerInvoke
	remoteFunction.OnClientInvoke

	remoteFunction:InvokeServer()
	remoteFunction:InvokeClient()
--]]


local PlayerService = game:GetService("Players")
local localPlayer = PlayerService.LocalPlayer

local remoteEmulator = script.Parent.Parent
local packages = remoteEmulator.Packages

local TypeLibrary = require(remoteEmulator.TypeLibrary)
local Signal = require(packages.Signal)

local remoteFunction = {}
remoteFunction.__index = remoteFunction
remoteFunction.__newindex = function(tbl: TypeLibrary.REMOTE_FUNCTION_MOCK, key, item)
	if key ~= "OnServerInvoke" and key ~= "OnClientInvoke" then
		return
	end
	
	assert(item and typeof(item) == "function", `{key} must be a function`)
	
	local requestSignal = tbl._Listeners.ServerRequest
	local invokeSignal = tbl._Props.Emulator.ServerContext
	if key == "OnClientInvoke" then
		requestSignal = tbl._Listeners.ClientRequest
		invokeSignal = tbl._Props.Emulator.ClientContext
	end
	
	invokeSignal:DisconnectAll()
	invokeSignal:Connect(function(requestID: any, ...)
		local res = {item(...)}
		if #res > 0 then
			requestSignal:Fire(requestID, table.unpack(res))
		end
	end)
end

function remoteFunction.new(remoteID: string, emulatorMock: TypeLibrary.EMULATOR_MOCK): TypeLibrary.REMOTE_FUNCTION_MOCK
	local remoteJanitor = emulatorMock.Janitor
	local remoteMock = {
		_Props = {
			Emulator = emulatorMock,
			RemoteID = remoteID,
			RemoteType = "RemoteFunction"
		},
		_Listeners = {
			ServerRequest = Signal.new(),
			ClientRequest = Signal.new()
		},
		OnServerInvoke = nil,
		OnClientInvoke = nil
	}
	
	remoteJanitor:AddObject(function()
		remoteMock._Listeners.ClientRequest:Destroy()
		remoteMock._Listeners.ServerRequest:Destroy()		
	end)
	
	return setmetatable(remoteMock, remoteFunction)
end

local function AwaitRequest(invokeSignal: Signal.Signal<any>, requestSignal: Signal.Signal<any>, ...)
	local requestID = newproxy(false)
	local currentThread = coroutine.running()
	
	local isYielded = false
	local yieldConnection
	local requestResults
	
	yieldConnection = requestSignal:Connect(function(id, ...)
		if id == requestID then
			if not isYielded then
				requestResults = {...}
			else
				task.spawn(currentThread, ...)
			end		
			
			yieldConnection:Disconnect()
		end
	end)
	
	invokeSignal:Fire(requestID, ...)
	
	if requestResults then
		yieldConnection:Disconnect()
		return table.unpack(requestResults)
	end
	
	task.defer(function()
		if yieldConnection.Connected then
			yieldConnection:Disconnect()
			task.spawn(currentThread, nil)
		end
	end)
	
	isYielded = true
	return coroutine.yield()
end

function remoteFunction.InvokeServer(remoteMock: TypeLibrary.REMOTE_FUNCTION_MOCK, ...)
	return AwaitRequest(
		remoteMock._Props.Emulator.ServerContext,
		remoteMock._Listeners.ServerRequest,
		...)
end

function remoteFunction.InvokeClient(remoteMock: TypeLibrary.REMOTE_FUNCTION_MOCK, player, ...)
	assert(player:IsDescendantOf(PlayerService), "InvokeClient: player argument must be a Player object")
	
	return AwaitRequest(
		remoteMock._Props.Emulator.ClientContext,
		remoteMock._Listeners.ClientRequest,
		player,
		...)
end

return remoteFunction
