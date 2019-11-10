pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function _update60()

	updatetimeouts()
	foreach(cycles,updatecycle)

	if mode=="start" then
		dialog=gen[level].dialog
		update_start()
	elseif mode=="instructions" then
		update_instructions()
	elseif mode=="play" then
		update_game()
	elseif mode=="nextlevel" then
		update_nextlevel()
	elseif mode=="completed" then
		update_completed()
	elseif mode=="gameover" then
		update_gameover()
	elseif mode=="message" then
		update_message()
	end
end

function _draw()
	if mode=="start" then
		draw_start()
	elseif mode=="instructions" then
		draw_instructions()
	elseif mode=="play" then
		draw_game()
	elseif mode=="nextlevel" then
		draw_nextlevel()
	elseif mode=="completed" then
		draw_completed()
	elseif mode=="gameover" then
		draw_gameover()
	elseif mode=="message" then
		draw_message()
	end
end