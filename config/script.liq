#!/usr/bin/liquidsoap

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

# Random music
random_music = normalize(
    playlist(
        id="playlist",
        mode="random",
        reload=600,
        "/music"
    )
)

# Silence 
silence = blank(id="blank")

# Fallback to Silence if Playlist dies for some reason
radio = fallback(
    track_sensitive=false,
    [ random_music, silence ]
)

# Stream name
stream_mountpoint = getenv("stream_mountpoint")

# Output
output.icecast(
    %mp3.vbr(quality=1, id3v2=true),
    name = getenv("STREAM_NAME"),
    description = getenv("STREAM_DESC"),
    url = getenv("STREAM_URL"),
    mount = "radio_high.mp3",
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