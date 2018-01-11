function writeToFile(temp,humi)
    if temp and humi then
        local log=file.open(globalFilename,"a")
        if log then
            local content=temp..";"..humi
    
            print("writing '"..content.."' to "..globalFilename)
            
            log:writeline(content)
            log:close()
        else
            print("problem writing "..globalFilename)
        end
    end
end

function onPublishRcvd(client)
    print("publish received")
end

function getPayload(temp,humi)
    local payload='{"t":'..tostring(temp)..
    ',"h":'..tostring(humi)..'}'

    print("paylod: "..payload)
    
    return payload
end

function parseLog(itemList)
    local count=0;
    local log=file.open(globalFilename,"r")
    
    if log then
        local line=log:readline()
        while line do
            line=line:gsub("\n","")
            print("read "..line)

            local delPos=line:find(";")
            local temp=line:sub(0,delPos-1);
            local humi=line:sub(delPos+1)

            count=count+1
            
            local reading={}
            reading.t=temp
            reading.h=humi
            
            itemList[count]=reading
            
            line=log:readline()
        end
    
        log:close()
        file.remove(globalFilename)
    else
        print("problem reading "..globalFilename)
    end

    print("read "..count.." entries from log")
    return count
end

function publish(mqttClient)
    local topic=wifi.sta.getmac()
    topic=string.gsub(topic,":","")

    local itemList={}
    local count=parseLog(itemList)

    if global.t and global.h then
        local reading={}
        
        reading.t=global.t
        reading.h=global.h
        itemList[count+1]=reading

        global.t=nil
        global.h=nil
    end

    for i,reading in ipairs(itemList) do
        local payload=getPayload(reading.t,reading.h)
        
        print("publishing to: "..topic.." payload: "..payload)
        mqttClient:publish(topic,payload,0,0,onPublishRcvd)
    end
end

globalFilename="log.txt"
