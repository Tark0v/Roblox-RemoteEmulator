local module = {}
local registry = {}

function module.RegisterContainer(containerID: string)
	assert(registry[containerID] == nil, `{containerID} already exists`)
	registry[containerID] = {}
end

function module.GetFromRegistry(containerID: string, itemID: string): any
	local validRegistry = assert(registry[containerID], `{containerID} Does not exists`)
	return validRegistry[itemID]
end

function module.AddToRegistry<T>(containerID: string, itemID: string, item: T): T
	local validRegistry = assert(registry[containerID], `{containerID} Does not exists`)
	assert(validRegistry[itemID] == nil, `{itemID} already exists`)
	
	validRegistry[itemID] = item
	
	return item
end

function module.RemoveFromRegistry(containerID: string, itemID: string)
	local validRegistry = assert(registry[containerID], `{containerID} Does not exists`)
	validRegistry[itemID] = nil
end

return module
