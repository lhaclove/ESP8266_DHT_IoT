function writeToFile(temp,humi)
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

function onPublishRcvd(client)
    print("publish received")
end

function publish(mqttClient)
    local log=file.open(globalFilename,"r")
    if log then
        local topic=wifi.sta.getmac()
        topic=string.gsub(topic,":","")
                
        local line=log:readline()
        while line do
            line=line:gsub("\n","")
            print("read '"..line.."'")

            local delPos=line:find(";")
            local temp=line:sub(0,delPos-1);
            local humi=line:sub(delPos+1)
            
            local payload='{"t":'..tostring(temp)..',"h":'..tostring(humi)..'}'
            
            print("publishing to: "..topic.." payload: "..payload)
            mqttClient:publish(topic,payload,0,0,onPublishRcvd)
            
            line=log:readline()
        end
    
        log:close()
        file.remove(globalFilename)
    else
        print("problem reading "..globalFilename)
    end
end

globalFilename="log.txt"