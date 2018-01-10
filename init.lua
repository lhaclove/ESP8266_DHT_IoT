function doInit()
    local timeout=15
    tmr.alarm(0, timeout*1000, tmr.ALARM_SINGLE, function()
        local sec=30
        print("going to deepsleep for "..sec.." seconds")
        node.dsleep(sec*1000*1000)
    end)
    
    dofile("wifi.lua")

    dofile("dht.lua")
    local temp,humi=readDHT()

    dofile("publisher.lua")
    writeToFile(temp,humi)
        
    checkAndConnect(function(T)
        --dofile("mqtt_cayenne.lua")
        dofile("mqtt_local.lua")
        connectToBroker(publish)
    end)
end

local waitTime=3
print(waitTime.."secs before init. stop timer 0 to prevent.")
tmr.alarm(0, waitTime*1000, tmr.ALARM_SINGLE, doInit)
