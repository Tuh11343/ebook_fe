

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FirstInitEvent extends HomeEvent {

  const FirstInitEvent();
}

class UpdateUserEvent extends HomeEvent {

  const UpdateUserEvent();

  @override
  List<Object> get props => [];
}