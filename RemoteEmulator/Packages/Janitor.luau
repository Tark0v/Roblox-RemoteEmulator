local janitorService = {}
local janitorMethods = {}
janitorService.__index = janitorMethods

function janitorService.New()
    return setmetatable({Collectables = {}, identityMap = {}}, janitorService)
end

export type janitorClass = typeof(janitorService.New())

function janitorMethods.AddObject<Object>(self: janitorClass, object: Object, identifier: string?): Object
	if identifier then
		if self.identityMap[identifier] then
			self:Clean(self.identityMap[identifier])
		end

		self.identityMap[identifier] = object
	end

	self.Collectables[identifier or object] = true
    return object
end

function janitorMethods.CleanObject<Object>(self: janitorClass, object: Object): janitorClass
	if not object then
		return
	end

	local isIdentityMapped = self.identityMap[object]
	local realObject = isIdentityMapped or object

	if typeof(realObject) == "function" then
        task.spawn(realObject)
    elseif typeof(realObject) == "thread" then
        task.cancel(realObject)
    elseif typeof(realObject) == "Instance" then
        if realObject:IsA("AnimationTrack") then
            realObject:Stop()
        end

        realObject:Destroy()
    elseif typeof(realObject) == "RBXScriptConnection" then
        realObject:Disconnect()
    elseif typeof(realObject) == "TweenBase" then
        realObject:Cancel()
    elseif typeof(realObject) == "table" then
        if realObject.Destroy then
            realObject:Destroy()
        elseif realObject.Stop then
            realObject:Stop()
        elseif realObject.Cancel then
            realObject:Cancel()
        end
    end

   	self.identityMap[object] = nil
    self.Collectables[isIdentityMapped or object] = nil

    return janitorService
end

function janitorMethods.Clean(self: janitorClass): janitorClass
    for object, _ in self.Collectables do
        self:CleanObject(object)
    end

    table.clear(self.Collectables)

    return self
end

return janitorService
