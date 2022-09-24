-- some constants in measurements of seconds
MAX_SONG_TOTAL_LENGTH  = 60*5
MAX_SONG_REPEAT_LENGTH = 30
MAX_SINGLE_SONG_REPEAT_LENGTH = 10
FADE_OUT_LENGTH = 1
FADE_IN_LENGTH = 1

function _init()
    load_song()
end

function load_song()
    g_cartname, g_songname, g_tracknum = get_next_cart()
    g_song_time = 0
    g_cur_track = g_tracknum
    g_tracks = {[g_cur_track]=true}
    g_remaining_song_time = nil

    -- reload current cart first because it has a stop at every track, ensuring bad files won't be played
    reload(0x3100, 0x3100, 0x1200)
    reload(0x3100, 0x3100, 0x1200, g_cartname)
    printh("playing: "..g_songname.. " - "..g_tracknum)
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

function _draw()
    fillp(0b1010010110100101)
    rectfill(0,0,127,127,1)
    fillp()

    camera(0, sin(t()/4)*16)
    ovalfill(64-65-40, 64-8, 64+64+40, 64+8, 1)
    zprint(g_songname..":"..g_tracknum, 64, 59, 0, 7)
    zprint("("..g_cur_track..")", 64, 65, 0, 7)
    camera()
end

function get_next_cart()
    poke(0x4300, 0)

    local buff = ""
    while true do
        serial(0x0804, 0x4300, 1)
        if @0x4300 == 10 then
            local name, num = unpack(split(buff, ":"))
            return name, get_first(buff, "-", ".", ":"), tonum(num, 0x4)
        end
        buff = buff..chr(@0x4300)
    end
end

function zprint(str, x, y, align, color)
    if align == 0    then x -= #str*2
    elseif align > 0 then x -= #str*4+1 end
    print(str, x, y, color)
end

-- split, but get the first thing with all delimiters
function get_first(text, ...)
    foreach({...}, function(delim)
        text = split(text, delim)[1]
    end)
    return text
end
