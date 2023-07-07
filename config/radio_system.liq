#!/usr/bin/liquidsoap

 log.file.set(true)
 log.stdout.set(true)
 log.level.set(4)

 settings.request.metadata_decoders.set(["FFMPEG", "MP4", "OGG", "TAGLIB", "ID3V2", "GSTREAMER"])

# Allow root for official docker image
set("init.allow_root", true)

# Set environments if empty
if getenv("STREAM_NAME") == "" then
    setenv("STREAM_NAME", "Radio")
end
if getenv("STREAM_DESC") == "" then
    setenv("STREAM_DESC", "Radio Station Pro Music")
end
if getenv("STREAM_MOUNTPOINT") == "" then
    setenv("STREAM_MOUNTPOINT", "live")
end

# Playlist mode

# A fallback switch

req = say_metadata(request.queue())



# Random music
# random_music = normalize(
#     playlist(
#         id="playlist",
#         mode="pls_mode",
#         reload_mode="watch",
#         mime_type="audio/x-mpegurl",
#         "/music"
#     )
# )

Default = playlist(reload=3600,
        id='playlist',
        mode="pls_mode",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Default/play.m3u")

Morning = playlist(reload=3600,
        id='playlist',
        mode="pls_mode",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Morning/play.m3u")


Evening = playlist(reload=3600,
        id='playlist',
        mode="pls_mode",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Evening/play.m3u")


Earlymorning = playlist(reload=3600,
        id='playlist',
        mode="pls_mode",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Earlymorning/play.m3u")


Night = playlist(reload=3600,
       id='playlist',
        mode="pls_mode",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Night/play.m3u")

# Silence

silence = blank(id="blank")


jingles = rotate([
 playlist(reload=1,
        id='jingle',
        mode="pls_mode",
        reload_mode='rounds',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Jingles/play.m3u")
])

# A scheduler,
# assuming you have defined the night and day sources

radio = switch([
    ({6h-13h}, Morning),
    ({12h-17h}, Evening),
    ({18h-23h}, Night),
    ({0h-6h}, Earlymorning),
    ({0m0s}, Default)
    ])

# Effect

# Stream name

radio = rotate(weights = [1, 5],[ jingles, radio ])
radio = add([radio, switch([({0m0s},jingles)])])
radio = nrj(normalize(radio))
radio = crossfade(fade_out=3., fade_in=3., duration=5., radio)
radio = fallback(track_sensitive=false, [ radio, silence])


# Fallback to Silence if Playlist dies for some reason

stream_mountpoint = getenv("stream_mountpoint")


# Output


output.icecast(
    %mp3.vbr(quality=1, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = getenv("STREAM_MOUNTPOINT"),
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    port = 8808,
    icy_metadata="true",
    encoding = "UTF-8",
    radio
)

output.icecast(
    %mp3.vbr(quality=5, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = "station-medium.mp3",
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    port = 8808,
    icy_metadata="true",
    encoding = "UTF-8",
    radio
)

output.icecast(
    %mp3.vbr(quality=8, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = "station-low.mp3",
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    icy_metadata="true",
    port = 8808,
    encoding = "UTF-8",
    radio
)
