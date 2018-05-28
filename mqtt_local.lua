function onConnect(client)
    print("connected callback")

    mqttOnConClb(client)

    print("closed: "..tostring(client:close()))
end

function onError(client, reason)
    print("connection problem: "..reason)
end

function connectToBroker(onConClb)

    local server="192.168.178.36"
    local client=mqtt.Client(wifi.sta.gethostname(),60)
    mqttOnConClb=onConClb

    print("connected: "..tostring(
        client:connect(server,onConnect,onError)))
end
