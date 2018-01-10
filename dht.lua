function readDHT()
    local pin=6
    local status,temp,humi,temp_dec, humi_dec

    print("reading DHT on pin "..pin)
    status, temp, humi, temp_dec, humi_dec=dht.read(pin)

    if status==dht.OK then
        print("temp = "..temp)
        print("humi = "..humi)
    else
        print("can't read DHT sensor. status: "..status)
        temp=nil
        humi=nil
    end

    if humi and humi > 100 then
        humi=nil
    end
    
    return temp,humi
end
