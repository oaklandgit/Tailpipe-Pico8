pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function update_game()

    if health<=0 then
        sfx(15)
        sash=0
        timeouts["gameover"]=180
        mode="gameover"
        stop_music()
    end

    if (gen[level].flies-killedflies == 0) then
        sfx(14)
        sash=0
        timeouts["nextlevel"]=180
        if (level<4) then
            mode="nextlevel"
        else
            mode="completed"
        end
    end

    tooltip=""

    update_ugene()
    spawn_flies()
    respawn_weapon()

	--update objects
	foreach(flies,updatefly)
    foreach(drones,updatedrone)
    foreach(shots,updateshot)
    foreach(fruits,updatefruit)
    foreach(messages,updatemessage)
	foreach(bullets,updatebullet)
    foreach(lasers,updatelaser)
    foreach(stream,updatestream)
	foreach(parts,updatepart)
    foreach(trees,updatetree)
    foreach(weapons,updateweapon)
    foreach(coins,updatecoin)

    foreach(outlets,updateoutlet)
    foreach(fountains,updatefountain)
    
    if (gen[level].phone) updatephone(phone)
	
	--check collisions
    --foreach(coins,collect)

	-- camera follow
    cam_x=ugene.x-64+(ugene.w/2)
    camera(cam_x,0)

end

function draw_game()

	-- screen
    cls(6)
	map(0,0,0,0,map_w/8,16)
    map(0,0,map_w,0,map_w/8,16) --fill right
    map(0,0,-map_w,0,map_w/8,16) --fill left

    if (gen[level].phone) drawphone(phone)
 
    -- objects
    foreach(outlets,drawoutlet)
    foreach(fountains,drawfountain)
    
    foreach(trees,drawtree)
    foreach(coins,drawcoin)
    foreach(weapons,drawweapon)
    foreach(bullets,drawbullet)
    foreach(lasers,drawlaser)
    foreach(stream,drawstream)
    foreach(flies,drawfly)
    

    foreach(shots,drawshot)
    foreach(drones,drawdrone)
    
    foreach(fruits,drawfruit)
    foreach(parts,drawpart)
    
    draw_ui()
    drawugene()
    foreach(messages,drawmessage)
    
    if not(tooltip=="") then
        shadowfont(tooltip,tooltipx-((#tooltip/2)*4),tooltipy,7,0)
    end
end

-- movement
function burnfuel(i)
    co2=mid(0,co2+fueltoxicity,co2_max)
    if timeouts["smoke"]<=0 then
        createsmoke()
        timeouts["smoke"]=rnd(30)
    end
    sfx(0)
end

function createsmoke()
	-- which size puff?
    local sprite, x, s
	if #smoke > 0 then
		sprite=smoke[#smoke].img+1
		if sprite > 51 then
			sprite = 49
		end
	else
		sprite=49
	end

	-- position relative to ugene
	if ugene.left then
		x=ugene.x+20
	else
		x=ugene.x-4
	end

	s = {
		x=x,
		y=ugene.y,
		age=0,
		img=sprite
	}
	add(smoke,s)

end

function drawsmoke(s)
    spr(s.img,s.x,s.y-s.age/3)
    --phantoms
    spr(s.img,s.x+map_w,s.y-s.age/3)
    spr(s.img,s.x-map_w,s.y-s.age/3)
    s.y-=.25
    if s.y < -8 then
        del(smoke,s)
    end
end

-- colliding with flies

function collide(f)
    --flies vs. ugene
    if box_hit(f,{x=ugene.x+8,y=ugene.y+8,w=8,h=8})
        and timeouts["collisions"] <=0 then
        sfx(5)
        --jumpback(3)
        health-=flypenalty
        timeouts["ugenewhite"]=20
        timeouts["collisions"]=40
        dialog=rnd_anger[flr(rnd(2)+1)]
        --f.hilite=true
    end --end check ugene

    --bullets v. flies
    for b in all(bullets) do
        if onscreen(f) and box_hit(f,b) then

            killfly(f.x,f.y)
            f.hit=true

            --spawn a fruit
            local fruit={}
            fruit.type=flr(rnd(#fruits_types))+1
            --debug=fruit.type
            --fruit.type=weightedrnd(#fruits_types)
            --fruit.type=7-(flr(rnd(6)))
            fruit.x=f.x
            fruit.y=f.y
            fruit.left=f.left
            -- print(fruit.left)
            -- stop()
            if b.left then
                fruit.dir=-1
            else
                fruit.dir=1
            end

            fruit.gravity=.98
            fruit.bounce=-.88
            fruit.bounces=6
            fruit.dy=0

            fruit.w=8
            fruit.h=8

            fruit.friction=.98
            fruit.dx=0
            fruit.val=10
            add(fruits,fruit)
            del(flies,f)
        end --end check collision
    end --end bullet loop

    --trees blocking flies
    for t in all(trees) do
        if box_hit(f,t) then
            f.left = not f.left
            f.dx = -f.dx
        end
    end
end

-- weapons
function putdownweapon()
    if ugene.weapon ~=nil then
        ugene.weapon.x=ugene.x
        ugene.weapon.y=wall_h
        respawn_queue=ugene.weapon
        ugene.action="idle"
        ugene.weapon=nil
    end
end


function pickupweapon(w)
    putdownweapon()
    sfx(14)
    ugene.weapon=w
    ugene.action=w.id
    del(weapons,w)
end

function updateweapon(w)
    if box_hit(ugene,w) then
        tooltip="❎ "..w.n
        --tooltipx=w.x-((#tooltip*4)/2)
        tooltipx=w.x+(w.w/2)
        tooltipy=w.y+16
        tooltipc=w.c
        w.hilite=true
        if btnp(❎) then
            pickupweapon(w)
        end
    end
end

function drawweapon(w)
    if w.hilite then
        shadowsprite(w.s,w.x,w.y,w.w/8,w.h/8,7)
    else
        spr(w.s,w.x,w.y,w.w/8,w.h/8)
    end
    w.hilite=false
end

function respawn_weapon()
    if respawn_queue then
        if not box_hit(ugene,respawn_queue) then
            if respawn_queue.id=="planter" then
                add(trees,respawn_queue)
            else
                add(weapons,respawn_queue)
            end
            respawn_queue=nil
        end
    end
end

-- shooting the squirtgun
function createstream(age)
    local d={} --droplet
    d.w=2
    d.h=2
    d.y=ugene.y+7
    d.dy=.6
    d.age=age
    d.left=ugene.left
    if ugene.left then
        d.x=ugene.x
        --d.dx=-3
    else
        d.x=ugene.x+20
        --d.dx=3
    end

    d.dx=ugene.dx

    --arc radius
    d.r=30

    --arc centerpoint
    d.cx=d.x
    d.cy=d.y+d.r

    add(stream,d)
end

function updatestream(d)
    local percent=(d.age/100)+.75
    if percent <=1 and not d.left then
        --clockwise arc
        d.x=flr(d.cx+d.r*cos(-percent))
        d.y=flr(d.cy+d.r*sin(-percent))
    elseif percent <=1 and d.left then
        --counterclockwise arc
        d.x=flr(d.cx-d.r*cos(percent))
        d.y=flr(d.cy-d.r*sin(percent))
    else
        d.y+=d.age/100
    end
    d.age+=.5
    d.x+=d.dx
    d.y+=d.dy

    --check if hitting any trees
    for t in all(trees) do
        if box_hit(d,t) then
            t.health=mid(0,t.health+.25,500)
            t.hilite=true
            --t.hiliteplant=true
            --no need to educate on watering anymore
            --until co2 is super low
            --watermetip=false
        end

        --grow magic if present
        if t.countdown > 0 then
            for i,c in pairs(t.coins) do
                if t.size==i and not(c[3]) then
                    add(coins,{
                        s=t.magic+fruit_base_spr,
                        x=t.x+(c[1]*8)-4,
                        y=t.y-(c[2]*8)-8,
                        w=8,
                        h=8
                    })
                    c[3]=true
                end
            end
        end
    end

    if d.y > 90 or d.x < 0 or d.x > map_w then
        del(stream,d)
    end 
end

function drawstream(d)
    pset(d.x+rnd(3),d.y+rnd(3),7)
end

-- firing laser beam
function createlaser()
    local l={}
    if ugene.left then
        l.x=ugene.x-5
        l.dx=-6
    else
        l.x=ugene.x+22
        l.dx=6
    end
    l.y=ugene.y+8
    l.w=16
    l.h=1
    l.age=0
	add(lasers,l)
end

function updatelaser(l)
    l.x+=l.dx
	l.age+=1
	if l.age>gen[level].lasergun[4] then --shoot as far as range for this level
		del(lasers,l)
	end
    --wrap laser
	if l.x<0 then
		l.x+=map_w
	elseif l.x>map_w then
		l.x-=map_w
	end

    --collide with ugene!?
    if box_hit(l,{x=ugene.x+8,y=ugene.y+8,w=8,h=8})
        and timeouts["collisions"] <=0 then
        gotshot()
    end --end check ugene

    --collide with drones?
    for d in all(drones) do
        if onscreen(d) and box_hit(l,d) then
            sfx(22)
            del(lasers,l)
            d.health-=gen[level].lasergun[3] --damage for this level
            score+=gen[level].lasergun[3]
            if d.health==0 then
                sfx(27)
                del(drones,d)
                killdrone(d.x,d.y)
                score+=40
            else
                --add(messages,{text=d.health,x=d.x,y=d.y,age=40})
                if (d.meterdelay==0) d.meterdelay=20
            end
        end
    end
    --collide with flies?
    --no fruit for laser kills
    for f in all(flies) do
        if onscreen(f) and box_hit(l,f) then
            del(lasers,l)
            killfly(f.x,f.y)
            del(flies,f)
        end
    end
end

function drawlaser(l)
    line(l.x,l.y,l.x+l.w,l.y,8)

    --phantoms
    line(l.x+map_w,l.y,l.x+map_w+l.w,l.y,8)
    line(l.x-map_w,l.y,l.x-map_w+l.w,l.y,8)
end

function attack(sourcex,sourcey,destx,desty)
    local s={} --shot
    s.w=4
    s.h=1
    s.x=sourcex
    s.y=sourcey
    s.ang = atan2(destx-sourcex,desty-sourcey)
    add(shots,s)
end

function updateshot(s)
    if box_hit(s,{x=ugene.x+8,y=ugene.y+8,w=8,h=8})
        and timeouts["collisions"] <=0 then
        gotshot()
        del(shots,s)
    else
        s.x+=cos(s.ang)*4
        s.y+=sin(s.ang)*4
        if (s.x < cam_x) or (s.x > cam_x+127) or (s.y < 0) or (s.y > 127) then
            del(shots,s)
        end
    end
end

function drawshot(s)
    line(s.x,s.y,s.x+cos(s.ang)*6,s.y+sin(s.ang)*6,8)
end

function gotshot()
    sfx(5)
    jumpback(1)
    health-=.5
    timeouts["ugenewhite"]=20
    timeouts["collisions"]=40
    dialog="*@%$ drones!"  
end

-- shooting the nerf gun
function createbullet()
    local b={}
    if ugene.left then
		b.x=ugene.x-5
		b.dx=-3
        b.left=true
	else
	    b.x=ugene.x+22
		b.dx=3
        b.left=false
	end
    b.y=ugene.y+7
    b.dy=.6
    b.w=5
    b.h=5
    b.age=0
	b.hit=false
	b.fallen=false
	add(bullets,b)
end

function updatebullet(b)
	b.x+=b.dx
	b.age+=1
	if b.age>10 then
		b.y+=b.dy
	end
    
    -- place bullet on ground
    -- and randomize placement a bit
    -- so they don't all overlap on the ground
	if b.y>coin_y+rnd(2)-4 then
		del(bullets,b)
		add(coins,{s=52,x=b.x,y=b.y,w=8,h=8,left=ugene.left})
	end	

    --wrap bullets
	if b.x<0 then
		b.x+=map_w
	elseif b.x>map_w then
		b.x-=map_w
	end

    --bounce bullets off drones
    for d in all(drones) do
        if box_hit(d,b) then
            b.dx=b.dx*.25
            b.dy=b.dy*4
            b.dx=-b.dx
            b.left=not(b.left)
        end
    end
end

function drawbullet(b)
 debug_hitbox(b)
	spr(52,b.x,b.y,1,1,b.left)
	--and its phantoms
    spr(52,b.x+map_w,b.y,1,1,b.left)
    spr(52,b.x-map_w,b.y,1,1,b.left)
    --debug="bullet.x:"..bullet.x
end