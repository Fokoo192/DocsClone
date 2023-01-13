import 'dart:convert';
import 'package:docs_clone/constants.dart';
import 'package:docs_clone/models/error_model.dart';
import 'package:docs_clone/models/user_model.dart';
import 'package:docs_clone/repository/local_storage_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:docs_clone/constants.dart';


final authRepoProvider = Provider(
  // using provider so there is no need to create GoogleSignIn object continously
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepo: LocalStorageRepo()
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);


class AuthRepository {
  final GoogleSignIn _googleSignIn; //made it private so only AuthRepository can access it
  final Client _client;
  final LocalStorageRepo _localStorageRepo;

  AuthRepository({required GoogleSignIn googleSignIn, required Client client, required LocalStorageRepo localStorageRepo})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepo = localStorageRepo;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(error: "Some unexpected error occured", data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
            name: user.displayName!,
            email: user.email,
            profilePic: user.photoUrl!,
            uid: "",
            token: "");
      var res = await _client.post(Uri.parse("$host/api/signup"), 
      body: userAcc.toJson(),
      headers: {"Content-Type" : "application/json; charset=UTF-8"}, //telling the server it is in json format
      );

      switch (res.statusCode) {
        case 200:
        final newUser = userAcc.copyWith(
          uid: jsonDecode(res.body)["user"]["_id"],
          token: jsonDecode(res.body)["token"]
        );
        error = ErrorModel(error: null, data: newUser);
        _localStorageRepo.setToken(newUser.token);
        break;
      }
      }

    } catch (e) {
      print(e);
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
  
  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(error: "Some unexpected error occured", data: null);
    try {
      String? token = await _localStorageRepo.getToken(); //using local storage to see if the token is already generated
      if (token != null) {
        var res = await _client.get(Uri.parse("$host/"), 
        headers: {"Content-Type" : "application/json; charset=UTF-8", "x-auth-token": token} //tellin the server it is in json format
        );
        switch (res.statusCode) {
          case 200:
          final newUser = UserModel.fromJson(jsonEncode(jsonDecode(res.body)["user"]))
          .copyWith(token: token);
          error = ErrorModel(error: null, data: newUser);
          _localStorageRepo.setToken(newUser.token);
          break;
        }
      }    
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
  void signOut() async {
    //signout from google 
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
    _localStorageRepo.setToken("");
  }
}
