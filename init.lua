function doInit()
    dofile("publisher.lua")
    
    local timeoutSec=15
    local timeoutTimer = tmr.create()
    timeoutTimer:alarm(timeoutSec*1000, tmr.ALARM_SINGLE, function()
        if global.t and global.h then
            writeToFile(global.t, global.h)
        end
        
        local dsleepSec=600
        print("going to deepsleep for "..dsleepSec.." seconds")
        node.dsleep(dsleepSec*1000*1000)
    end)
    
    dofile("wifi.lua")

    dofile("dht.lua")
    global.t, global.h=readDHT()
        
    checkAndConnect(function(T)
        dofile("mqtt.lua")
        connectToBroker(sendValues)
    end)
end

global={}
global.t=nil
global.h=nil

local waitTimeSec=3
print(waitTimeSec .. " secs before init. call initTimer:unregister() to prevent.")

initTimer = tmr.create()
initTimer:alarm(waitTimeSec*1000, tmr.ALARM_SINGLE, doInit)
