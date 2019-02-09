import 'dart:convert';
import 'package:share/share.dart';

import '../ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final String apiKey;
  HomePage(this.apiKey);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search.isEmpty) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=${widget.apiKey}&limit=20&rating=R");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=${widget.apiKey}&q=${this._search}&limit=19&offset=${this._offset}&rating=R&lang=en");
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
        this.setState(() {

        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                this.setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container(
                        child: Text("Erro ao carregar imagens :("),
                      );
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(int number) {
      if (_search == null) {
          return number;
      } else {
          return number + 1;
      }
  }

  Widget _createGifTable(context, snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: _getCount(snapshot.data["pagination"]["count"]),
      itemBuilder: (context, index) {
        if(_search == null || index <snapshot.data["pagination"]["count"])
            return GestureDetector(
            child: CachedNetworkImage(
                imageUrl: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                placeholder: Container(),
                errorWidget: Icon(Icons.error),
                fit: BoxFit.cover,
                fadeInCurve: Curves.easeIn,
            ),
            onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                     );
            },
            onLongPress: () async {
                var link = snapshot.data["data"][index]["images"]["fixed_height"]["url"];
                await Share.share(link);
            },
            );
        else
            return Container(
                child: GestureDetector(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Icon(Icons.add, color: Colors.white, size: 70.0),
                            Text("Carregar mais...",
                            style: TextStyle(color: Colors.white, fontSize: 20.0),)
                        ],
                    ),
                    onTap: () {
                        setState(() {
                            _offset += 19;
                        });
                    },
                ),
            );
      },
    );
  }
}
