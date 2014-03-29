--[[

  Improve logging to stdout: add timestamp, track connects/renames/disconnects better, map changes.

]]--

local L = require"utils.lambda".L

spaghetti.addhook("log", function(info) info.s = os.date("%c | ") .. info.s end)

spaghetti.addhook("log", function(info)
  if info.s:match"^client connected" or info.s:match"^client [^ ]+ disconnected" or info.s:match"^disconnected client" then info.skip = true return end
end, true)

local ip = require"utils.ip"
local function conninfo(client)
  local name, cn= "", client
  if type(client) ~= 'number' then name, cn = client.name, client.clientnum end
  local peer = engine.getclientpeer(cn)
  return string.format('%s(%d) %s:%d:%d', name, cn, tostring(ip.ip(engine.ENET_NET_TO_HOST_32(peer.address.host))), peer.address.port, peer.incomingPeerID)
end
spaghetti.addhook("clientconnect", function(info)
  engine.writelog("connect: " .. conninfo(info.ci))
end)
spaghetti.addhook("connected", function(info)
  engine.writelog("join: " .. conninfo(info.ci))
end)
spaghetti.addhook(server.N_SWITCHNAME, function(info)
  if info.skip then return end
  engine.writelog(string.format('rename: %s -> %s(%d)', conninfo(info.ci), engine.filtertext(info.text):sub(1, server.MAXNAMELEN):gsub("^$", "unnamed"), info.ci.clientnum))
end)
spaghetti.addhook("clientdisconnect", function(info)
  engine.writelog(string.format("disconnecting: %s %s", conninfo(info.ci), engine.disconnectreason(info.reason) or "none"))
end)
spaghetti.addhook("enetevent", function(info)
  if info.skip or info.event.type ~= engine.ENET_EVENT_TYPE_DISCONNECT then return end
  if info.ci then engine.writelog("disconnected: " .. conninfo(info.ci))
  else
    local peer = info.event.peer
    engine.writelog(string.format('disconnected: %s:%d:%d', tostring(ip.ip(engine.ENET_NET_TO_HOST_32(peer.address.host))), peer.address.port, peer.incomingPeerID))
  end
end)

spaghetti.addhook("changemap", L"engine.writelog(string.format('new %s on %s', server.modename(_.mode, '?'), _.map))")