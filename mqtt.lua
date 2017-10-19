clientID=""
username=""

global_temp=nil
global_humi=nil

function onPublishRcvd(client)
    print("publish received")
end

function onConnect(client, topic, message)
    print("connected callback")

    do
        local channel="0"
        local topic="v1/"..username.."/things/"..clientID.."/data/"..channel
        local payload="temp,c="..tostring(global_temp)
        
        print("publishing to:"..topic.." payload: "..payload)
        client:publish(topic,payload,0,0,onPublishRcvd)

        channel="1"
        topic="v1/"..username.."/things/"..clientID.."/data/"..channel
        payload="rel_hum,p="..tostring(global_humi)
        print("publishing to:"..topic.." payload: "..payload)
        client:publish(topic,payload,0,0,onPublishRcvd)
    end
end

function onConnectFailed(client, reason)
    print("failed to connect due to: "..reason)
end

function publishMQTT(temp,humi)

global_temp=temp
global_humi=humi

    local password=""
    local server="mqtt.mydevices.com"
    
    local client=mqtt.Client(clientID,60,username,password)

    client:on("connect", onConnect)
    print("connected: "..tostring(client:connect(server)))

    print("closed: "..tostring(client:close()))
end
