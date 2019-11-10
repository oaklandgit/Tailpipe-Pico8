--pico-8 cartridge // http://www.pico-8.com
--version 18
__lua__

function _init()

	--dev=false

	mode="start"
	score=4287
	level=1
	sash=0

	playmusic=false
	menuitem(1,"stop music",toggle_music)
	-- if dev then
	-- 	menuitem(2,"toggle hitboxes",toggle_hitboxes)
	-- 	menuitem(3,"toggle memory debug",toggle_memorydebug)
	-- end

    --difficulty
    health=5.5
	health_max=5
    flyspawnspeed=500
	flyspeed=1.5+rnd(.5)
    co2healthpenalty=.005
	flypenalty=.5
	cactuspenalty=.5
	h2o_max=30
	power_max=99
	co2_max=100
	fueltoxicity=.05
	magiclife=400

    --education
    --watermetip=true
    
 	--debugging
	hitboxes=false
	memorydebug=false

	--playfield
	map_w=952
	wall_h=88
	max_y=100
	coin_y=96
	min_y=-10
	cam_x=0

	--physics
	friction=.008
	accel=.07
 	accel_max=1.5

	--words
	messages={}
	dialog=""
	tooltip=""
	rnd_anger={}
	rnd_anger[1]="ouch!"
	rnd_anger[2]="grrrr."

	--levels
	gen={
		{
			ugene={120,50},
			dialog="something smells funny",
			name="1st gen",
			flies=8,
			nerfgun={300,wall_h},
			phone={120,wall_h+4,"ugene,//i mixed up the yellow/cake with the fruit cake./(oops!)//so you might notice some/mutant fruit flies.//love,/zeno"}
		},
		{
			ugene={20,50},
			dialog="sigh",
			name="2nd gen",
			flies=16,
			nerfgun={120,wall_h},
			drones={{300,40},{340,60}},
			lasergun={400,wall_h,5,127}, --x,y,power,range
			outlets={{200,77},{488,77},{776,77}},
			phone={20,wall_h+4,"hi again ugene,//it seems the flies evolved/and hacked our security/system!//so also watch out for/killer drones.//your pal, zeno"}
		},
		{
			ugene={20,50},
			dialog="sigh",
			name="3rd gen",
			flies=32,
			nerfgun={400,wall_h},
			drones={{300,40},{340,60}},
			lasergun={120,wall_h,10,220},
			outlets={{200,77},{776,77}},
			phone={20,wall_h+4,"hey little buddy,//i made some mods to your/laser gun!//but be careful -- it has/quite a loooong range!//xoxoxo"}
		},
		{
			ugene={300,50},
			dialog="i want to go home",
			name="4th gen",
			flies=32,
			drones={{500,40},{580,60},{600,70},{700,30}},
			nerfgun={300,wall_h},
			lasergun={600,wall_h,10,220},
			outlets={{776,77}},
			squirtgun={500,wall_h},
			fountains={{716,44},{696,40}},
			trees={
				{400,76,1},
				{540,76,2},{560,76,1},{550,82,1},--further down y in front
				{700,76,3},
				{820,76,1}
			},
			phone={260,wall_h+4,"by the way,//the lab's ventilation/is shot, so watch your/co2 levels and don't/run your motor too long...//or you'll asphyxiate, lol!//p.s. please water the/plants"}
		}
	}
	
	--timeouts
	timeouts={}
	timeouts["smoke"]=0
	timeouts["dialog"]=300
	timeouts["tooltip"]=200
	timeouts["dripping"]=0
	timeouts["spawnright"]=0
	timeouts["spawnleft"]=0
	timeouts["collisions"]=0
	timeouts["ugenewhite"]=0
	timeouts["co2blinking"]=0
	timeouts["shooting"]=0
	timeouts["phonering"]=0
	timeouts["typing"]=0
	
	--for tracking animations, loops, etc.
	cycles={}
	addcycle("idle",60,{7})
 	addcycle("water",20,{4})
	addcycle("fly",10,{16,32})
 	addcycle("blink",40,{true,false})
	addcycle("blink_text",30,{10,11})
	addcycle("blink_ok",30,{11,3})
	addcycle("blink_yellow",30,{10,7})
	addcycle("blink_shadow",30,{0})
	addcycle("drone_blink",60,{5,8})
	addcycle("phone_shake",60,{true,false})
	addcycle("spawn",5,{true,true,true,false,false,false,true,true,false,false,true,false})
	
	--fruit values
	fruit_base_spr=179
	fruits_types={"orange","watermelon","grapes","cherries","peach","apple"}

	--activate level!
	reset_level()

end 

function reset_level()

	--reset variables
	--health=5.5
	totalflies=0
	killedflies=0
	nerf=50
	power=99
	h2o=30
	co2=0

	--reset objects
	parts={} 
	smoke={}
	shots={}
	respawn_queue=nil
	bullets={}
	lasers={}
	flies={}
	fruits={}
	stream={} --water stream
	coins={} --anything collectable
	weapons={}

	--respawn objects
	phone={
		x=gen[level].phone[1],
		y=gen[level].phone[2],
		msg=gen[level].phone[3],
		w=8,
		h=8,
		hilite=false,
		read=false
	}

	--player
	ugene={
		x=gen[level].ugene[1], y=gen[level].ugene[2],
		w=18, h=18,
		dx=0, dy=0,
		aim="left",
		left=false,
		action="idle",
		weapon=nil,
		sprite={ --sprite, width in sprites
			idle={7,2},
			nerfgun={1,3},
			squirtgun={9,3},
			lasergun={138,4},
			planter={12,3}
			}
		}

	--squirt gun
	if (gen[level].squirtgun) then
		add(weapons,
			{
				n="squirt gun",
				id="squirtgun",
				--quote="so it's ❎ to fire and/🅾️ to put down?",
				s=238,
				x=gen[level].squirtgun[1],
				y=gen[level].squirtgun[2],
				w=16,
				h=16,
				left=false,
				hilite=false,
				c=12
			}
		)
	end

	--nerf gun
	if (gen[level].nerfgun) then
		add(weapons,
			{
				n="nerf gun",
				id="nerfgun",
				--quote="so it's ❎ to fire and/🅾️ to put down?",
				s=206,
				x=gen[level].nerfgun[1],
				y=gen[level].nerfgun[2],
				w=16,
				h=16,
				left=false,
				hilite="false",
				c=9
			}
		)
	end

	--laser gun
	if (gen[level].lasergun) then
		add(weapons,
			{
				n="laser gun",
				id="lasergun",
				--quote="so it's ❎ to fire and/🅾️ to put down?",
				s=235,
				x=gen[level].lasergun[1],
				y=gen[level].lasergun[2],
				w=16,
				h=16,
				left=false,
				hilite="false",
				c=8
			}
		)
	end

	--drones
	drones={}
	for drone in all(gen[level].drones) do
		add(drones,
			{
				x=drone[1],
				y=drone[2],
				dx=rnd(.5)+.5,
				w=16,
				h=8,
				active=false,
				health=100,
				meterdelay=0,
				left=true
			}
		)
	end

	outlets={}
	for outlet in all(gen[level].outlets) do
		add(outlets,
			{
				x=outlet[1],
				y=outlet[2],
				w=8,
				h=8,
				hilite=false
			}
		)
	end

	fountains={}
	for fountain in all(gen[level].fountains) do
		add(fountains,
			{
				x=fountain[1],
				y=fountain[2],
				w=24,
				h=16,
				hilite=false
			}
		)
	end

	--trees
	--tree sprites - spr,tile width, tile height, offset
	tree_types={
	{{128,1,1,5},{129,1,1,5},{130,2,1,0},{144,2,2,0},{146,2,2,0}}, --exotic
		{{132,1,1,4},{133,1,1,4},{134,1,1,4},{148,2,2,0},{150,2,2,0}}, --bamboo
		{{176,1,1,4},{177,1,1,4},{178,1,1,4},{136,1,2,4},{142,2,2,0}} --cactus
	}
	trees={}
	for tree in all(gen[level].trees) do
		add(trees,
			{
				x=tree[1],
				y=tree[2],
				type=tree[3],
				health=0,
				hilite=false,
				planthilite=false,
				size=0,
				w=16,
				h=8,
				magic=nil,
				countdown=0,
				coins={{1,0,false},{0,1,false},{2,1,false},{1,2,false},{0,3,false}}
			}
		)
	end
end