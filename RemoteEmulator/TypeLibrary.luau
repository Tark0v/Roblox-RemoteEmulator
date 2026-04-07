local packages = script.Parent.Packages

local Janitor = require(packages.Janitor)
local Signal = require(packages.Signal)

export type RUN_TIME_CONTEXT = "SERVER" | "CLIENT"
export type REMOTE_TYPE = "RemoteEvent" | "RemoteFunction"

export type EMULATOR_MOCK = {
	RemoteID: string,
	RemoteType: REMOTE_TYPE,
	ClientContext: Signal.Signal<any>,
	ServerContext: Signal.Signal<any>,
	Janitor: Janitor.janitorClass,	
}

export type REMOTE_PROPS = {
	Emulator: EMULATOR_MOCK,
	RemoteID: string,
	RemoteType: REMOTE_TYPE,
}

export type InstanceMethods = {
	Destroy: (self: any)->nil,
	IsA: (self: any, class: string)->boolean,
}

export type Remote_Base = {
	_Props: REMOTE_PROPS
}

export type REMOTE_EVENT_MOCK = Remote_Base & InstanceMethods & {
	OnServerEvent: Signal.Signal<any>,
	OnClientEvent: Signal.Signal<any>,
	FireServer: (remoteMock: REMOTE_EVENT_MOCK, ...any) -> (),
	FireClient: (remoteMock: REMOTE_EVENT_MOCK, player: Player, ...any) -> (),
	FireAllClients: (remoteMock: REMOTE_EVENT_MOCK, ...any) -> (),
}

export type REMOTE_FUNCTION_MOCK = Remote_Base & InstanceMethods & {
	OnServerInvoke: nil,
	OnClientInvoke: nil,
	InvokeServer: (RemoteMock: REMOTE_FUNCTION_MOCK, ...any)->...any,
	InvokeClient: (RemoteMock: REMOTE_FUNCTION_MOCK, player: Player, ...any)->...any,
	
}

return 1