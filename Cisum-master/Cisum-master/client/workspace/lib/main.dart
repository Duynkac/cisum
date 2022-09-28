import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Cisum'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  final String server = 'http://localhost:8888';
  final AudioPlayer player = AudioPlayer();

  String input = '';
  String chosenArtist = '';
  String songkickID = '';
  var artistInfo;
  var musicInfo;
  var concertInfo;
  var songkickIDs;
  List<String> artistNames;
  List<String> artistImages;
  List<String> musicTitles;
  List<String> musicUrls;
  List<String> concertNames;
  List<String> concertDates;
  List<String> concertLocations;
  bool isOnArtist = false;
  bool isOnMusic = false;
  bool hasResult = false;
  bool hasMusic = false;
  bool hasConcert = false;
  bool isPlaying = false;
  int selectedArtist = -1;
  int selectedMusic = -1;
  int chosenMusic = -1;

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                flex: 15,
                child: Container(
                    child: Center(
                  child: Column(
                    children: [
                      Expanded(
                          child: Container(
                            child: Text(
                              "Cisum",
                              style: TextStyle(fontSize: 100),
                            ),
                          ),
                          flex: 99),
                      Expanded(child: Container(), flex: 1)
                    ],
                  ),
                )),
              ),
              Expanded(
                flex: 10,
                child: Row(
                  children: [
                    Expanded(
                      flex: 25,
                      child: Container(),
                    ),
                    Expanded(
                        flex: 50,
                        child: Container(
                          child: TextField(
                            cursorColor: Colors.black,
                            controller: myController,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration.collapsed(
                                hintText: 'Enter a music artist'),
                          ),
                          decoration: BoxDecoration(border: Border.all()),
                        )),
                    Expanded(
                        flex: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.search,
                            size: 30,
                          ),
                          onPressed: () {
                            setState(() {
                              chosenArtist = '';
                            });
                            _searchArtist();
                          },
                        )),
                    Expanded(flex: 15, child: Container())
                  ],
                ),
              ),
              Expanded(flex: 75, child: _buildArtists()),
            ],
          )),
    );
  }

  _searchArtist() async {
    setState(() {
      input = myController.text;
      input = input.replaceAll(' ', '%20');
    });
    http.Response response = await http.post(
      server + '/api/search',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'query': input,
      }),
    );

    setState(() {
      artistInfo = json.decode(response.body);
      if (artistInfo['name'].length > 0) {
        hasResult = true;
        artistNames = List<String>.generate(
            artistInfo['name'].length, (index) => artistInfo['name'][index]);
        artistImages = List<String>.generate(
            artistInfo['image'].length, (index) => artistInfo['image'][index]);
      } else {
        hasResult = false;
      }
    });
  }

  _buildArtists() {
    if (!hasResult && myController.text.isEmpty) {
      return Container();
    } else if (!hasResult && myController.text.isNotEmpty) {
      return Container(
        child: AutoSizeText(
          "No result",
          style: TextStyle(fontSize: 30),
        ),
      );
    } else {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 30,
              child: Container(
                  color: Colors.black,
                  child: Column(
                    children: [
                      Expanded(
                          child: Row(children: [
                            Expanded(child: Container(), flex: 1),
                            Expanded(
                                flex: 24,
                                child: AutoSizeText(
                                  'Select an artist',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                )),
                            Expanded(
                              flex: 75,
                              child: Container(),
                            )
                          ]),
                          flex: 20),
                      Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: artistNames.length,
                            itemBuilder: (BuildContext context, int position) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      chosenArtist = artistNames[position];
                                      hasConcert = false;
                                    });
                                    _getMusic();
                                  },
                                  onHover: (value) {
                                    if (value) {
                                      setState(() => selectedArtist = position);
                                    }
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 500,
                                    child: MouseRegion(
                                      onEnter: (e) => setState(() {
                                        isOnArtist = true;
                                      }),
                                      onExit: (e) => setState(() {
                                        isOnArtist = false;
                                      }),
                                      child: Card(
                                        color: Colors.black,
                                        shape: (selectedArtist == position &&
                                                isOnArtist)
                                            ? RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 2,
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(20))
                                            : RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Card(
                                                shape: CircleBorder(),
                                                child: artistImages[position] ==
                                                        ''
                                                    ? Image.asset(
                                                        'asset/images/blank_profile.png')
                                                    : Image.network(
                                                        artistImages[position]),
                                              ),
                                              flex: 8,
                                            ),
                                            Expanded(
                                                child: AutoSizeText(
                                                  artistNames[position],
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                flex: 2)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                            }),
                        flex: 80,
                      )
                    ],
                  )),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Expanded(
                flex: 67,
                child: Row(children: [
                  Expanded(
                    flex: 5,
                    child: (chosenArtist != '') ? _buildMusic() : Container(),
                  ),
                  Expanded(
                    flex: 5,
                    child: (chosenArtist != '') ? _buildConcert() : Container(),
                  )
                ]))
          ],
        ),
      );
    }
  }

  _getMusic() async {
    setState(() {
      chosenArtist = chosenArtist.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), "");
      chosenArtist = chosenArtist.replaceAll(' ', '%20');
    });
    http.Response response = await http.post(
      server + '/api/search/$chosenArtist',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'query': chosenArtist,
      }),
    );

    setState(() {
      musicInfo = json.decode(response.body);

      if (musicInfo['name'].length > 0) {
        hasMusic = true;
        musicTitles = List<String>.generate(
            musicInfo['name'].length, (index) => musicInfo['name'][index]);
        musicUrls = List<String>.generate(
            musicInfo['url'].length, (index) => musicInfo['url'][index]);
      } else {
        hasMusic = false;
      }
    });
    _getSongKickID();
  }

  _buildMusic() {
    if (!hasMusic && chosenArtist == '') {
      return Container();
    } else if (!hasMusic && chosenArtist != '') {
      return Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                  child: Row(children: [
                    Expanded(child: Container(), flex: 2),
                    Expanded(
                        flex: 33,
                        child: AutoSizeText(
                          'Song Previews',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )),
                    Expanded(
                      flex: 65,
                      child: Container(),
                    )
                  ]),
                  flex: 10),
              Expanded(
                  child: Center(
                    child: AutoSizeText(
                      "No song found",
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                  flex: 90)
            ],
          ));
    } else {
      return Container(
          color: Colors.black,
          child: Column(
            children: [
              Expanded(
                  child: Row(children: [
                    Expanded(child: Container(), flex: 2),
                    Expanded(
                        flex: 33,
                        child: AutoSizeText(
                          'Song Previews',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )),
                    Expanded(
                      flex: 65,
                      child: Container(),
                    )
                  ]),
                  flex: 10),
              Expanded(
                  child: ListView.builder(
                      itemCount: musicTitles.length,
                      itemBuilder: (BuildContext context, int position) {
                        return InkWell(
                            onTap: () {
                              if (isPlaying == false ||
                                  chosenMusic != position) {
                                player.play(musicUrls[position]);
                                setState(() {
                                  chosenMusic = position;
                                  isPlaying = true;
                                });
                              } else if (isPlaying =
                                  true && chosenMusic == position) {
                                player.stop();
                                setState(() {
                                  isPlaying = false;
                                });
                              }
                            },
                            onHover: (value) {
                              if (value) {
                                setState(() => selectedMusic = position);
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              child: MouseRegion(
                                onEnter: (e) => setState(() {
                                  isOnMusic = true;
                                }),
                                onExit: (e) => setState(() {
                                  isOnMusic = false;
                                }),
                                child: Card(
                                  color: Colors.black,
                                  shape:
                                      (selectedMusic == position && isOnMusic)
                                          ? RoundedRectangleBorder(
                                              side: BorderSide(
                                                  width: 2,
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(20))
                                          : RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: AutoSizeText(
                                          musicTitles[position],
                                          style: TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        flex: 5,
                                      ),
                                      Expanded(
                                        child: _buildIcon(position),
                                        flex: 4,
                                      ),
                                      Expanded(
                                        child: Container(),
                                        flex: 1,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ));
                      }),
                  flex: 90)
            ],
          ));
    }
  }

  _buildIcon(index) {
    if (selectedMusic == index && isOnMusic) {
      if (chosenMusic == index && isPlaying) {
        return Icon(
          Icons.pause,
          color: Colors.white,
          size: 15,
        );
      } else {
        return Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 15,
        );
      }
    } else if (chosenMusic == index && isPlaying) {
      return Icon(
        Icons.pause,
        color: Colors.white,
        size: 15,
      );
    } else {
      return Container();
    }
  }

  _getSongKickID() async {
    http.Response response = await http.post(
      server + '/api/songkick/$chosenArtist',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'query': chosenArtist,
      }),
    );

    setState(() {
      songkickIDs = json.decode(response.body);

      if (songkickIDs['id'].length > 0) {
        songkickID = songkickIDs['id'][0].toString();
      }
    });
    _getConcert();
  }

  _getConcert() async {
    http.Response response = await http.post(
      server + '/api/coming_concert/$songkickID',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'query': songkickID,
      }),
    );

    setState(() {
      concertInfo = json.decode(response.body);

      if (concertInfo['name'].length > 0) {
        hasConcert = true;
        concertNames = List<String>.generate(
            concertInfo['name'].length, (index) => concertInfo['name'][index]);
        concertDates = List<String>.generate(
            concertInfo['date'].length, (index) => concertInfo['date'][index]);
        concertLocations = List<String>.generate(concertInfo['location'].length,
            (index) => concertInfo['location'][index]);
      } else {
        hasConcert = false;
      }
    });
  }

  _buildConcert() {
    if (!hasConcert && chosenArtist == '') {
      return Container();
    } else if (!hasConcert && chosenArtist != '') {
      return Container(
          color: Colors.blueGrey[400],
          child: Column(
            children: [
              Expanded(
                  child: Row(children: [
                    Expanded(child: Container(), flex: 2),
                    Expanded(
                        flex: 53,
                        child: AutoSizeText(
                          'Upcoming Events',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        )),
                    Expanded(
                      flex: 45,
                      child: Container(),
                    )
                  ]),
                  flex: 10),
              Expanded(
                  child: Center(
                    child: AutoSizeText(
                      "No event found",
                      style: TextStyle(fontSize: 30, color: Colors.black),
                    ),
                  ),
                  flex: 90)
            ],
          ));
    } else {
      return Container(
          color: Colors.blueGrey[400],
          child: Column(
            children: [
              Expanded(
                  child: Row(children: [
                    Expanded(child: Container(), flex: 2),
                    Expanded(
                        flex: 53,
                        child: AutoSizeText(
                          'Upcoming Events',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        )),
                    Expanded(
                      flex: 45,
                      child: Container(),
                    )
                  ]),
                  flex: 10),
              Expanded(
                  child: Center(
                      child: ListView.builder(
                    itemCount: concertNames.length,
                    itemBuilder: (BuildContext context, int position) {
                      return Row(
                        children: [
                          Expanded(child: Container(), flex: 5),
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    concertNames[position],
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      AutoSizeText('Date: '),
                                      AutoSizeText(concertDates[position]),
                                      SizedBox(width: 50),
                                      AutoSizeText('Location: '),
                                      AutoSizeText(concertLocations[position]),
                                    ],
                                  )
                                ],
                              ),
                              flex: 95)
                        ],
                      );
                    },
                  )),
                  flex: 90)
            ],
          ));
    }
  }
}
