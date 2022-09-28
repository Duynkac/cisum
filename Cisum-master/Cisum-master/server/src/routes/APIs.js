const express = require('express');
const https = require('https');
const router = express.Router();
const token = require('./../app.js');
const bodyParser = require('body-parser');
const request = require('request')
const fsLibrary = require('fs');
const { create } = require('domain');

router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());



router.post('/search', (req,res,next) => {
    var query = req.body.query;
    var options = createArtistOptions(query);
    const artistReq = https.request(options, (artistRes) => {
        let body = [];
        artistRes.on('data',function(chunk) {
            body.push(chunk);
       });
       artistRes.on('end', function() {        
            const bodyString = body.join('');
            const artistsJSON = JSON.parse(bodyString);
            if(query != '') {
                const artistInfo = parseArtists(artistsJSON);
                res.send(artistInfo);
            }
            res.end();
        });
    });
    artistReq.on('error', (e) => {
        console.error(e);
    });
    artistReq.end();
    
});

router.post('/songkick/:query', (req,res,next) => {
    var query = req.body.query;
    var concertOptions = createConcertOptions(query,'artist');

    const concertReq = https.request(concertOptions, (concertRes) => {
        let body = [];
        concertRes.on('data',function(chunk) {
            body.push(chunk);
        });
        concertRes.on('end', function() {      
            const bodyString = body.join('');
            const concertJSON = JSON.parse(bodyString);
            const songkickID = parseConcert(concertJSON, 'artist');
            res.send(songkickID);
            res.end();
        });
    });
    concertReq.on('error', (e) => {
        console.error(e);
    });
    concertReq.end();
});

router.post('/coming_concert/:query', (req,res,next) => {
    var query = req.body.query;
    var comingOptions = createConcertOptions(query,'comingEvent');
    
    const comingReq = https.request(comingOptions, (comingRes) => {
        let body = [];
        comingRes.on('data', function(chunk) {
            body.push(chunk);
        });
        
        comingRes.on('end', function() {
            const bodyString = body.join('');
            const comingJSON = JSON.parse(bodyString);
            const comingInfo = parseConcert(comingJSON,'comingEvent');
            res.send(comingInfo);
            res.end();
        });
    })
    comingReq.on('error', (e) => {
        console.error(e);
    });
    comingReq.end();
});

router.post('/search/:query', (req,res,next) => {
    var query = req.body.query;
    var musicOptions = createMusicOptions(query);

    const musicReq = https.request(musicOptions, (musicRes) => {
        let body = [];
        musicRes.on('data',function(chunk) {
            body.push(chunk);
       });
       musicRes.on('end', function() {
            const bodyString = body.join('');
            const musicJSON = JSON.parse(bodyString);
            const musicInfo = parseMusic(musicJSON);
            res.send(musicInfo);
            res.end();
        });
    });
    musicReq.on('error', (e) => {
        console.error(e);
    });
    musicReq.end();
});

const spotifyArtists = {
    limit : '20',
    type : 'artist'
};

const spotifyMusic = {
    limit : '20',
    type : 'track'
};

const songkickConcert = {
    apikey : 'WrjWVFUrbGWK4Brn',
}

function createArtistOptions(query) {
	const options = {
        hostname: 'api.spotify.com',
        headers: { 'Authorization': 'Bearer ' + token.accessToken },
        json: true,
		port: 443,
		path: '/v1/search?',
		method: 'GET'
	}
            
    const str = 'q=' + query +
                '&type=' + spotifyArtists.type + 
                '&limit=' + spotifyArtists.limit 
	options.path += str;
	return options;
}

function parseArtists(artists) {
    let s = {
        name : [],
        image : [],
    };
	for (let i = 0; i < artists.artists.items.length; i++) {
        artist = artists.artists.items[i];
        name = artist.name;
        image = '';
        for(let i = 0; i < artist.images.length; i++) {
            if (artist.images[i].width == '640' && artist.images[i].height == '640') {
                image = artist.images[i].url;
            }
        }
        s.name.push(name);
        s.image.push(image);
    }
	return s;
}

function createMusicOptions(query) {
	const options = {
        hostname: 'api.spotify.com',
        headers: { 'Authorization': 'Bearer ' + token.accessToken },
        json: true,
		port: 443,
		path: '/v1/search?',
		method: 'GET'
	}
            
    const str = 'q=' + query +
                '&type=' + spotifyMusic.type + 
                '&limit=' + spotifyMusic.limit 
	options.path += str;
	return options;
}

function parseMusic(music) {
    let s = {
        name : [],
        url : [],
    };

	for (let i = 0; i < music.tracks.items.length; i++) {
        track = music.tracks.items[i];
        name = track.name;
        url = track.preview_url;
        
        s.name.push(name);
        s.url.push(url);

    }
	return s;
}

function createConcertOptions(query, type) {
	const options = {
        hostname: 'api.songkick.com',
        json: true,
		port: 443,
		path: '/api/3.0/',
		method: 'GET'
	}
    
    if (type == 'artist') {
        const str = 'search/artists.json?apikey=' + 
                songkickConcert.apikey +
                '&query=' + query +
                '&per_page=1'
               
        options.path += str;
    } else if (type == 'comingEvent') {
        const str = 'artists/' + query +
                '/calendar.json?apikey=' +
                songkickConcert.apikey +
                '&per_page=10'
                
	    options.path += str;
    } else if (type == 'pastEvent') {
        const str = 'artists/' + query +
                '/gigography.json?apikey=' +
                songkickConcert.apikey +
                '&per_page=5'
                
	    options.path += str;
    }
    
	return options;
}

function parseConcert(data, type) {

    if (type == 'artist') {
        let s = {
            id : [],
        };
        if(data.resultsPage.totalEntries != 0) {
            for (let i = 0; i < data.resultsPage.results.artist.length; i++) {
                artist = data.resultsPage.results.artist[i];
                id = artist.id;
                s.id.push(id);   
            }
            return s;
        }
        
    } else if (type == 'comingEvent') {
        let s = {
            name : [],
            date : [],
            location : []
        };
        if(data.resultsPage.totalEntries != 0) {
            for (let i = 0; i < data.resultsPage.results.event.length; i++) {
                event = data.resultsPage.results.event[i];
                name = event.displayName;
                date = event.start.date;
                location = event.location.city;
                s.name.push(name);
                s.date.push(date);
                s.location.push(location);
            }
            return s;
        }
    }
	
	return;
}

module.exports = router;