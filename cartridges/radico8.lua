-- some constants in measurements of seconds
MAX_SONG_TOTAL_LENGTH  = 60*7
MAX_SONG_REPEAT_LENGTH = 10
MAX_SONG_RAND_REPEAT_LENGTH = 5
FADE_OUT_LENGTH = 1.25
PAUSE_LENGTH = 1
FADE_IN_LENGTH = 0

function _init()
  load_song()
end

function load_song()
  g_cartname, g_tracknum, g_artist = next_song()

  -- reload current cart first because it has a stop at every track, ensuring bad files won't be played
  reload(0x3100, 0x3100, 0x1200)
  if g_cartname ~= "" then
    reload(0x3100, 0x3100, 0x1200, g_cartname..".p8.png")
    local song_len, does_repeat = calc_song_len(g_tracknum)
    song_len = min(song_len, MAX_SONG_TOTAL_LENGTH)
    g_song_len = song_len+(does_repeat and (MAX_SONG_REPEAT_LENGTH + rnd(MAX_SONG_RAND_REPEAT_LENGTH)) or 0)

    local minutes = (song_len+.5)\1\60
    local seconds = (song_len+.5)\1%60
    printh(g_cartname..":"..g_tracknum..":"..minutes..":"..seconds..":"..(does_repeat and "repeat" or "stop")..":"..g_artist)
  else
    g_song_len = 0
  end

  g_pause_song_count = 0
  g_remaining_song_time = g_song_len
end

-- uncomment for debugging. not needed in production though.
function _draw()
  cls()

  local minutes = ((g_remaining_song_time or 0)+.5)\1\60
  local seconds = ((g_remaining_song_time or 0)+.5)\1%60
  print(minutes.."m", 64, 60, 7)
  print(seconds.."s", 64, 68, 7)
end

function _update60()
  local cur_track, cur_tick, is_music_playing = stat(54), stat(56), stat(57)

  -- pause before we actually start playing the music
  if g_pause_song_count then
    if g_pause_song_count >= 60*PAUSE_LENGTH then
      g_pause_song_count = nil
      music(g_tracknum, 1000*FADE_IN_LENGTH)
    end

  -- give some time to fade out before loading the next song
  elseif g_next_song_count then
    if g_next_song_count >= 60*FADE_OUT_LENGTH then
      g_next_song_count = nil
      load_song()
    end

  -- if time is over or music is not playing, then start next song count
  elseif btnp(4) or btnp(5) or g_remaining_song_time <= 0 or not is_music_playing then
    music(-1, 1000*FADE_OUT_LENGTH)
    g_next_song_count = 0

  elseif g_remaining_song_time then
    g_remaining_song_time = max(0, g_remaining_song_time-1/60)
  end

  -- update timers
  if g_pause_song_count    then g_pause_song_count += 1 end
  if g_next_song_count     then  g_next_song_count += 1 end
end

-- return song_len_in_seconds, does_song_repeat
function calc_song_len(track)
  local cur_track = track
  local tracks = {}
  local does_repeat = true

  -- or cur_track is empty (stop)
  while not tracks[cur_track] do
    local trackdata  = peek4(0x3100+cur_track*4)
    local data_stop  = trackdata & 0x0080.0000 ~= 0
    local data_end   = trackdata & 0x0000.8000 ~= 0
    local data_beg   = trackdata & 0x0000.0080 ~= 0

    local track_len, chan_count = calc_track_len(trackdata)
    -- printh("track: "..cur_track.." chans: "..chan_count.." len: "..track_len.." beg: "..(data_beg and "yes" or "no").." end: "..(data_end and "yes" or "no").." stop: "..(data_stop and "yes" or "no"))
    if chan_count == 0 then
      does_repeat = false
      break
    end

    tracks[cur_track] = track_len

    if data_stop then
      cur_track = cur_track
      does_repeat = false
    elseif data_end then
      while cur_track > 0 do
        if (peek4(0x3100+cur_track*4) & 0x0000.0080) ~= 0 then
          break
        end
        cur_track -= 1
      end
    else
      cur_track = max(0, min(63, cur_track+1))
    end
  end

  local song_len = 0
  for k,v in pairs(tracks) do
    song_len += v
  end

  return max(0, song_len), does_repeat
end

-- return track_len_in_seconds, channel_count
function calc_track_len(trackdata)
  local channels = {}
  if trackdata & 0x0000.0040 == 0 then add(channels,  shl(trackdata & 0x0000.003f, 16)) end
  if trackdata & 0x0000.4000 == 0 then add(channels,  shl(trackdata & 0x0000.3f00,  8)) end
  if trackdata & 0x0040.0000 == 0 then add(channels, lshr(trackdata & 0x003f.0000,  0)) end
  if trackdata & 0x4000.0000 == 0 then add(channels, lshr(trackdata & 0x3f00.0000,  8)) end

  local slowest = 0
  for sfxid in all(channels) do
    local sfx_speed, does_loop = calc_sfx_len(sfxid)
    if not does_loop then
      return sfx_speed, #channels
    elseif sfx_speed > slowest then
      slowest = sfx_speed
    end
  end

  return slowest, #channels
end

-- return len_in_seconds, does_it_loop
function calc_sfx_len(sfxid)
  local sfxaddr    = 0x3200 + sfxid*68
  local speed      = max(1, @(sfxaddr+65))
  local loop_start = @(sfxaddr+66)
  local loop_end   = @(sfxaddr+67)
  local sfxlen     = 32
  if loop_end == 0 and loop_start > 0 then sfxlen = loop_start end
  return speed / 120 * sfxlen, loop_end > loop_start
end

g_playlist = {}
function next_song()
  if #g_playlist == 0 then
    printh("###") -- triger scripts to send input
    g_playlist = load_round()
  end

  if #g_playlist > 0 then
    return unpack(deli(g_playlist,1))
  end

  return "", 0, ""
end

function load_round()
  local playlist = {}

  poke(0x4300, 0)

  local buff = ""
  while true do
    serial(0x0804, 0x4300, 1)
    if @0x4300 == 10 then
      if buff == "###" then
        return playlist
      else
        -- there was an issue where a "colon" wasn't specified once, so radico8 crashed.
        -- adding the defaults helps the radio be a bit more resilient.
        local name, num, artist = unpack(split(buff, ":", false))
        add(playlist, {name or "", tonum(num, 0x4) or 0, artist or ""})
        buff=""
      end
    else
      buff = buff..chr(@0x4300)
    end
  end
end
