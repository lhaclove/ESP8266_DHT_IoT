function doInit()
    dofile("publisher.lua")
    
    local timeout=15
    tmr.alarm(0, timeout*1000, tmr.ALARM_SINGLE, function()
        if global.t and global.h then
            writeToFile(global.t, global.h)
        end
        
        local dsleepSec=30
        print("going to deepsleep for "..dsleepSec.." seconds")
        node.dsleep(dsleepSec*1000*1000)
    end)
    
    dofile("wifi.lua")

    dofile("dht.lua")
    global.t, global.h=readDHT()
        
    checkAndConnect(function(T)
        --dofile("mqtt_cayenne.lua")
        dofile("mqtt_local.lua")
        connectToBroker(sendValues)
    end)
end

global={}
global.t=nil
global.h=nil

local waitTime=3
print(waitTime.."secs before init. stop timer 0 to prevent.")
tmr.alarm(0, waitTime*1000, tmr.ALARM_SINGLE, doInit)
