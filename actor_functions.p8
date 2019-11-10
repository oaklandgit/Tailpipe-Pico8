pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- flies!
function spawn_flies()
    if totalflies<gen[level].flies then
        if timeouts["spawnright"]==0 then
            createfly("right")
            timeouts["spawnright"]=flyspawnspeed
            totalflies+=1
        end
        if timeouts["spawnleft"]==0 then
            createfly("left")
            timeouts["spawnleft"]=flyspawnspeed
            totalflies+=1
        end
    end
end

function createfly(dir)
    local f={}
    f.w=8
    f.h=5
	if dir=="right" then
	    f.x=cam_x+300+rnd(100)
		f.dx=rndminmax(.75,1.25)
		f.left=true
	else
		f.x=cam_x-rnd(100)
		f.dx=-rndminmax(.75,1.25)
		f.left=false
	end
    f.y=rnd(wall_h)
	f.value=1
    f.hilite=false
	add(flies,f)
end

function updatefly(f)
    f.x-=f.dx
    if (f.x<0) f.x+=map_w
    if (f.x>map_w) f.x-=map_w
    if (timeouts["collisions"]<=0) f.hilite=false
    collide(f)
end

function drawfly(f)
    draw_thrice(printcycle("fly"),f.x,f.y,1,1,f.left)
    -- --debug_hitbox(f)
end

function killfly(x,y)
    score+=1
    killedflies+=1
    sfx(9)
    for i=0, 10 do
        local ang=rnd()
        local dx=sin(ang)*1
        local dy=cos(ang)*1
		
		if ugene.left then
            dx-=1
		else
			dx+=1
		end
		addpart(x,y,dx,dy,rnd(2),1,rnd(16))
	end
end

function updatedrone(d)

    if (d.active) then
        if d.left then d.x-=d.dx else d.x+=d.dx end
        if (d.x<0) d.x=map_w
        if (d.x>map_w) d.x=0
        if (rnd(400) < 1) d.left=not(d.left) --rnd dir change

        --randomly shoot at ugene
        --if it wasn't just hit, and is onscreen
        if (d.meterdelay==0) and (rnd(200)<1) and onscreen(d) then
            attack(d.x+8,d.y+4,ugene.x+8,ugene.y+8)
            sfx(21)
        end
        --check for collisions against fellow drones
        for i,d2 in pairs(drones) do
            if not(d==d2) and box_hit(d,d2) then
                if(d.x > d2.x) then 
                    d.left=false
                    d2.left=true
                else
                    d.left=true
                    d2.left=false
                end
            end
        end
        if(d.meterdelay>0) d.meterdelay-=1
    else
        if (onscreen(ugene) and onscreen(d)) d.active=true
    end
end

function drawdrone(d)
    drawdrone_copy(d,0)
    drawdrone_copy(d,map_w)
    drawdrone_copy(d,-map_w)    
end

function drawdrone_copy(d,pos)
    --just got hit
    if (d.meterdelay > 0) then
        --show health meter
        rectfill(pos+d.x,d.y-12,pos+d.x+16,d.y-8,0)
	    line(pos+d.x+2,d.y-10,pos+d.x+2+(flr(14*(d.health/100))),d.y-10,11)
        --make all red
        setspritecolor(8)
    end

    --drone
    spr(187,d.x+pos,d.y,2,1)
    --aimed eye
    local ang = atan2(ugene.x-d.x,ugene.y-d.y)
    local ox=flr(5*cos(ang)+7)
    line(d.x+ox-1+pos,d.y+3,d.x+ox+3+pos,d.y+3,8)
    --antenna
    line(d.x+1+pos,d.y,d.x+1+pos,d.y-4,7)
    pset(d.x+1+pos,d.y-5,printcycle("drone_blink"))
    --shadow
    spr(54,d.x+pos,max_y+3,2,1)

    --reset color
    pal()

end

function killdrone(x,y)
    for i=0, 30 do
        local ang=rnd()
        local dx=sin(ang)*1
        local dy=cos(ang)*1
		if ugene.left then dx-=2 else dx+=2 end
		--addpart(x,y,dx,dy,rnd(2),7,rnd(16))
        addpart(x,y,dx,dy,nil,nil,rnd(20),{49,50,51},10)
	end
end

-- fruit
function updatefruit(f)
    for t in all(trees) do
        if t.countdown==0 and t.size<1 and box_hit(f,t) then
            t.magic=f.type
            t.countdown=magiclife
            del(fruits,f)
        end
    end

    if f.bounces>0 then
        f.dy+=f.gravity
        f.y+=f.dy

        if f.y > wall_h then
            f.dy=f.dy*f.bounce
            f.bounces-=1
            sfx(20)
        end
    else
        add(coins,{s=f.type+fruit_base_spr,x=f.x,y=f.y,w=8,h=8,left=f.left})
        del(fruits,f)
    end
end

function drawfruit(f)
    draw_thrice(f.type+fruit_base_spr,f.x,f.y,1,1,f.left)
end

function updatefountain(f)
    f.hilite=false
    if box_hit(ugene,f) then
        f.hilite=true
        if ugene.weapon and ugene.weapon.id=="squirtgun" then
            tooltip="❎ refill squirtgun"
            if btnp(❎) then
                h2o=h2o_max
                dialog="yesss!"
                sfx(14)
            end
        else
            tooltip="water fountain"
        end
        tooltipx=f.x+(f.w/2)
        tooltipy=f.y+20
    end
end

function drawfountain(f)
    if not(f.hilite) then
        draw_thrice(44,f.x,f.y,3,2)
    else
        shadowsprite(44,f.x,f.y,3,2,7)
    end
end

function updatephone(p)
    p.hilite=false
    if box_hit(ugene,p) then
        p.hilite=true
        tooltip="❎ read message"
        tooltipx=p.x+(p.w/2)
        tooltipy=p.y+12
        
        if (btnp(❎)) then
            msg_l=1
            msg=p.msg
            mode="message"
            p.read=true
        end
    end
end

function drawphone(p)
    local ox=0
    local oy=0
    if not(p.read) and printcycle("phone_shake") then
        ox=rnd(2)
        oy=rnd(2)
        if onscreen(p) then
            sfx(25)
        else
            sfx(24)
        end
    end
    if not(p.hilite) then
        draw_thrice(53,p.x+ox,p.y+oy,1,1)
    else
        shadowsprite(53,p.x,p.y,1,1,7)
    end
end

function updateoutlet(o)
    o.hilite=false
    if box_hit(ugene,o) then
        o.hilite=true
        if ugene.weapon and ugene.weapon.id=="lasergun" then
            tooltip="❎ recharge laser gun"
            if btnp(❎) then
                power=power_max
                dialog="yesss!"
                sfx(14)
            end
        else
            tooltip="power outlet"
            tooltipx=o.x-16
        end
        tooltipx=o.x-#tooltip
        tooltipy=o.y+20
    end
end

function drawoutlet(o)
    if not(o.hilite) then
        draw_thrice(241,o.x,o.y,1,1)
    else
        shadowsprite(241,o.x,o.y,1,1,7)
    end
end

-- trees
function updatetree(t)
    t.health=mid(0,t.health-.2,500) --degrow tree
    t.size=mid(0,flr(t.health/10),5) --which sprite, 1-5
    co2=mid(0,co2-.05*t.size,co2_max) --scrub co2

    if (t.countdown>0) then  --magic mode
        t.countdown-=1

        --reset as soon as it gets to zero
        if t.countdown==0 then
            t.health=0
            t.size=0
            t.magic=nil
            --reset the magic coins
            for c in all(t.coins) do
                c[3]=false
            end
        end

        --animate particles if magic tree
        local ang = rnd()
        local ox = sin(ang)*7
        local oy = cos(ang)*7
        addpart(t.x+8+ox,t.y+oy,ox*.05,oy*.05,1,7,rnd(20))
    else --not magic

        --touching cactus?
        if t.type==3
            and t.size==5
            and timeouts["collisions"]<=0
            and box_hit({x=ugene.x+8,y=ugene.y+8,w=8,h=8},{x=t.x,y=t.y-16,w=16,h=16})
        then
            sfx(5)
            dialog="ouchie!"
            jumpback(4)
            health-=cactuspenalty
            timeouts["ugenewhite"]=20
            timeouts["collisions"]=120
            t.hiliteplant=true
        end
    end

    --touching non-grown plant?
    if box_hit(ugene,t) then
        --if watermetip then
            t.hilite=true
            tooltip="water me"
            tooltipx=t.x+(t.w/2)
            tooltipy=t.y+20
        --end
    end
end

function drawtree(t)
    --shadow
    line(t.x+2,t.y+16,t.x+13,t.y+16,5)

    --magic content peeks from behind pot
    if t.countdown>0 then
        draw_thrice(t.magic+fruit_base_spr,t.x+4,t.y-4,1,1)
    end

    --pot
    if t.hilite then
        shadowsprite(174,t.x,t.y,2,2,7)
    else
        draw_thrice(174,t.x,t.y,2,2)
    end

    --plant
    if t.countdown==0 then --if it's not a magic fruit tree
        if t.size>0 then
            local sprite=tree_types[t.type][t.size][1]
            local spritew=tree_types[t.type][t.size][2]
            local spriteh=tree_types[t.type][t.size][3]
            local spriteoff=tree_types[t.type][t.size][4]

            if t.hiliteplant then
                shadowsprite(sprite,t.x+spriteoff,t.y-spriteh*8,spritew,spriteh,8)
            else
                draw_thrice(sprite,t.x+spriteoff,t.y-spriteh*8,spritew,spriteh)
            end
        end
    end

    t.hilite=false
    if (timeouts["collisions"]<=0) t.hiliteplant=false

end

--coins
function updatecoin(c)

    if box_hit(ugene,c) then

        -- collected ammo
        if c.s==52 and ugene.weapon and ugene.weapon.id=="nerfgun" then
            nerf+=1
            sfx(3)
            add(messages,{text="nerf ammo",x=c.x,y=c.y,age=40})
            del(coins,c)
        end

        --collected apple
        if  c.s==fruit_base_spr+6 then --apple is #6
            sfx(3)
            if (health<6) health+=1
            add(messages,{text="health +1",x=c.x,y=c.y,age=40})
            del(coins,c)
        end

        --all other fruit
        for i=1,5 do --all but the apple
            if c.s==i+fruit_base_spr then
                sfx(8)
                score+=10*i
                add(messages,{text=fruits_types[i].." +" ..10*i,x=c.x,y=c.y,age=40})
                del(coins,c)
            end
        end

    end
end

function drawcoin(c)
    --debug_hitbox(c)
    --shadow
    if (c.y>wall_h) then
        line(c.x,c.y+8,c.x+8,c.y+8,5)
        line(c.x+map_w,c.y+8,c.x+8+map_w,c.y+8,5)
        line(c.x-map_w,c.y+8,c.x+8-map_w,c.y+8,5)
    end
    draw_thrice(c.s,c.x,c.y,c.w/8,c.h/8,c.left)
end