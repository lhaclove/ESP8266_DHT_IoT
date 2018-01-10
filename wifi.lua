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
    end
    
    local station_cfg={}
    station_cfg.ssid=w.ssid
    station_cfg.pwd=w.pass
    station_cfg.auto=true
    station_cfg.save=false
    
    wifi.setmode(wifi.STATION)
    wifi.setphymode(wifi.PHYMODE_G)
    
    wifi.sta.clearconfig()

    wifi.sta.config(station_cfg)
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
        local cfg={}
        cfg.ssid=nil
        cfg.channel=0
        cfg.show_hidden=1
        cfg.bssid=apList[index].mac
    
        wifi.sta.getap(cfg,1,getAPClbk)
        
        tmr.alarm(1, 2500, tmr.ALARM_SINGLE, function()
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
