


import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user.dart';
import 'main_wrapper_state.dart';


class MainWrapperCubit extends Cubit<MainWrapperState> {
  MainWrapperCubit() : super(const MainWrapperState());

  void setBottomNavigationVisibility(bool isVisible) {
    emit(state.copyWith(bottomNAVVisibility: isVisible));
  }

  // Hàm để thay đổi trạng thái hiển thị của Song Control widget
  void setSongControlVisibility(bool isVisible) {
    emit(state.copyWith(songControlVisibility: isVisible));
  }

  Future<void> onBottomNavBarButtonPressed(int index) async {
    emit(state.copyWith(selectedPageIndex: index));
  }

// Các hàm khác sẽ được thêm vào sau này khi bạn mở rộng tính năng
// Ví dụ: loadInitialAccountData(), setBottomNavigationVisibility(), v.v.
}