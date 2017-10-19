function connectWifi(onConnectClb,w)
    do
        local defOnGotIP=function(T)
            print("got IP: " .. T.IP .. 
            " subnet: " .. T.netmask ..
            " gateway: " .. T.gateway)
        end
        
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
        function(T)
            defOnGotIP(T)
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

function getAPClbk(list)
    for bssid,v in pairs(list) do

        local rssi=0;
        for val in string.gmatch(v,"-%d+") do
            rssi=tonumber(val)
        end

        if bssid==fritz.mac then
            fritz.found=true
            fritz.rssi=rssi
            print("fritz found")
        elseif bssid==raspi.mac then
            raspi.found=true
            raspi.rssi=rssi
            print("raspi found")
        end
    end
end

fritz={}
fritz.mac=""
fritz.found=false
fritz.rssi=0
fritz.ssid=""
fritz.pass=""

raspi={}
raspi.mac=""
raspi.found=false
raspi.rssi=0
raspi.ssid=""
raspi.pass=""
    
function checkAPs()
    print("checking APs")
    
    local cfg={}
    cfg.ssid=nil
    cfg.channel=0
    cfg.show_hidden=1

    cfg.bssid=fritz.mac
    wifi.sta.getap(cfg,1, getAPClbk)

    tmr.alarm(1, 2*1000, tmr.ALARM_SINGLE,function()
        cfg.bssid=raspi.mac
        wifi.sta.getap(cfg,1, getAPClbk)
    end)
end

function checkAndConnect(onConnectClb)
    checkAPs()

    tmr.alarm(1, 5*1000, tmr.ALARM_SINGLE,function()
        local w
        
        if fritz.found and raspi.found then
            if fritz.rssi<raspi.rssi then
                w=raspi
            else
                w=fritz
            end
        elseif not fritz.found then
            w=raspi
        elseif not raspi.found then
            w=fritz
        end
        
        connectWifi(onConnectClb,w)
    end)
end