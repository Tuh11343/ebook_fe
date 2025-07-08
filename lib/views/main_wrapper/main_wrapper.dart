import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../widgets/song_control.dart';
import 'main_wrapper_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main_wrapper_state.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class MainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  @override
  State<MainWrapper> createState() => MainWrapperStatefulState();
}

class MainWrapperStatefulState extends State<MainWrapper> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainWrapperCubit, MainWrapperState>(
      buildWhen: (previous, current) {
        return previous.bottomNAVVisibility != current.bottomNAVVisibility ||
            previous.songControlVisibility != current.songControlVisibility ||
            previous.selectedPageIndex != current.selectedPageIndex;
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            bottomNavigationBar: state.bottomNAVVisibility
                ? SlidingClippedNavBar(
                    backgroundColor: Colors.white,
                    onButtonPressed: (index) {
                      context
                          .read<MainWrapperCubit>()
                          .onBottomNavBarButtonPressed(index);
                    },
                    iconSize: 20,
                    activeColor: Colors.black,
                    selectedIndex: state.selectedPageIndex,
                    barItems: [
                      BarItem(title: 'Home', icon: Icons.home_rounded),
                      BarItem(title: 'Search', icon: Icons.search_rounded),
                      BarItem(
                          title: 'Favorite', icon: Icons.local_library_rounded),
                      BarItem(title: 'User', icon: Icons.person),
                    ],
                  )
                : null,
            body: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  // BlocListener vẫn cần ở đây để xử lý side-effect điều hướng GoRouter
                  child: BlocListener<MainWrapperCubit, MainWrapperState>(
                    listenWhen: (previous, current) =>
                        previous.selectedPageIndex != current.selectedPageIndex,
                    listener: (context, state) async{

                      if(state.selectedPageIndex==3||state.selectedPageIndex==2){
                        User? user=await AppStorage.getUser();
                        if(user==null){
                          widget.navigationShell.goBranch(
                            4,
                            initialLocation: state.selectedPageIndex ==
                                widget.navigationShell.currentIndex,
                          );
                        }else{
                          widget.navigationShell.goBranch(
                            state.selectedPageIndex,
                            initialLocation: state.selectedPageIndex ==
                                widget.navigationShell.currentIndex,
                          );
                        }
                      }else{
                        widget.navigationShell.goBranch(
                          state.selectedPageIndex,
                          initialLocation: state.selectedPageIndex ==
                              widget.navigationShell.currentIndex,
                        );
                      }
                    },
                    child: widget.navigationShell,
                  ),
                ),
                state.songControlVisibility
                    ? const Positioned(
                        bottom: 0,
                        child: SongControl(),
                        // child: Container(),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }
}
