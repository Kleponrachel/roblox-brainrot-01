-- Brainrot Big Top: every RemoteEvent the client and server use, built
-- once here so no script invents its own channel. The client fires the
-- Request* events; the server answers on the Update* events.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local function makeRemote(name)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = ReplicatedStorage
	Remotes[name] = remote
	return remote
end

-- Client asks the server to do something.
makeRemote("RequestBuy")
makeRemote("RequestSteal")
makeRemote("RequestSlap")
makeRemote("RequestLockBase")
makeRemote("RequestRebirth")
makeRemote("RequestBuySlot")
makeRemote("RequestClaimContract")
makeRemote("RequestClaimDaily")
makeRemote("RequestDeliver")

-- Server tells one client (or all clients) something changed.
makeRemote("UpdateHud")
makeRemote("UpdateDex")
makeRemote("UpdateContracts")
makeRemote("ShowToast")
makeRemote("ShowBanner")
makeRemote("ShowOfflineEarnings")
makeRemote("UpdateLeaderboard")

return Remotes
