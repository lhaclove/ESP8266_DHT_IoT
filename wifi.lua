function connectWifi(onConnectClb,w)
    do
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
        function(T)
            print("got IP: " .. T.IP .. 
            " subnet: " .. T.netmask ..
            " gateway: " .. T.gateway ..
            " dns: " .. net.dns.getdnsserver(0))
            onConnectClb(T)
        end)

        wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,
        function(T)
            print("connected to: " .. T.SSID .. 
            " on channel: " .. T.channel)
        end)

        wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,
        function(T)
            print("disconnected from: " .. T.SSID .. 
            " reason: " .. T.reason)
            if T.reason == wifi.eventmon.reason.NO_AP_FOUND then
                print("Access Point not found, disconnecting...")
                wifi.sta.disconnect()
            end
        end)        
    end
    
    wifi.setmode(wifi.STATION, false)
    wifi.setphymode(wifi.PHYMODE_G)

    local countryCfg={
        country="DE",
        start_ch=1,
        end_ch=13,
        policy=wifi.COUNTRY_MANUAL}
    wifi.setcountry(countryCfg)
    
    wifi.sta.clearconfig()

    local staCfg={
        ssid=w.ssid,
        pwd=w.pass,
        auto=true,
        save=false
    }    
    wifi.sta.config(staCfg)
end

function getBestAP()
    local bestIndex=0
    local bestRSSI=0
    
    for i,v in ipairs(apList) do
        if i==1 then
            bestRSSI=v.rssi
        end
        if v.found==true then
            if v.rssi>=bestRSSI then
                bestRSSI=v.rssi
                bestIndex=i
            end
        end
    end

    if bestIndex~=0 then
        print(apList[bestIndex].name .. " is strongest")
        connectWifi(globalOnConnectClb,apList[bestIndex])
    else
        print("no AP in reach")
    end
end

function getAPClbk(list)
    for bssid,v in pairs(list) do
        local rssi=0;
        for val in string.gmatch(v,"-%d+") do
            rssi=tonumber(val)
        end

        for i,v in ipairs(apList) do
            if bssid==v.mac then
                v.found=true
                v.rssi=rssi
                print("found: "..v.name)
            end
        end
    end
end
    
function checkAPs(index)
    if index==nil then
        index=1
    end

    if apList[index]~=nil then
        local cfg={
            ssid=nil,
            channel=0,
            show_hidden=1,
            bssid=apList[index].mac}
        
        wifi.setmode(wifi.STATION, false)
        wifi.sta.getap(cfg,1,getAPClbk)

        local checkTimer = tmr.create() 
        checkTimer:alarm(2500, tmr.ALARM_SINGLE, function()
            checkAPs(index+1)
        end)
    else
        getBestAP()
    end
end

function checkAndConnect(onConnectClb)
    dofile("wifi_ap_list.lua")
    globalOnConnectClb=onConnectClb
    checkAPs()
end
