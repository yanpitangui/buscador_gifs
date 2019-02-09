import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GifPage extends StatelessWidget {
    final Map _gifData;
    GifPage(this._gifData);
  @override
  Widget build(BuildContext context) {
    var link = _gifData["images"]["fixed_height"]["url"];
    return Scaffold(
      appBar: AppBar(
          title: Text(_gifData["title"]),
          backgroundColor: Colors.black,
          actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async {
                      await Share.share(link);
                    //   var stream = CachedNetworkImageProvider(link).resolve(ImageConfiguration());
                    //   stream.addListener((listener, err) async {
                    //       final ByteData bytes = await listener.image.toByteData();
                    //       print(bytes.lengthInBytes);
                    //   });
                  },
              )
          ],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: CachedNetworkImage(
              imageUrl: link,
                fadeInCurve: Curves.easeIn,),
      ),
    );
  }
}