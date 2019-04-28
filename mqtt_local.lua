function onError(client, reason)
    print("MQTT connection problem: "..reason)
end

function onConnect(client)
    mqttOnConClb(client)

    print("MQTT closed: "..tostring(client:close()))
end

function dnsResolveClb(sk, ip)
    if ip~=nil then
        local client=mqtt.Client(wifi.sta.gethostname(),60)
        print("MQTT connecting to: "..ip.." result="..tostring(
            client:connect(ip, onConnect, onError)))
    else
        print("DNS could not resolve broker")
    end
end

function connectToBroker(onConClb)
    mqttOnConClb=onConClb
    net.dns.resolve("raspberrypi", dnsResolveClb)
end
