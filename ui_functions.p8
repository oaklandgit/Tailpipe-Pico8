pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function draw_ui()
	--debug
    -- if (memorydebug) then
    --     debug=	"flies:"..#flies..
	-- 			" smoke:"..#smoke..
	-- 			" bullets"..#bullets..
	-- 			" trees"..#trees
    -- end
	-- if (debug) print(debug,cam_x+1,1,0)

	--meters
	score_ui(cam_x+61,4)
	level_ui(cam_x+4,4)
 	flies_ui(cam_x+1,120)	
	if (ugene.weapon and ugene.weapon.id=="nerfgun") nerf_ui(cam_x+24,120)
	if (ugene.weapon and ugene.weapon.id=="squirtgun") h2o_ui(cam_x+24,120)
	if (ugene.weapon and ugene.weapon.id=="lasergun") power_ui(cam_x+24,120)	
	if (gen[level].trees) co2_ui(cam_x+50,120)
	health_ui(cam_x+124,117)
	radar_ui()
end

function score_ui(x,y)
	shadowfont(score,x,y,11,0)
end

function level_ui(x,y)
	shadowfont(gen[level].name,x,y,11,0)
end

function flies_ui(x,y)
	spr(16,x,y-1,1,1)
	shadowfont(gen[level].flies-killedflies,x+10,y,7,0)
end

function nerf_ui(x,y)
	if (nerf==0 and printcycle("blink")) return
	spr(52,x-1,y-4,1,1)
	shadowfont(nerf,x+9,y,7,0)
end

function h2o_ui(x,y)
	if (h2o==0 and printcycle("blink")) return
	spr(59,x,y,1,1)
	shadowfont(h2o,x+11,y,7,0)
end

function power_ui(x,y)
	if (power==0 and printcycle("blink")) return
	spr(48,x,y-2,1,1)
	shadowfont(power.."%",x+9,y,7,0)
end

function co2_ui(x,y)
	local percent=co2/co2_max
	if percent < .50 then
		c=11 -- green ok
	elseif percent < .80 then
		c=10 -- yellow
		--watermetip=true
	else
		--watermetip=true
		if printcycle("blink") then
			sfx(10)
			health-=co2healthpenalty
  		end
 	end
	shadowfont("co2",x,y,7,0)
	rectfill(x+13,y,x+35,y+4,0)
	line(x+15,y+2,x+15+(flr(18*percent)),y+2,c)
end

function health_ui(x,y)
	if (health<1.5 and printcycle("blink")) then
		sfx(10)
		return
	end

	local sprite
	for h=1,health_max do
		if (health >= h)  then
			if (health-h < .5) then
				sprite=13
			else
				sprite=12
			end
		else
			sprite=14
		end
		shadowsprite(sprite,x-(h*6),y,1,1,0)
	end
end

function radar_ui()
	local cx,cy = cam_x+116, 14 --centerx,centery
	local r1,r2,r3 = 8,5,2 --outer,plotted,inner circles
	local percent
	circfill(cx,cy,r1,0)
	circfill(cx,cy,r3,6)
	
	--plot ugene
	percent=ugene.x/map_w
	px = flr(cx+r2*cos(-percent))
	py = flr(cy+r2*sin(-percent))
	pset(px,py,15)

	--plot weapon
	for w in all(weapons) do
		percent=w.x/map_w
		px = flr(cx+r2*cos(-percent))
		py = flr(cy+r2*sin(-percent))
		pset(px,py,w.c) --color on radar
	end
end