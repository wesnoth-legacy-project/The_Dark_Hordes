--
-- Copyright (C) 2006 - 2021 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

---
-- Fades out the currently playing music and replaces
-- it with silence afterwards.
--
-- It is not possible at this time to know whether music is enabled in
-- the first place, so the fade out delay will always occur regardless
-- of the user's preferences.
--
-- [fade_out_music]
--     duration= (optional int, defaults to 1000 ms)
-- [/fade_out_music]
---
function wesnoth.wml_actions.fade_out_music(cfg)
	local duration = cfg.duration

	if duration == nil then
		duration = 1000
	end

	-- HACK: reserve last 10 milliseconds for the music switch workaround.
	duration = duration - 10

	local delay_granularity = 10

	duration = math.max(delay_granularity, duration)
	local rem = duration % delay_granularity

	if rem ~= 0 then
		duration = duration - rem
	end

	local steps = duration / delay_granularity
	--wesnoth.message(("%d steps"):format(steps))

	for k = 1, steps do
		local v = mathx.round(100 - (100*k / steps))
		--wesnoth.message(("step %d, volume %d"):format(k, v))
		wesnoth.music_list.volume = v
		wesnoth.delay(delay_granularity)
	end

	wesnoth.music_list.clear()

	-- Unset existing ms_after to work around Wesnoth issues #4458, #4459, and #4460.
	if wesnoth.music_list.current then
		wesnoth.music_list.current.ms_after = 0
	end

	wesnoth.music_list.add("silence.ogg", true)

	-- HACK: give the new track a chance to start playing silently before
	--       resetting to full volume.
	wesnoth.delay(10)

	wesnoth.music_list.volume = 100.0
end

local function wml_sfx_volume_fade_internal(duration, is_fade_out)
	if duration == nil then
		duration = 1000
	end

	local delay_granularity = 10

	duration = math.max(delay_granularity, duration)
	duration = duration - (duration % delay_granularity)

	local steps = duration / delay_granularity
	--wesnoth.message(("%d steps"):format(steps))

	for k = 1, steps do
		local v = 0

		if is_fade_out then
			v = mathx.round(100 - (100*k / steps))
		else
			v = mathx.round(100*k / steps)
		end

		--wesnoth.message(("step %d, volume %d"):format(k, v))

		wesnoth.sound_volume(v)

		wesnoth.delay(delay_granularity)
	end
end
