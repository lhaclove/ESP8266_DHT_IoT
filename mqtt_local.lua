function onPublishRcvd(client)
    print("publish received")
end

function onConnect(client)
    print("connected callback")

    do
        local topic=wifi.sta.getmac()
        local payload='{"t":'..tostring(global_temp)..',"h":'..tostring(global_humi)..'}'
        
        print("publishing to:"..topic.." payload: "..payload)
        client:publish(topic,payload,0,0,onPublishRcvd)
    end

    print("closed: "..tostring(client:close()))
end

function onError(client, reason)
    print("connection problem: "..reason)
end

function publishMQTT(temp,humi)

global_temp=temp
global_humi=humi

    local server="192.168.178.36"
    
    local client=mqtt.Client(0,60)

    print("connected: "..tostring(
        client:connect(server,onConnect,onError)))
end

local global_temp=-1
local global_humi=-1