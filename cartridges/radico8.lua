-- some constants in measurements of seconds
MAX_SONG_TOTAL_LENGTH  = 60*5
MAX_SONG_REPEAT_LENGTH = 20
MAX_SINGLE_SONG_REPEAT_LENGTH = 10
FADE_OUT_LENGTH = 1
FADE_IN_LENGTH = 1

function _init()
    load_song()
end

function load_song()
    g_cartname, g_tracknum = next_song()
    g_song_time = 0
    g_cur_track = g_tracknum
    g_tracks = {[g_cur_track]=true}
    g_remaining_song_time = nil

    -- reload current cart first because it has a stop at every track, ensuring bad files won't be played
    reload(0x3100, 0x3100, 0x1200)
    if g_cartname ~= "" then
        reload(0x3100, 0x3100, 0x1200, g_cartname..".p8.png")
        printh(g_cartname..":"..g_tracknum)
    end
    music(g_tracknum, 1000*FADE_IN_LENGTH)
end

function _update60()
    local frame_track = stat(54)
    if not g_next_song_count and (btn(1) or g_remaining_song_time and g_remaining_song_time >= 60*MAX_SONG_REPEAT_LENGTH or g_song_time >= 60*MAX_SONG_TOTAL_LENGTH or not stat(57)) then
        music(-1, 1000*FADE_OUT_LENGTH)
        g_next_song_count = 0
    end

    if frame_track ~= -1 and g_cur_track ~= frame_track then
        g_cur_track = frame_track
        if not g_tracks[g_cur_track] then
            g_tracks[g_cur_track] = true
        elseif g_tracks[g_cur_track] and not g_remaining_song_time then
            g_remaining_song_time = 0
        end
    end

    if g_next_song_count and g_next_song_count >= 60*FADE_OUT_LENGTH then
        g_next_song_count = nil
        load_song()
    end

    if g_next_song_count     then     g_next_song_count += 1 end
    if g_remaining_song_time then g_remaining_song_time += 1 end
    if g_song_time           then           g_song_time += 1 end
end

g_playlist = {}
function next_song()
    if #g_playlist == 0 then
        printh("---") -- triger scripts to send input
        g_playlist = load_round()
    end

    if #g_playlist > 0 then
        -- there was an issue where a "colon" wasn't specified once, so radico8 crashed.
        -- adding the "track or 0" here helps the radio be more resilient, because track could be nil.
        local cart, track = unpack(deli(g_playlist,1))
        return cart or "", track or 0
    end

    return "", 0
end

function load_round()
    local playlist = {}

    poke(0x4300, 0)

    local buff = ""
    while true do
        serial(0x0804, 0x4300, 1)
        if @0x4300 == 10 then
            -- printh(buff.." -- "..#buff)
            if buff == "---" then
                return playlist
            else
                -- don't want to convert numbers on split, because some numbers are cart
                -- ids larger than the pico8 number limit, so they wrap to negative.
                -- also, tonum doesn't return zero for nil.
                local name, num = unpack(split(buff, ":", false))
                add(playlist, {name, tonum(num, 0x4)})
                buff=""
            end
        else
            buff = buff..chr(@0x4300)
        end
    end
end
