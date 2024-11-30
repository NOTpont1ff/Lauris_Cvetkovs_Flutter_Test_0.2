import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gif_with_bloc/search/UI/Enter_text.dart';
import 'package:gif_with_bloc/search/UI/Build_AppBar.dart';
import 'package:gif_with_bloc/search/UI/GIF_tile_widget.dart';
import 'package:gif_with_bloc/search/UI/No_Gifs_Found.dart';
import 'package:gif_with_bloc/search/UI/SearchDetail.dart';
import 'package:gif_with_bloc/search/bloc/search_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchBloc searchBloc = SearchBloc();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    searchBloc.add(InitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      bloc: searchBloc,
      listenWhen: (previous, current) => current is SearchActionState,
      buildWhen: (previous, current) => current is! SearchActionState,
      listener: (context, state) {},
      builder: (context, state) {
        switch (state.runtimeType) {
          case SearchLoadingState:
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case SearchInitial:
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
              body: Container(
                  child: Column(
                children: [
                  BuildAppbar(),
                  Text(
                    '',
                    style: TextStyle(fontSize: 10),
                  ),
                  _buildSearchBar(),
                  EnterText(),
                ],
              )),
            );

          case SearchLoadedSuccessState:
            final successState = state as SearchLoadedSuccessState;
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
              body: Container(
                  child: Column(
                children: [
                  BuildAppbar(),
                  Text(
                    '',
                    style: TextStyle(fontSize: 10),
                  ),
                  _buildSearchBar(),
                  Flexible(
                    child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent * 0.9) {
                            searchBloc.add(LoadMoreGifs(
                                text: _textController.text.trim()));
                          }
                          return false;
                        },
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0.1,
                            mainAxisSpacing: 0.1,
                            childAspectRatio: 1,
                          ),
                          itemCount: successState.gifs.length + 1,
                          itemBuilder: (context, index) {
                            if (index == successState.gifs.length) {
                              return Center(
                                child: Text(
                                  'No more\n GIFs :(',
                                  style: TextStyle(
                                    fontSize: 29,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                print(
                                    'GIF clicked: ${successState.gifs[index].title}');
                                searchBloc.add(
                                    GifClicked(gif: successState.gifs[index]));
                              },
                              child: GifTileWidget(
                                gifModel: successState.gifs[index],
                              ),
                            );
                          },
                        )),
                  ),
                ],
              )),
            );

          case SearchDetailState:
            final successState = state as SearchDetailState;
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
              body: Container(
                  child: Column(
                children: [
                  BuildAppbar(),
                  Text(
                    '',
                    style: TextStyle(fontSize: 10),
                  ),
                  _buildSearchBar(),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          searchBloc.add(SearchButtonClicked(
                              text: _textController.text.trim()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 79, 199, 254),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_left, color: Colors.white),
                            Text(
                              'Go Back',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                  SearchDetail(gifModel: successState.gif)
                ],
              )),
            );
          case NoGifsFoundState:
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
              body: Container(
                  child: Column(
                children: [
                  BuildAppbar(),
                  Text(
                    '',
                    style: TextStyle(fontSize: 10),
                  ),
                  _buildSearchBar(),
                  NoGifsFound(),
                ],
              )),
            );
          case SearchErrorState:
            final errorState = state as SearchErrorState;
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 39, 39, 39),
              body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 10),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Text(
                        errorState.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.blue),
                      ),
                      onPressed: () {
                        searchBloc.add(InitialEvent());
                      },
                      child: Text('Go to the initial page',
                          style: TextStyle(fontSize: 17)),
                    )
                  ])),
            );
          default:
            return SizedBox();
        }
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(7.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17.0),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color.fromARGB(255, 79, 199, 254), width: 4)),
        child: TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: 'Search for GIFs',
            labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            suffixIcon: Icon(
              Icons.search_outlined,
              size: 30.0,
            ),
          ),
          cursorColor: Color(0xFF4facfe),
          onChanged: (value) {
            searchBloc.add(SearchButtonClicked(text: value.trim()));
          },
        ),
      ),
    );
  }
}