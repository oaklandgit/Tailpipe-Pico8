pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- debugging and environment

function draw_thrice(sprite,x,y,w,h,left)
	spr(sprite,x,y,w,h,left)
	spr(sprite,x+map_w,y,w,h,left)
	spr(sprite,x-map_w,y,w,h,left)
end

-- function toggle_hitboxes()
-- 	hitboxes=not hitboxes
-- end

-- function toggle_memorydebug()
-- 	memorydebug = not memorydebug
-- end

-- function save_video()
-- 	extcmd('video')
-- end

function stop_music()
	music(-1)
	menuitem(1,"start music",toggle_music)
	playmusic=false
end

function start_music()
	music(0,0,1)
	menuitem(1,"stop music",toggle_music)
	playmusic=true
end

function toggle_music()
	if playmusic then
		stop_music()
	else
		start_music()
	end
end

function debug_hitbox(_o)
 if hitboxes then
  local offset=_o.topoffset or 0
  rect(_o.x,_o.y+offset,_o.x+_o.w,_o.y+_o.h,8)
 end
end

-- common game routines
function rndminmax(min,max)
	return rnd(max-min) + min
end

--sprite all 1 color
function setspritecolor(c)
	for i=0,15 do
		pal(i,c)
	end
end

function jumpback(d)
	if ugene.left then
    	ugene.dx+=d
    else
        ugene.dx-=d
    end
end

function updatetimeouts()
	for i,v in pairs(timeouts) do
		if timeouts[i]>0 then
			timeouts[i]-=1
		end
	end
end

function onscreen(o)
	if (o.x+o.w > cam_x and o.x < cam_x+127) return true
  	return false
end

function box_hit(obj1,obj2)
	hit=false
	local xd=abs((obj1.x+(obj1.w/2))-(obj2.x+(obj2.w/2)))
	local xs=obj1.w*0.5+obj2.w*0.5
	local yd=abs((obj1.y+(obj1.h/2))-(obj2.y+(obj2.h/2)))
	local ys=obj1.h/2+obj2.h/2
	if xd<xs and yd<ys then
		hit=true
	end
	return hit
end

-- cycles
function addcycle(_name,_duration,_data)
	local _c={}
	_c.name=_name
	_c.duration=_duration
	_c.age=0
	_c.data=_data --table
	_c.index=1
	add(cycles,_c)
end

function updatecycle(cycle)
	cycle.age+=1
	if cycle.duration-cycle.age < 0 then 
		cycle.index+=1
		cycle.age=0
	end
	
	if cycle.index > #cycle.data then
		cycle.index=1
	end
end

function printcycle(_name)
	for cycle in all(cycles) do
		if cycle.name==_name then
			return cycle.data[cycle.index]
		end
	end
end

--messages
function updatemessage(m)
	m.age-=1
	m.y-=.5
	if m.age<0 then
		del(messages,m)
	end
end

function drawmessage(m)
	shadowfont(m.text,m.x,m.y,7,0)
end

--particles
function addpart(x,y,dx,dy,r,col,l,anim,anim_sp)
    local p={}
	p.x=x
	p.y=y
	p.dx=dx
	p.dy=dy
	p.r=r --radius
	p.col=col
	p.lifespan=l
	p.anim=anim
	p.anim_ix=1
	p.anim_sp=anim_sp
	p.speed_ct=0
	add(parts,p)
end

function updatepart(p)
    if p.lifespan > 0 then
        p.lifespan-=1
        --acceleration
		p.x+=p.dx
		p.y+=p.dy
		--gravity
		p.y+=0.2
		p.speed_ct+=1
		if (p.anim) and (p.anim_sp-p.speed_ct==0) then
			p.speed_ct=0
			p.anim_ix+=1
			if (p.anim_ix>#p.anim) p.anim_ix=1
		end
	else
		del(parts,p)
	end
end

function drawpart(p)
	--pset(part.x,part.y,part.col)
	if (p.r) then
		circfill(p.x,p.y,p.r,p.col)
	else
		spr(p.anim[p.anim_ix],p.x,p.y,1,1)
	end
end

function shadowsprite(s,x,y,w,h,c)
	--turn all pixels the chosen shadow color
	for i=0,15 do
		pal(i,c)
	end
	spr(s,x+1,y,w,h)
	spr(s,x-1,y,w,h)
	spr(s,x,y+1,w,h)
	spr(s,x,y-1,w,h)
	pal() --reset
	spr(s,x,y,w,h)
end

function shadowfont(t,x,y,c1,c2)
    print(t,x+1,y,c2)
    print(t,x-1,y,c2)
    print(t,x,y+1,c2)
    print(t,x,y-1,c2)
    print(t,x,y,c1)
end

function say(t,x,y,d,tail)
	if timeouts["dialog"]==0 then
		timeouts["dialog"]=d
		dialog=""
		return
	end
	local lines={}
	local l=1
	local tmplen=0
	local maxlen=0

	for i=1, #t do
		if sub(t,i,i) == "/" then
			if tmplen > maxlen then
				maxlen=tmplen
			end
			tmplen=0
			l+=1
		else
			if not(lines[l]) then
				lines[l]=""
			end
			lines[l]=lines[l]..sub(t,i,i)
			tmplen+=1
		end
	end
	
	if tmplen > maxlen then
		maxlen=tmplen
	end

	--for some reason, must be even number!
	if maxlen % 2 ~= 0 then
		maxlen+=1
	end
	
	local w=(maxlen*4)+8
	local h

	if #lines==1 then
		local letterheights, gapheights
		h=18 
	else
		letterheights=#lines*5
		gapheights=(#lines+1)*3
		h=letterheights+gapheights
	end
	
	local offsetx, offsety=4,3
	local balx=x-(w/2)+offsetx
	local baly=y-h-offsety

	-- top corners
	spr(203,balx,baly,1,1)
	spr(204,balx+w-8,baly,1,1)
	--bottom corners
	spr(219,balx,baly+h-8,1,1)
	spr(220,balx+w-8,baly+h-8,1,1)

	--fill left/right
	for i=baly+8,baly+h-8 do
		pset(balx-1,i,5)
		pset(balx,i,6)
		line(balx+1,i,balx+w-1,i,7)
		pset(balx+w,i,5)
	end

	--fill top/bottom
	for i=balx+8,balx+w-8 do
		pset(i,baly-1,5)
		line(i,baly,i,baly+h-1,7)
		pset(i,baly+h-1,6)
		pset(i,baly+h,5)
	end

	--fill middle
	rectfill(balx+8,baly+8,balx+w-8,baly+h-8,7)

	--tail
	spr(205,balx+(w/2)+3,baly+h-1,1,1,tail)

	--finally, the text!
	local indenty = ((h-(#lines*7))/2)+1
	for i=1, #lines do
		local indentx = (w-(#lines[i]*4))/2
		print(lines[i],balx+indentx,baly+(i*7-7)+indenty,0)
	end
end


