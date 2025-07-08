import 'package:equatable/equatable.dart';

class MainWrapperState extends Equatable {
  final bool songControlVisibility;
  final bool bottomNAVVisibility;
  final int selectedPageIndex;

  const MainWrapperState({
    this.songControlVisibility = false,
    this.bottomNAVVisibility=true,
    this.selectedPageIndex=0,
  });

  MainWrapperState copyWith({
    bool? songControlVisibility,
    bool? bottomNAVVisibility,
    int? selectedPageIndex,
  }) {
    return MainWrapperState(
      songControlVisibility: songControlVisibility ?? this.songControlVisibility,
      bottomNAVVisibility: bottomNAVVisibility ?? this.bottomNAVVisibility,
        selectedPageIndex: selectedPageIndex ?? this.selectedPageIndex
    );
  }

  @override
  List<Object?> get props => [
    songControlVisibility,
    bottomNAVVisibility,
    selectedPageIndex
  ];
}