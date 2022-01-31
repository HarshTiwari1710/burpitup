import 'dart:convert';
import 'dart:io';
import 'package:burpitup/Models/recipe.dart';
import 'package:burpitup/recipe_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<RecipeModel> recipes = <RecipeModel>[];
  TextEditingController textEditingController = new TextEditingController();
  String appId = 'ffcbf8ee';
  String appKey = 'ebe6100a1c77c883e31738bddb813c5f	';
  getRecipies(String query)async{
    String url = "https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=ffcbf8ee&app_key=ebe6100a1c77c883e31738bddb813c5f";
    var response = await http.get(Uri.parse(url));
    Map<String,dynamic> jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element){
      print(element.toString());
      RecipeModel recipeModel = RecipeModel(url: '',image: '', label: '', source: '',);
      recipeModel = RecipeModel.fromMap(element['recipe']);
      recipes.add(recipeModel);
    });
    setState(() {
      print("${recipes.toString()}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xFFC72848),
                  Color(0xFFF8A20D)
                ]
              )
            ),
          ),
          SingleChildScrollView(

          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40,vertical: Platform.isIOS?60:24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: kIsWeb?MainAxisAlignment.start:MainAxisAlignment.center,
                  children: const <Widget>[
                    Text('Burp',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.white),),
                    Text('ItUp',style: TextStyle(color: Colors.blueAccent,fontSize: 18,fontWeight: FontWeight.w500),)
                  ],
                ),
                const SizedBox(height: 30,),
                const Text('What will You cook?',style: const TextStyle(fontSize: 20,color: Colors.white),),
                const SizedBox(height: 8,),
                const Text('Just Enter the indgredients and we will show the best recipe for you',style: TextStyle(fontSize: 15,color: Colors.white)),
                const SizedBox(height: 30,),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter the Ingredients',
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.5),
                            ),
                           ),
                          style: TextStyle(
                            color: Colors.white
                          ),
                          controller: textEditingController,
                        ),
                      ),
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: (){
                          if(textEditingController.text.isNotEmpty){
                            getRecipies(textEditingController.text);
                            print('Do it');
                          }else{
                            print('Do not do it');
                          }
                        },
                        child: Container(
                          child: Icon(Icons.search,color: Colors.white,),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                Container(
                  child: GridView(
                    shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200, mainAxisSpacing: 10.0
                      ),
                    children: List.generate(recipes.length, (index) {
                      return GridTile(
                          child: RecipieTile(
                            url: recipes[index].url,
                            desc: recipes[index].source,
                            title: recipes[index].label,
                            imgUrl: recipes[index].image,


                          ));
                    }),
                  ),
                )
              ],
            ),
          )
          )
        ],
      ),

    );
  }
}
class RecipieTile extends StatefulWidget {
   String title, desc, imgUrl, url;

  RecipieTile({required this.title,required this.desc,required this.imgUrl,required this.url});

  @override
  _RecipieTileState createState() => _RecipieTileState();
}

class _RecipieTileState extends State<RecipieTile> {
  _launchURL(String url) async {
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (kIsWeb) {
              _launchURL(widget.url);
            } else {
              print(widget.url + " this is what we are going to see");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecipeView(
                        postUrl: widget.url,
                      )));
            }
          },
          child: Container(
            margin: EdgeInsets.all(15),
            child: Stack(
              children: <Widget>[
                Image.network(
                  widget.imgUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 30,),
                Container(
                  width: 200,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white30, Colors.white],
                          begin: FractionalOffset.centerRight,
                          end: FractionalOffset.centerLeft)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontFamily: 'Overpass'),
                        ),
                        Text(
                          widget.desc,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              fontFamily: 'OverpassRegular'),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GradientCard extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final String topColorCode;
  final String bottomColorCode;

  GradientCard(
      {required this.topColor,
        required this.bottomColor,
        required this.topColorCode,
        required this.bottomColorCode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                Container(
                  height: 160,
                  width: 180,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [topColor, bottomColor],
                          begin: FractionalOffset.topLeft,
                          end: FractionalOffset.bottomRight)),
                ),
                Container(
                  width: 180,
                  alignment: Alignment.bottomLeft,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.white30, Colors.white],
                          begin: FractionalOffset.centerRight,
                          end: FractionalOffset.centerLeft)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          topColorCode,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          bottomColorCode,
                          style: TextStyle(fontSize: 16, color: bottomColor),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

