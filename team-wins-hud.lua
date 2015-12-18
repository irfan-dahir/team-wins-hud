if teamStats == nil then teamStats = {} end
teamStats.author = "Nighthawk"
teamStats.version = "0.2"
function teamStats.initArray(table,index) local arr = table if type(table) == "table" then arr = {} end for i=1,index do arr[i] = 0 end return arr end

--[[
	Configuration
]]
teamStats.config = {
	--[[
		You can turn the visual bar on/off here.
			render = true -- it will show
			render = false -- it won't show
		This will NOT turn it off!
	]]
	render = true,
	--[[
		showTime = x
		In Seconds. The visual bar will disappear after x seconds.
		If you don't want it to disappear and to stay for the rest of the round then set x as 0
			showTime = 0
	]]
	showTime = 30, -- seconds
	--[[
		freeTime = x
		In Seconds. The visual bar will be freed up as will the variables included with the images after x seconds AFTER showTime. This helps prevent lag
		So if the showTime of the visual bar is 30 seconds and the freeTime is 3 seconds then the visual bar will be free its memory after 33 seconds.
		This is useful is you extend the fade out timings of the HUD elements. If your background is set to fade out after 5 seconds then you will have to increase 'freeTime' to 5 or 6 seconds so the HUD doesn't free up before the transition finishes.
		If you don't know what this means then don't touch it
	]]
	freeTime = 3, -- seconds
	--[[
		roundLimit = x
		The team win stats will reset count after x rounds. If you don't want it to reset then set it as 0;
			roundLimit = 0
	]]
	roundLimit = 3, --rounds
	--[[
		The positions are completely customizable.
	]]
	UI = {
		bg = {
			src = "gfx/teamwinhud/bg.png",
			x = 330,
			y = 75,
			alpha = 0.8, -- 0.0 - 1.0
		},
		shade = {
			show = true,
			src = "gfx/teamwinhud/shade.png",
			x = 330,
			y = 75,
			alpha = 0.8, -- 0.0 - 1.0
		},
		ct_bar = {
			src = "gfx/teamwinhud/ct.png",
			alpha = 0.9, -- 0.0 - 1.0
			--[[
				Do not tweak this unless you know what you're doing
				start_x is where the FIRST rendered block lies
			]]
			start_x = 130,
			y = 75,
			--[[
				Do not tweak this unless you know what you're doing
				The width here is the image's width of 1 block in pixels.  (i.e; ct.png)
			]]
			width = 4,
		},
		tt_bar = {
			src = "gfx/teamwinhud/tt.png",
			alpha = 0.9, -- 0.0 - 1.0
			--[[
				Do not tweak this unless you know what you're doing
				start_x is where the FIRST rendered block lies
			]]
			start_x = 525,
			y = 75,
			--[[
				Do not tweak this unless you know what you're doing
				The width here is the image's width of 1 block in pixels.  (i.e; tt.png)
			]]
			width = 4,
		},
		ct_hudtxt = {
			show = true,
			id = 44, -- hudtxt ID
			text = "Counter-Terrorists",
			color = "\169230230230", -- \169rrggbb
			x = 130,
			y = 62,
			alpha = 1.0,
		},
		tt_hudtxt = {
			show = true,
			id = 45, -- hudtxt ID
			text = "Terrorists",
			color = "\169230230230", -- rrggbb
			x = 435,
			y = 62,
			alpha = 1.0,
		},
		percentage_hudtxt = {
			show = true,
			color = "\169255255255", -- rrggbb
		},
	},
	--[[
		Choose whether you want a nice fade-in/out transition.
	]]
	animate = true,
	--[[
		Animation Settings
	]]
	animation = {
		bg = {
			fadeIn = true,
			fadeOut = true,
			fadeInTime = 1000, -- milliseconds
			fadeOutTime = 1000, -- milliseconds
		},
		shade = {
			fadeIn = true,
			fadeOut = true,
			fadeInTime = 1500, -- milliseconds
			fadeOutTime = 1500, -- milliseconds
		},
		hudtxt = {
			fadeOut = true,
			fadeOutTime = 1500, -- milliseconds
			slideIn = true,
			slideOut = false,
			slideInTime = 1000, -- milliseconds
			slideOutTime = 1000, -- milliseconds
		},
		bar = {
			fadeIn = true,
			fadeOut = true,
			slideOut = true,
			--[[
				!!!WARNING!!!
				Don't touch these if you don't know what you're doing.
			]]
			fadeOutTime = 500, -- milliseconds
			fadeInTime = 5000, -- milliseconds
			--[[
				1 block is 1 block image that's equal to 1% of what completes the bar in the HUD, so in the render process we'll be negating the tween_alpha time taken
				i.e fadeInTime - fadeInTimeDecrementPerBlock
				A total of 100 bars are called in the process. Each bar will have it's own tween_alpha on the transition process so the effect would be more like the starting blocks will take longer to fade in then the ones further in. Damn I suck at explaining so there you go, top notch explanation.
				Imagine this as a bar, the numbers inside are the tween_alpha time taken
				[] = 1 block (there are a total of 100 blocks)
				[5000][5900][5800][5700][5600][5500], [fadeInTime-fadeInTimeDecrementPerBlock], ...

				Tweak these settings at your own discretion
			]]
			fadeInTimeDecrementPerBlock = 100, -- milliseconds
			fadeOutTimeDecrementPerBlock = 200, -- milliseconds
			slideOutTimeDecrementPerBlock = 250, -- milliseconds
		},
	},
}
--[[
	Constants/CS2D Variables
]]
teamStats.const = {
	gameModes = {
		ct = {30, 2, 11, 21, 22, 31, 41, 61}, -- cts win these modes
		tt = {1, 10, 12, 20, 40, 50, 60}, -- tts win these modes
	},
}

--[[
	Initialization
]]
teamStats.UI = {
	showing = false,
	bg = nil,
	shade = nil,
	ct = {},
	tt = {},
}
teamStats.UI.ct = teamStats.initArray(teamStats.UI.ct, 100)
teamStats.UI.tt = teamStats.initArray(teamStats.UI.tt, 100)

teamStats.vars = {
	tt = 0,
	ct = 0,
	ct_percentile = 0,
	tt_percentile = 0,
	round = 0,
	showTimeCount = 0,
	resetCall = false,
}


--[[
	Hook Calls
]]
addhook("startround", "teamStats.render")
addhook("endround", "teamStats.roundend")
addhook("second", "teamStats.second")

--[[
	Hook Functions
]]
function teamStats.second()
	if teamStats.config.showTime > 0 then
		if teamStats.UI.showing then
			teamStats.vars.showTimeCount = teamStats.vars.showTimeCount + 1
			if teamStats.vars.showTimeCount > teamStats.config.showTime then
				if teamStats.config.animation.bg.fadeOut then
					teamStats.animate(teamStats.UI.bg, "fadeOut", teamStats.config.animation.bg.fadeOutTime, 0)
				end
				if teamStats.config.animation.shade.fadeOut then
					teamStats.animate(teamStats.UI.shade, "fadeOut", teamStats.config.animation.shade.fadeOutTime, 0)
				end
				for i=1,teamStats.vars.ct_percentile do
					if teamStats.config.animation.bar.fadeOut then
						teamStats.animate(teamStats.UI.ct[i], "fadeOut", teamStats.config.animation.bar.fadeOutTime, 0)
					end
					if teamStats.config.animation.bar.slideOut then
						teamStats.animate(teamStats.UI.ct[i], "slideOut", teamStats.config.animation.bar.slideOutTimeDecrementPerBlock + (i*10), 0, {teamStats.config.UI.ct_bar.start_x, teamStats.config.UI.ct_bar.y})
					end
				end
				for i=1,teamStats.vars.tt_percentile do
					if teamStats.config.animation.bar.fadeOut then
						teamStats.animate(teamStats.UI.tt[i], "fadeOut", teamStats.config.animation.bar.fadeOutTime, 0)
					end
					if teamStats.config.animation.bar.slideOut then
						teamStats.animate(teamStats.UI.tt[i], "slideOut", teamStats.config.animation.bar.slideOutTimeDecrementPerBlock + (i*10), 0, {teamStats.config.UI.tt_bar.start_x, teamStats.config.UI.tt_bar.y})
					end
				end
				if teamStats.config.animate then
					if teamStats.config.animation.hudtxt.slideOut then
						parse('hudtxtmove 0 '..teamStats.config.UI.ct_hudtxt.id..' '..teamStats.config.animation.hudtxt.slideOutTime..' -100 '..teamStats.config.UI.ct_hudtxt.y)
						parse('hudtxtmove 0 '..teamStats.config.UI.tt_hudtxt.id..' '..teamStats.config.animation.hudtxt.slideOutTime..' 600 '..teamStats.config.UI.tt_hudtxt.y)
					end
					if teamStats.config.animation.hudtxt.fadeOut then
						parse('hudtxtalphafade 0 '..teamStats.config.UI.ct_hudtxt.id..' '..teamStats.config.animation.hudtxt.fadeOutTime..' 0.0')
						parse('hudtxtalphafade 0 '..teamStats.config.UI.tt_hudtxt.id..' '..teamStats.config.animation.hudtxt.fadeOutTime..' 0.0')
					end
				end
			end
			if teamStats.vars.showTimeCount > teamStats.config.showTime + teamStats.config.freeTime then
				teamStats.free()
			end
		end
	end
end

function teamStats.render()
	if teamStats.vars.resetCall then
		teamStats.reset()
		teamStats.free()
		teamStats.vars.resetCall = false
	end
	if teamStats.config.render then
		if teamStats.vars.ct > 0 or teamStats.vars.tt > 0 then
			teamStats.UI.showing = true
			local ct_offset = 0
			local tt_offset = 0
			local ct_hudtxt = teamStats.config.UI.ct_hudtxt.text
			local tt_hudtxt = teamStats.config.UI.tt_hudtxt.text
			if teamStats.config.UI.percentage_hudtxt.show then
				ct_hudtxt = ct_hudtxt..' ('..teamStats.config.UI.percentage_hudtxt.color..teamStats.vars.ct_percentile..'%'..teamStats.config.UI.ct_hudtxt.color..')'
				tt_hudtxt = tt_hudtxt..' ('..teamStats.config.UI.percentage_hudtxt.color..teamStats.vars.tt_percentile..'%'..teamStats.config.UI.tt_hudtxt.color..')'
			end
			if teamStats.config.UI.ct_hudtxt.show then
				if teamStats.config.animate then
					if teamStats.config.animation.hudtxt.slideIn then
						teamStats.hudtxt(teamStats.config.UI.ct_hudtxt.id, ct_hudtxt, teamStats.config.UI.ct_hudtxt.color, (teamStats.config.UI.ct_hudtxt.x-50), teamStats.config.UI.ct_hudtxt.y, 0)
						parse('hudtxtmove 0 '..teamStats.config.UI.ct_hudtxt.id..' '..teamStats.config.animation.hudtxt.slideInTime..' '..teamStats.config.UI.ct_hudtxt.x..' '..teamStats.config.UI.ct_hudtxt.y)
					end
				else
					teamStats.hudtxt(teamStats.config.UI.ct_hudtxt.id, ct_hudtxt, teamStats.config.UI.ct_hudtxt.color, teamStats.config.UI.ct_hudtxt.x, teamStats.config.UI.ct_hudtxt.y, 0)
				end
			end
			if teamStats.config.UI.tt_hudtxt.show then
				if teamStats.config.animate then
					if teamStats.config.animation.hudtxt.slideIn then
						teamStats.hudtxt(teamStats.config.UI.tt_hudtxt.id, tt_hudtxt, teamStats.config.UI.tt_hudtxt.color, (teamStats.config.UI.tt_hudtxt.x+50), teamStats.config.UI.tt_hudtxt.y, 0)
						parse('hudtxtmove 0 '..teamStats.config.UI.tt_hudtxt.id..' '..teamStats.config.animation.hudtxt.slideInTime..' '..teamStats.config.UI.tt_hudtxt.x..' '..teamStats.config.UI.tt_hudtxt.y)
					end
				else
					teamStats.hudtxt(teamStats.config.UI.tt_hudtxt.id, tt_hudtxt, teamStats.config.UI.tt_hudtxt.color, teamStats.config.UI.tt_hudtxt.x, teamStats.config.UI.tt_hudtxt.y, 0)
				end
			end
			teamStats.UI.bg = image(teamStats.config.UI.bg.src, teamStats.config.UI.bg.x, teamStats.config.UI.bg.y, 2)
			if teamStats.config.animation.bg.fadeIn then
				teamStats.animate(teamStats.UI.bg, "fadeIn", teamStats.config.animation.bg.fadeInTime, teamStats.config.UI.bg.alpha)
			end
			for i=1,teamStats.vars.ct_percentile do
				teamStats.UI.ct[i] = image(teamStats.config.UI.ct_bar.src, teamStats.config.UI.ct_bar.start_x+ct_offset, teamStats.config.UI.ct_bar.y, 2)
				imagealpha(teamStats.UI.ct[i], teamStats.config.UI.ct_bar.alpha)
				ct_offset = ct_offset + teamStats.config.UI.ct_bar.width
				if teamStats.config.animation.bar.fadeIn then
					local fade_in_time = teamStats.config.animation.bar.fadeInTime - (teamStats.config.animation.bar.fadeInTimeDecrementPerBlock*i)
					teamStats.animate(teamStats.UI.ct[i], "fadeIn", fade_in_time, teamStats.config.UI.ct_bar.alpha)
				end
			end
			for i=1,teamStats.vars.tt_percentile do
				teamStats.UI.tt[i] = image(teamStats.config.UI.tt_bar.src, teamStats.config.UI.tt_bar.start_x-tt_offset, teamStats.config.UI.tt_bar.y, 2)
				imagealpha(teamStats.UI.tt[i], teamStats.config.UI.tt_bar.alpha)
				tt_offset = tt_offset + teamStats.config.UI.tt_bar.width
				if teamStats.config.animation.bar.fadeIn then
					local fade_in_time = teamStats.config.animation.bar.fadeInTime - (teamStats.config.animation.bar.fadeInTimeDecrementPerBlock*i)
					teamStats.animate(teamStats.UI.tt[i], "fadeIn", fade_in_time, teamStats.config.UI.tt_bar.alpha)
				end
			end
			if teamStats.config.UI.shade.show then
				teamStats.UI.shade = image(teamStats.config.UI.shade.src, teamStats.config.UI.shade.x, teamStats.config.UI.shade.y, 2)
				if teamStats.config.animation.shade.fadeIn then
					teamStats.animate(teamStats.UI.shade, "fadeIn", teamStats.config.animation.shade.fadeInTime, teamStats.config.UI.shade.alpha)
				end
			end
		end
	end
end

function teamStats.roundend(mode)
	if teamStats.config.roundLimit > 0 then
		teamStats.vars.round = teamStats.vars.round + 1
		if teamStats.vars.round <= teamStats.config.roundLimit then
			for _,gm in pairs(teamStats.const.gameModes.ct) do
				if gm == mode then
					teamStats.vars.ct = teamStats.vars.ct + 1
					break
				end
			end
			for _,gm in pairs(teamStats.const.gameModes.tt) do
				if gm == mode then
					teamStats.vars.tt = teamStats.vars.tt + 1
					break
				end
			end
		else teamStats.vars.resetCall = true end
	else
		print('INFINITE ROUNDS MODE')
		for _,gm in pairs(teamStats.const.gameModes.ct) do
			if gm == mode then
				teamStats.vars.ct = teamStats.vars.ct + 1
				break
			end
		end
		for _,gm in pairs(teamStats.const.gameModes.tt) do
			if gm == mode then
				teamStats.vars.tt = teamStats.vars.tt + 1
				break
			end
		end
	end
	-- Round End Calls/Updates
	teamStats.calculatePercentile()
	teamStats.vars.showTimeCount = 0
	teamStats.UI.showing = false
end

--[[
	Module Functions
]]
function teamStats.reset()
	teamStats.vars.ct = 0
	teamStats.vars.tt = 0
	teamStats.vars.ct_percentile = 0
	teamStats.vars.tt_percentile = 0
	teamStats.vars.round = 0
end
function teamStats.calculatePercentile()
	local total = teamStats.vars.ct + teamStats.vars.tt
	if total ~= 0 then
		teamStats.vars.ct_percentile = math.floor(((teamStats.vars.ct/total)*100)+0.5)
		teamStats.vars.tt_percentile = math.floor(((teamStats.vars.tt/total)*100)+0.5)
	end
end
function teamStats.free()
	if teamStats.UI.bg ~= nil then
		freeimage(teamStats.UI.bg)
		teamStats.UI.bg = nil
	end
	if teamStats.UI.shade ~= nil then
		freeimage(teamStats.UI.shade)
		teamStats.UI.shade = nil
	end
	for i=1,teamStats.vars.ct_percentile do
		if teamStats.UI.ct[i] ~= nil then
			freeimage(teamStats.UI.ct[i])
			teamStats.UI.ct[i] = nil
		end
	end
	for i=1,teamStats.vars.tt_percentile do
		if teamStats.UI.tt[i] ~= nil then
			freeimage(teamStats.UI.tt[i])
			teamStats.UI.tt[i] = nil
		end
	end
	parse('hudtxtalphafade 0 '..teamStats.config.UI.ct_hudtxt.id..' 0 0.0')
	parse('hudtxtalphafade 0 '..teamStats.config.UI.tt_hudtxt.id..' 0 0.0')
	teamStats.UI.showing = false
end
function teamStats.animate(image_id, animation, time, alpha, ...)
	if teamStats.config.animate then
		if time < 0 then time = 100 end
		if animation == "fadeIn" then
			imagealpha(image_id, 0)
			tween_alpha(image_id, time, alpha)
		elseif animation == "fadeOut" then
			tween_alpha(image_id, time, alpha)
		elseif animation == "slideOut" then
			tween_move(image_id, time, unpack(...))
		end
	end
end
function teamStats.hudtxt(id,msg,color,x,y,align)
	parse('hudtxt '..id..' "'..color..''..msg..' " '..x..' '..y..' '..align)
end