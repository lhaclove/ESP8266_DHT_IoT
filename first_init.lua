function deepSleep()
    if deepSleepEnabled then
        print("going to sleep for " .. sleepTime .. "secs")
        node.dsleep(1000000 * sleepTime)
    end
end

function httpCallback(code, data)
    print("HTTP code: " .. tostring(code) .. " result: " .. tostring(data))
end

function publish(values, count)
    --local url = "http://dweet.io/dweet/for/" .. node.chipid() .. "?tmp=" .. temp .. "&hum=" .. hum
    --print("publishing: " .. url)
    --http.get(url, nil, httpCallback)

    if (count > 0) then
        local temp, hum = unpack(values[count])        
        local url = "http://data.sparkfun.com/input/" .. phantPublicKey .. "?private_key=" .. phantPrivateKey .. "&humidity=" .. hum .. "&temperature=" .. temp
        values[count] = nil
        print("publishing: " .. url)
        http.get(url, nil,
            function (code, data)
                httpCallback(code, data)
                node.task.post(
                    function ()
                        publish(values, count - 1)
                    end
                )
            end
        )        
    else
        deepSleep()
    end
end

function writeToFile(temp, hum)
    print("writing to file " .. measurementsFile)
    
    if file.open(measurementsFile, "a+") then
        local data=temp .. "#" .. hum
        print("wrote: " .. data)
        file.writeline(data)
        file.close()
    else
        print("problem opening file")
    end
end

function readDHT()
    print("reading DHT22")
    local stat, temp, hum=dht.read(dhtPin)
    
    if (stat==dht.OK) then
        print(temp .. "°C " .. hum .. "%")
        return temp, hum
    else
        print("problem with DHT")
        return -1, -1
    end
end

function readMeasurements()
    local count = 0
    local result = {}
    
    if file.open(measurementsFile,"r") then
        print("opened file " .. measurementsFile)
        local line = file.readline()
        
        while (line ~= nil) do
            line = string.gsub(line, "\n", "")
            local del = string.find(line,"#")
            local temp = string.sub(line, 0, del - 1)
            local hum = string.sub(line, del + 1)
            result[count + 1] = {temp, hum}
            count = count + 1
            line = file.readline()
        end
        
        file.close()
        file.remove(measurementsFile)
    else
        print("problem opening " .. measurementsFile)
    end
    
    return count, result
end

function doWork(hasIP)
    local temp, hum = readDHT()

--force file write
--hasIP=false
    
    if (hasIP == false) then
        writeToFile(temp, hum)
        deepSleep()
    else
        local count = 0
        local values = {}
        
        if file.exists(measurementsFile) then
            count, values = readMeasurements()
        end
        
        values[count + 1] = {temp, hum}
        count = count + 1
        publish(values, count)
    end
end

function connectWIFI()
    print("connecting to WIFI")
    print("SSID is " .. ssid .. " password is " .. pass)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, pass)
    
    local wifiTries=0
    tmr.alarm(0, 1000, tmr.ALARM_AUTO,
        function()
            if (wifi.sta.getip() == nil) then
                wifiTries = wifiTries + 1
                print("waiting for " .. wifiTries .. "secs now")
                if (wifiTries >= wifiMaxTries) then
                    tmr.stop(0)
                    print("couldn't get IP, writing to file")
                    doWork(false)
                end
            else
                tmr.stop(0)
                print("got IP: " .. wifi.sta.getip())
                doWork(true)
            end
        end
    )
end

ssid = ""
pass = "@freenet.de"
initialWait = 3
sleepTime = 10 * 60
dhtPin = 6
deepSleepEnabled = true
wifiMaxTries = 30
measurementsFile = "measurements.txt"
phantPrivateKey = ""
phantPublicKey = ""
resetTime = 3 * 60

print("stop timer 0 to stop init.lua")
print("set deepSleepEnabled=false to prevent deep sleep")
print("reset time for last resort timer (1) is: " .. resetTime .. "secs")
print("deepsleep time is: " .. sleepTime .. "secs")
print("DHT22 pin is: " .. dhtPin)
print("WIFI will wait " .. wifiMaxTries .. "secs for an IP")
print("offline data file name is: " .. measurementsFile)
print("you have " .. initialWait .. "sec from now")
tmr.alarm(0, 1000 * initialWait, tmr.ALARM_SINGLE, connectWIFI)
tmr.alarm(1, 1000 * resetTime, tmr.ALARM_SINGLE,
    function ()
        node.reset()
    end
)
