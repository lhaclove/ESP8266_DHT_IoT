function readDHT()
    local pin=6
    local status,temp,humi,temp_dec, humi_dec

    print("dht: reading DHT on pin "..pin)
    status, temp, humi, temp_dec, humi_dec=dht.read(pin)

    if status==dht.OK then
        print("dht: temp = "..temp.." humi = "..humi)
    else
        print("dht: can't read DHT sensor. status: "..status)
        temp=nil
        humi=nil
    end

    if humi and humi > 100 then
        humi=nil
    end
    
    return temp,humi
end
