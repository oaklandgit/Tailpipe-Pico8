pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function update_gameover()
	if timeouts["gameover"] == 0 then
		_init()
	end
end

function draw_gameover()
	draw_sash("game over",8)
end

function update_nextlevel()
	if timeouts["nextlevel"] == 0 then
		level+=1
		reset_level()
		mode="play"
	end
end

function draw_nextlevel()
	draw_sash(gen[level].name.." complete!",12)
end

function update_completed()
	if btnp(❎) then
		_init()
	end
end

function draw_completed()
	draw_sash("want more? tweet me @elstono",11)
end

function draw_sash(txt,bg)
	camera()
	if sash<16 then
		line(0,(127/2)-sash-1,127,(127/2)-sash-1,7)
		rectfill(0,(127/2)-sash,127,127/2+sash,bg)
		line(0,(127/2)+sash,127,(127/2)+sash,0)
		sash+=2
	else
		shadowfont(txt,64-((#txt/2*4)),60,printcycle("blink_yellow"),0)
	end
end