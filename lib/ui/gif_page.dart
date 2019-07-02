import 'package:flutter/material.dart';
import 'package:share/share.dart';

//Pagina que não vai ser modificada, ou seja não vamos interagir , vou só abrir a foto
//E assim ela não precisa ser stateFull, apenas stateLes

class GifPage extends StatelessWidget {

  final Map _dadosGif;

  GifPage(this._dadosGif);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dadosGif["title"]),
        backgroundColor: Colors.black,
        //Vou criar a ação para compartilhamento no appBar
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            //Para quando for clicado
            onPressed: () {
              //Importei o share lá nas depedências
              //E aqui dentro vamos passar o texto que eu quero que ele compartilhe
              //E no caso vou passar o link para ele importar
              Share.share(_dadosGif["images"]["fixed_height"]["url"]);
            },
          )
        ],
      ),
      //Cor do fundo do app
      backgroundColor: Colors.black,
      //o corpo vai ser uma imagem na tela, vou mapear de acordo com o que vier do home_page
      body: Center(
        //pegando a url do gif
        child: Image.network(_dadosGif["images"]["fixed_height"]["url"]),
      ),
    );
  }
}
