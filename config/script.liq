#!/usr/bin/liquidsoap

 log.file.set(false)
 log.stdout.set(true)
 log.level.set(4)

 settings.request.metadata_decoders.set(["FFMPEG", "FLAC", "MP4", "OGG", "TAGLIB", "ID3V2", "GSTREAMER"])

# Allow root for official docker image
set("init.allow_root", true)

# Set environments if empty
if getenv("STREAM_NAME") == "" then
    setenv("STREAM_NAME", "Radio")
end
if getenv("STREAM_DESC") == "" then
    setenv("STREAM_DESC", "Our selection of music")
end
if getenv("STREAM_MOUNTPOINT") == "" then
    setenv("STREAM_MOUNTPOINT", "live")
end

# Playlist mode



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

radio_playlist = normalize(
    playlist(
        id='playlist',
        mode="normal",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/radio.m3u"
    )
)


# Silence 
silence = blank(id="blank")

# Fallback to Silence if Playlist dies for some reason
radio = fallback(
    track_sensitive=false,
    [ radio_playlist, silence ]
)

# Stream name
stream_mountpoint = getenv("stream_mountpoint")

# Output
output.icecast(
    %mp3.vbr(quality=1, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = "station-hight.mp3",
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    port = 8000,
    encoding = "UTF-8",
    radio
)

output.icecast(
    %mp3.vbr(quality=5, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = "radio_medium.mp3",
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    port = 8000,
    encoding = "UTF-8",
    radio
)

output.icecast(
    %mp3.vbr(quality=8, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = "radio_low.mp3",
    password = getenv("ICECAST_SOURCE_PASSWORD"),
    host = "icecast",
    port = 8000,
    encoding = "UTF-8",
    radio
)