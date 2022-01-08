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

default = normalize(
    playlist(
        id='playlist',
        mode="pls_mode",
        reload_mode='watch',
        mime_type="audio/x-mpegurl",
        "/music/playlists/Default/play.m3u"
    )
)

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
        mime_type="audio/music" ) )
s = skip_blank(length=7.,randomloop)

s = rewrite_metadata([("title","$(title)"),
                      ("comment","")],s)

#promo = playlist.safe("/home/audio/promo", mode="random")
#radio = random( weights = [1,4], [ delay(700.,promo), randomloop ])
#output.alsa(id="audioloop",bufferize=true,device="hw:1", radio)

s = audio_process(s)

output.icecast(%vorbis(quality=0.9, samplerate=44100, channels=2), 
	host="icecast",
	port=8000,
	mount='radio.ogg',
	genre='Radio',
#	restart="true",
	password="admin123",
	url="http://localhost",
	description="Radio",
	timeout=1200.,
	s	
)