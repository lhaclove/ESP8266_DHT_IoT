function onError(client, reason)
    print("mqtt: connection problem: "..reason)
end

function onConnect(client)
    mqttOnConClb(client)

    print("mqtt: closed connection: "..tostring(client:close()))
end

function dnsResolveClb(sk, ip)
    if ip~=nil then
        local client=mqtt.Client(wifi.sta.gethostname(),60)
        print("mqtt: connecting to: "..ip.." result="..tostring(
            client:connect(ip, onConnect, onError)))
    else
        print("mqtt: DNS could not resolve broker")
    end
end

function connectToBroker(onConClb)
    mqttOnConClb=onConClb
    net.dns.resolve("raspberrypi", dnsResolveClb)
end
