

import 'package:ebook_tuh/constants/app_secure_storage.dart';
import 'package:ebook_tuh/views/audio_book/audio_cubit.dart';
import 'package:ebook_tuh/views/auth/auth_cubit.dart';
import 'package:ebook_tuh/views/auth/enter_otp_page.dart';
import 'package:ebook_tuh/views/auth/login_prompt_screen.dart';
import 'package:ebook_tuh/views/auth/request_reset_password_page.dart';
import 'package:ebook_tuh/views/auth/set_newpassword_page.dart';
import 'package:ebook_tuh/views/auth/sign_up/sign_up_page.dart';
import 'package:ebook_tuh/views/book_reader/book_reader_bloc.dart';
import 'package:ebook_tuh/views/home/home_bloc.dart';
import 'package:ebook_tuh/views/home/home_event.dart';
import 'package:ebook_tuh/views/search/search_cubit.dart';
import 'package:ebook_tuh/views/search/search_page.dart';
import 'package:ebook_tuh/views/subscription_plan/subscription_cubit.dart';
import 'package:ebook_tuh/views/subscription_plan/subscription_plan_page.dart';
import 'package:ebook_tuh/views/user_library/user_library_page.dart';
import 'package:ebook_tuh/views/user_profile/user_cubit.dart';
import 'package:ebook_tuh/views/user_profile/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../views/audio_book/audio_book_page.dart';
import '../views/auth/login/login_page.dart';
import '../views/author/author_page.dart';
import '../views/book_detail/book_detail_page.dart';
import '../views/book_reader/book_reader_page.dart';
import '../views/home/home_view.dart';
import '../views/main_wrapper/main_wrapper.dart';
import '../views/main_wrapper/main_wrapper_cubit.dart';
import '../views/user_library/user_library_cubit.dart';
import '../views/user_profile/edit_profile_page.dart';

class AppNavigation {
  AppNavigation._();

  static String initR = '/home';

  // Các khóa điều hướng toàn cục cho root và shell navigation
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _rootNavigatorHomeKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Home');
  static final _rootNavigatorSearchKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Search');
  static final _rootNavigatorBookReaderKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Book Reader');
  static final _rootNavigatorAudioBookKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Book Audio');
  static final _rootNavigatorDetailBookKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Detail Book');
  static final _rootNavigatorSubscriptionPlanKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Subscription Plan');
  static final _rootNavigatorAuthorKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Author');
  static final _rootNavigatorUserLibraryKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell User Library');
  static final _rootNavigatorSignUpKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Sign Up');
  static final _rootNavigatorSignInKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Sign In');
  static final _rootNavigatorUserProfileKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell User Profile');
  static final _rootNavigatorLoginPromptKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Login Prompt');
  static final _rootNavigatorRequestResetPasswordKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Login Prompt');
  static final _rootNavigatorEnterOTPKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Login Prompt');
  static final _rootNavigatorSetNewPasswordKey =
  GlobalKey<NavigatorState>(debugLabel: 'Shell Login Prompt');


  //Config
  static final GoRouter router = GoRouter(
      initialLocation: initR,
      debugLogDiagnostics: true,
      navigatorKey: _rootNavigatorKey,
      routes: [
        //Main Route
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MultiBlocProvider(
                providers: [
                  // <<< ĐÂY LÀ NƠI BẠN CUNG CẤP Provider >>>
                  BlocProvider(
                    create: (context) => MainWrapperCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => AudioCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => SearchCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => UserLibraryCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => SubscriptionCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => AuthCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => UserCubit(), // Khởi tạo Cubit tại đây
                  ),
                  BlocProvider(
                    create: (context) => HomeBloc()..add(const FirstInitEvent()),
                  ),
                  BlocProvider(
                    create: (context) => BookReaderBloc(),
                  ),
                ],
                child: MainWrapper(
                  navigationShell: navigationShell,
                ),
              );
            },
            branches: [

              //Branch Home
              StatefulShellBranch(navigatorKey: _rootNavigatorHomeKey, routes: [
                GoRoute(
                  path: '/home',
                  name: 'home',
                  builder: (context, state) {
                    final mainWrapperCubit = context.read<MainWrapperCubit>();
                    return HomeView(
                      onBottomNavBarButtonPressed: mainWrapperCubit.onBottomNavBarButtonPressed,
                      key: state.pageKey,
                    );
                  },
                ),
              ]),

              //Branch Search
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorSearchKey,
                  routes: [
                    GoRoute(
                      path: '/searchPage',
                      name: 'searchPage',
                      builder: (context, state) {
                        return SearchView(key: state.pageKey,);
                      },
                    ),
                  ]),

              //Branch User Library
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorUserLibraryKey,
                  routes: [
                    GoRoute(
                      path: '/userLibrary',
                      name: 'userLibrary',
                      builder: (context, state) {
                        return UserLibraryPage(key: state.pageKey,);
                      },
                    ),
                  ]),

              //Branch User Profile
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorUserProfileKey,
                  routes: [
                    GoRoute(
                      path: '/userProfile',
                      name: 'userProfile',
                      builder: (context, state) {
                        return ProfileScreen(key: state.pageKey,);
                      },
                      routes: [
                        GoRoute(
                          path: 'editProfilePage',
                          name: 'editProfilePage',
                          builder: (context, state){

                            return EditProfileScreen(key: state.pageKey,);
                          },
                        ),
                      ]
                    ),
                  ]),

              //Branch SignIn
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorLoginPromptKey,
                  routes: [
                    GoRoute(
                      path: '/loginPrompt',
                      name: 'loginPrompt',
                      builder: (context, state) {
                        return LoginPromptScreen(
                          key: state.pageKey,
                        );
                      },),
                  ]),

              //Branch Subscription
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorSubscriptionPlanKey,
                  routes: [
                    GoRoute(
                      path: '/subscriptionPlan',
                      name: 'subscriptionPlan',
                      builder: (context, state) {
                        return SubscriptionPlansPage();
                      },
                    ),
                  ]),

              //Branch SignIn
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorSignInKey,
                  routes: [
                    GoRoute(
                        path: '/loginPage',
                        name: 'loginPage',
                        builder: (context, state) {
                          return LoginPage(
                            key: state.pageKey,
                          );
                        },),
                  ]),

              //Branch Sign Up
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorSignUpKey,
                  routes: [
                    GoRoute(
                      path: '/registerPage',
                      name: 'registerPage',
                      builder: (context, state) {
                        return SignUpPage(
                          key: state.pageKey,
                        );
                      },),
                  ]),

              //Branch Author
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorAuthorKey,
                  routes: [
                    GoRoute(
                      path: '/authorPage',
                      name: 'authorPage',
                      builder: (context, state) {
                        final Author author=state.extra as Author;
                        return AuthorDetailScreen(author:author,key: state.pageKey,);
                      },),
                  ]),


              //Branch Book Reader
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorBookReaderKey,
                  routes: [
                    GoRoute(
                      path: '/bookReader', // Đường dẫn con, ví dụ: '/detailBook/read'
                      name: 'bookReader', // Tên route vẫn giữ để điều hướng dễ dàng
                      builder: (context, state) {
                        // Lấy toàn bộ đối tượng Book từ state.extra
                        final Book book = state.extra as Book;
                        return BookReaderPage(book: book,epubPath: book.fileUrl!,);
                      },
                    ),
                  ]),

              //Branch Book Reader
              StatefulShellBranch(
                  navigatorKey: _rootNavigatorAudioBookKey,
                  routes: [
                    GoRoute(
                      path: '/audioBook',
                      name: 'audioBook',
                      builder: (context, state) {
                        // Lấy toàn bộ đối tượng Book từ state.extra
                        final Map<String, dynamic>? extraData = state.extra as Map<String, dynamic>?;

                        final Book book = extraData?['book'] as Book;
                        final String? authorName = extraData?['authorName'] as String?;
                        return AudioBookPage(book: book,authorName: authorName,);
                      },
                    ),
                  ]),

              //Branch Detail Book
              StatefulShellBranch(
                navigatorKey: _rootNavigatorDetailBookKey,
                routes: [
                  GoRoute(
                    path: '/detailBook',
                    name: 'detailBook',
                    builder: (context, state) {
                      final book = state.extra as Book;
                      return BookDetailPage(initialBook: book);
                    },
                  ),
                  // Nếu bạn có route '/bookReader' ở đây trước đó, hãy xóa nó đi
                ],
              ),


              //Branch request reset password
              StatefulShellBranch(
                navigatorKey: _rootNavigatorRequestResetPasswordKey,
                routes: [
                  GoRoute(
                    path: '/requestResetPassword',
                    name: 'requestResetPassword',
                    builder: (context, state) {
                      return RequestPasswordResetScreen(key: state.pageKey,);
                    },
                  ),
                  // Nếu bạn có route '/bookReader' ở đây trước đó, hãy xóa nó đi
                ],
              ),

              //Branch enter otp
              StatefulShellBranch(
                navigatorKey: _rootNavigatorEnterOTPKey,
                routes: [
                  GoRoute(
                    path: '/enterOTPPage',
                    name: 'enterOTPPage',
                    builder: (context, state) {
                      final String email=state.extra as String;
                      return EnterOtpScreen(key: state.pageKey,email: email,);
                    },
                  ),
                  // Nếu bạn có route '/bookReader' ở đây trước đó, hãy xóa nó đi
                ],
              ),

              //Branch Set New Password
              StatefulShellBranch(
                navigatorKey: _rootNavigatorSetNewPasswordKey,
                routes: [
                  GoRoute(
                    path: '/setNewPassword',
                    name: 'setNewPassword',
                    builder: (context, state) {
                      Map<String,dynamic> result=state.extra as Map<String,dynamic>;
                      return SetNewPasswordScreen(key: state.pageKey,email: result['email'],otp: result['otp'],);
                    },
                  ),
                  // Nếu bạn có route '/bookReader' ở đây trước đó, hãy xóa nó đi
                ],
              ),

            ]),
      ]);
}
