require 'sinatra'
require 'httparty'
require 'json'

before do
    $stdout.sync = true
    @spotify_client = ENV["SPOTIFY_CLIENT"]
    @spotify_secret = ENV["SPOTIFY_SECRET"]
end

post '/' do
    body = request.body.read
    jBody = JSON.parse(body)
    song = jBody["any"]
    token = jBody["token"]

    track = search(song, token)
    return play(track, token)
end

# Given a track (id, name, and artist) and an auth token,
# play the track on the user's active device
def play(track, token)
    body = {"uris": [track[:id]]}
    headers = {
        "Accept": "application/json",
        "Authorization": "Bearer #{token}"
    }
    putResponse = HTTParty.put("https://api.spotify.com/v1/me/player/play", :body => body.to_json, :headers => headers)

    # 204 indicates a success
    if putResponse.code == 204
        return "Playing #{track[:name]} by #{track[:artist]}"
    else
        return "Error!"
    end
end

# Given a search phrase and an auth token, search for a track,
# returning information about the first result
def search(searchString, token)
    query = {
        "q": searchString,
        "type": "track",
        "limit": 1
    }

    headers = {
        "Accept": "application/json",
        "Authorization": "Bearer #{token}"
    }

    response = HTTParty.get("https://api.spotify.com/v1/search", :query => query, :headers => headers)
    jBody = JSON.parse(response.body)
    result = {
        "id": "spotify:track:#{jBody["tracks"]["items"].first["id"]}",
        "name": jBody["tracks"]["items"].first["name"],
        "artist": jBody["tracks"]["items"].first["artists"].first["name"]
    }

    return result

end