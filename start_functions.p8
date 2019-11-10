pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function update_start()

	if btnp(❎) then
		mode="play"
		sfx(3)
		start_music()
	end

	if btnp(➡️) then
		mode="instructions"
		sfx(3)
	end
end

function draw_start()
	--cls()
	--fillp(printcycle("pattern"))
	--rectfill(0,0,127,127,0x1d)
	rectfill(0,0,127,127,13)
	--fillp()
	--splash title
	pal(7,0) --text shadow
 	pal(6,0) --text shadow
	spr(64,6,14,14,4)
	--reset color
	pal()
	
	shadowsprite(64,8,12,14,4,13)

 	--smoke
	shadowsprite(50,33,48,1,1,13)
	shadowsprite(49,33,54,1,1,13)

 	--ugene
	shadowsprite(4,40,56,3,3,0)

 	--bullet
	shadowsprite(52,63,63,1,1,13)

 	--fly
	shadowsprite(16,79,64,1,1,13)
 	--spr(16,79,64,1,1)

	shadowfont("press ❎ to play",34,86,printcycle("blink_text"),printcycle("blink_shadow"))
	shadowfont("➡️ for game tips",34,96,7,0)
	--shadowfont("(c) 2019 larry stone",24,110,7,13)
	shadowfont("twitter @elstono (c) 2019",13,118,7,13)
end

function update_instructions()
	if btnp(❎) then
		mode="play"
		sfx(3)
		start_music()
	end

	if btnp(➡️) then
		mode="start"
		sfx(3)
	end
end


function draw_instructions()
	cls(5)

	local offsetx, offsety = 24, 12
	local pts,txt

	--flies
	spr(16,offsetx,offsety)
	shadowfont("fruit fly = 1pt",offsetx+12,offsety+3,7,0)

	for i=1,#fruits_types do
		if i == 6 then --apple
			txt="apple = "
			spr(fruit_base_spr+i,offsetx,offsety+(10*i)+18)
			shadowfont(txt,offsetx+12,offsety+(10*i)+20,7,0)
			shadowfont("♥",offsetx+12+30,offsety+(10*i)+20,8,0)
		else
			pts=i*10
			txt=fruits_types[i].." = "..pts.."pts"
			spr(fruit_base_spr+i,offsetx,offsety+(10*i)+9)
			shadowfont(txt,offsetx+12,offsety+(10*i)+11,7,0)
		end
	end
	shadowfont("press ❎ to play",offsetx+10,offsety+96,printcycle("blink_text"),printcycle("blink_shadow"))
end