pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function update_ugene()
    --apply friction and keep in bounds
    if (ugene.dx<0) ugene.dx+=friction
    if (ugene.dx>0) ugene.dx-=friction
    ugene.dx=mid(-accel_max,ugene.dx,accel_max)

    -- buoyancy
    if btn(⬆️) then
        ugene.y-=1
        burnfuel(.02)
    end
    if btn(⬇️) then
        ugene.y+=1
        burnfuel(.01)
    end
    ugene.y=mid(min_y,ugene.y,max_y-ugene.h)
    
    -- accelerate right
    if btn(➡️) then
        if ugene.left then
            ugene.left=false
            ugene.aim="right"
        end
        ugene.dx+=accel
        burnfuel(.03)
    end
    -- accelerate left
    if btn(⬅️) then
        if not(ugene.left) then
            ugene.left=true
            ugene.aim="left"
        end
        ugene.dx-=accel
        burnfuel(.03)
    end
    
    -- fire nerfgun
    if btnp(❎) and ugene.weapon and ugene.weapon.id=="nerfgun" then
        timeouts["shooting"]=5
        if nerf>0 then
            sfx(2)
            createbullet()
            nerf-=1
            if nerf==12 then
                dialog="running low on ammo!"
            end
            if nerf==1 then
                dialog="this is my/last nerf!"
            end
        else
            dialog="need to find/more ammo!"
            --timeouts["flashammo"]=30
            sfx(7)
        end
    end

    -- fire lasergun
    if btnp(❎) and ugene.weapon and ugene.weapon.id=="lasergun" then
        if power>0 then
            sfx(21)
            createlaser()
            power=mid(0,power-2,99)
        end
        if power<10 then
            dialog="low on power!"
        end
        if power<=0 then
            dialog="out of juice!"
            sfx(26)
        end
    end
    
    --fire squirtgun
    if btnp(❎) and ugene.weapon and ugene.weapon.id=="squirtgun" then
        if h2o>0 then
            sfx(13)
            for i=1,rnd(20) do
                createstream(i)
            end
            h2o-=1
        else
            dialog="out of water!"
            --timeouts["flashammo"]=30
            sfx(7)
        end
    end

    --put down
    if btnp(🅾️) and ugene.weapon then
        dialog="who needs that /"..ugene.weapon.n.." anyway."
        putdownweapon()
    end

    --wrap ugene
    if (ugene.x<0) ugene.x=map_w
    if (ugene.x>map_w) ugene.x=0

    --move horizontally
    ugene.x+=ugene.dx
end

function drawugene()
    local sprite,drip_ox
    --debug_hitbox(ugene)
    foreach(smoke,drawsmoke)

	if (timeouts["ugenewhite"]>0) setspritecolor(8)
    if (timeouts["shooting"]>0) then
        sprite=4
    else
        sprite=ugene.sprite[ugene.action][1]
    end
	spr(sprite,ugene.x,ugene.y,ugene.sprite[ugene.action][2],3,ugene.left) 
    pal()

    if timeouts["dripping"]==0 and not(ugene.left) then
        addpart(ugene.x+2,ugene.y+10,0,1,1,7,16)
		timeouts["dripping"]=flr(rnd(500))
	end
	
	--shadow
	spr(54,ugene.x+4,max_y+3,2,1,ugene.left)

    -- dialog
	if (not(dialog=="")) say(dialog,ugene.x+12,ugene.y,500,false)
end