import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _procura;

  //colocando outras paginas
  int _offset=0;

  Future<Map>_getGifs() async {
    //Ele vai fazer a requisição na Internet
    //Tem que fazer a requisição e esperar um pouco, ou seja ela é assycrona = async
    //Essa resposta vai ser de dois tipos o primeiro vai buscar os melhores
    //E o 2º vai mostrar as pesquisas
    http.Response response;
    
    if(_procura == null || _procura.isEmpty) {
      //Melhores GIFS
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=jwkCdwQHqF88IOVnghC4So58ewFzTGmZ&limit=20&rating=G");
    }else {
      //Pesquisa
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=jwkCdwQHqF88IOVnghC4So58ewFzTGmZ&q=$_procura&limit=19&offset=$_offset&rating=G&lang=en");
    }

    //Retornar o json com os dados
    return json.decode(response.body);

  }

  @override
  void initState() {
    super.initState();

    //Pegar os GIFS quando ele chamar vai executar a função
    _getGifs().then((map){
        print(map);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: //1º Filho é o campo de texto
            TextField(
              decoration: InputDecoration(
                  labelText: "Procuro algo? Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  //Botando a borda que circula o campo de texto
                  border: OutlineInputBorder()
              ),
              //Definindo o stilo do texto que vai ficar dentro do campo
              style: TextStyle(color: Colors.white, fontSize: 19.0),
              textAlign: TextAlign.center,
              //Colocando a função para quando apertar no botão do teclado ele pesquise
              onSubmitted: (text) {
                setState(() {
                  //Ele atualiza a lista pois está dentro do setState, ele pega essa variavel
                  //E coloca dentro do _procura e o setState atualiza a tela
                  _procura = text;
                  //Se eu troquei de pagina e for procurar novamente,
                  //Tenho que reset o offset se não ele não vai mostrar os meus 1º itens
                  _offset = 0;
                });

              },
            ),
          ),
          //Preciso antes de colocar o GRID de gifs, colocar o expanded
          //Pois ele vai ocupar o espaço restante
          //E dentro dele que eu coloco o Futurebuilder
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                //Essa função retorna o widget dependendo do estado do snapshot
                //Se o snapshot ainda estiver carregando os dados, vou mostrar um indicator
                switch(snapshot.connectionState) {
                  //Caso ele esteja esperando ou caso esteja carregando nada
                //Eu mostro um indicator que está tentando carregar
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0, //largura do circulo
                      height: 200.0, //altura
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        //Ele vai indicar que estou botando uma cor no indicator
                        //E essa cor não vai mudar
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        //largura
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if(snapshot.hasError) return Container();
                    else return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ) ,
    );
  }

  //Retornar a minha lista de dados
  //Quando eu estiver mostrando os melhores GIFS eu não quero espaço do botão no final
  //Agora se eu pesquisar eu coloco o botão no final
  int _getCount(List dados) {
    if(_procura == null || _procura.isEmpty) {
        //Se eu não estou pesquisando
      return dados.length;
    }else {
      //Vou colocar o mais para que eu possar colocar o icone de mais.
      return dados.length + 1;
    }

  }




  //Código responsável por realizar a buscar por GIFS
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    //Aqui dentro eu retorno a minha tabela de GIFS
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        //Como os itens vão ser organizados
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //Aqui dentro vou definir quantos ele vai ter por linha
          crossAxisCount: 2,
          //Espaçamento na horizontal
          crossAxisSpacing: 10.0,
          //Espalamento na vertical para ficar cimetrico.
          mainAxisSpacing: 10.0
        ),
        //passando a lista de dados e chamando a função para distinguir
        itemCount: _getCount(snapshot.data["data"]),
        //Aqui eu passo a função que vai retornar o widget que vou botar em casa posição
        itemBuilder: (context, index) {
          //Se eu não estiver pesquisando vou retornar o meu GIF
          //Se eu estiver pesquisando mas não for o meu ultimo item vou continuar carregando o gif
          //se não for isso vai ser o ITEM do GIF
        if(_procura == null || index < snapshot.data["data"].length) {
          //A cada item que ele estiver contruindo nós chamamos a função
          //E aqui dentro retorno o item que eu quero que aparece na posição
          //Vou colocar logo o GetureDetector para que eu possa clicar na imagem
          //E mostra ela em outra pag

          //RETIREI ISSO POIS UTILIZAVA A IMAGEM DIRETO DA NET
          //Image.network(
          //              ,
          //              height: 300.0,
          //              fit: BoxFit.cover,)
          //snapshot.data["data"][index]["images"]["fixed_height"]["url"]

          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              //Placeholder é uma imagem que vai ficar no local enquanto ela é carregada
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"] ,
                height: 300.0,
                fit: BoxFit.cover,
            ),
            onTap: () {
              //Aqui é quando ele selecionar uma image, e vai ser navegado para outra pag
              //Chamo o MaterialPageRoute, e retorno => a Minha Página
              //Para redirecionar basta eu chamar o construtor passando a roda
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
              );
            },
            //Botão para quando for pressionado, você compartilhe a imagem
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
            },
          );
        }else {
          //Se for o meu item vou retornar o meu item para carregar mais
          return Container(
            //Vou botar o GestureDetector pois vou querer ser capaz de clicar
            child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0,),
                    Text("Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),)
                  ],
                ),
              //No carregar mais vou adicionar o onTap para quando eu tocar no CARREGAR MAIS
              onTap: () {
                  setState(() {
                    //Vai executar o offset e carregar novamente o FilteBuilder
                    _offset +=19;
                  });
              },
            )
          );
        }
        });
  }
}
