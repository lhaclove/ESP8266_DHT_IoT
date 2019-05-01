function writeToFile(temp,humi)
    if temp and humi then
        local log=file.open(globalFilename,"a")
        if log then
            local content=temp..";"..humi
    
            print("publisher: writing '"..content.."' to "..globalFilename)
            
            log:writeline(content)
            log:close()
        else
            print("publisher: problem writing "..globalFilename)
        end
    end
end

function onPublishRcvd(client)
    print("publisher: publish received")
end

function getPayload(temp,humi)
    local payload='{"t":'..tostring(temp)..
    ',"h":'..tostring(humi)..'}'

    print("publisher: paylod: "..payload)
    
    return payload
end

function parseLog(mqttClient,topic)
    local count=0;
    local log=file.open(globalFilename,"r")
    
    if log then
        local line=log:readline()
        while line do
            line=line:gsub("\n","")
            print("publisher: read line "..count.." -> "..line)

            count=count+1
            
            local delPos=line:find(";")
            local temp=line:sub(0,delPos-1)
            local humi=line:sub(delPos+1)
            local payload=getPayload(temp,humi)

            publish(mqttClient,topic,payload)
            
            line=log:readline()
        end
    
        log:close()
        file.remove(globalFilename)
    else
        print("publisher: problem reading "..globalFilename)
    end

    print("publisher: read "..count.." entries from log")
    return count
end

function publish(mqttClient,topic,payload)
    print("publisher: publishing payload: "..payload.." to "..topic)
    mqttClient:publish(topic,payload,0,0,onPublishRcvd)
end

function sendValues(mqttClient)
    local topic=wifi.sta.getmac()
    topic=string.gsub(topic,":","")

    if file.exists(globalFilename) then
        parseLog(mqttClient,topic)
    end

    if global.t and global.h then
        local payload=getPayload(global.t,global.h)

        publish(mqttClient,topic,payload)

        global.t=nil
        global.h=nil
    end
end

globalFilename="log.txt"
