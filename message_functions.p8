pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function update_message()
    if (timeouts["typing"]==0) and msg_l<#msg then
        timeouts["typing"]=2
        sfx(23)
        msg_l+=8
    end
    if (btnp(❎)) mode="play"
end

function draw_message()
    camera()
    local ox, oy = 10, 10
    local msg_c, msg_r = 1, 1
    local tmp=sub(msg,1,msg_l)
    rectfill(4,4,123,123,0)

    for i=1, #tmp do
        local char=sub(tmp,i,i)
        if char == "/" then
            msg_c=1
            msg_r+=8
        else
            print(char,msg_c+ox,msg_r+oy,11)
            msg_c+=4
        end
    end

    if (msg_l >= #msg) then
        print("❎ ok",ox,108,printcycle("blink_ok"))
    end
end