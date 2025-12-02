import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nornsabai/My_widget/My_alert.dart';
import 'package:nornsabai/My_widget/My_textform.dart';
import 'package:nornsabai/My_widget/Mybutton_log_and_sigup.dart';
import 'package:nornsabai/My_widget/My_profileedit.dart';
import 'package:nornsabai/model/reuse_model/color_model.dart';
import 'package:toastification/toastification.dart';

class Account extends StatefulWidget {
  final String userDocId;
  final Map<String, dynamic>? userdata;

  Account({super.key, required this.userDocId, this.userdata});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  String? _selectedGender;
  bool _isLoading = true;

  final List<String> _genders = ["Male", "Female"];

  @override
  void initState() {
    super.initState();
    if (widget.userdata != null) {
      _initializeData(widget.userdata!);
    } else {
      _fetchUserData();
    }
  }


  // set textfield
  void _initializeData(Map<String, dynamic> data) {
    _usernameController.text = data['username'] ?? '';
    _passwordController.text = data['password'] ?? '';
    _emailController.text = data['email'] ?? '';
    _phoneController.text = (data['phoneNumber'] ?? '').toString();
    
    if (data['detail'] != null) {
      _selectedGender = data['detail']['gender'];
      _ageController.text = (data['detail']['age'] ?? '').toString();
      _weightController.text = (data['detail']['weight'] ?? '').toString();
      _heightController.text = (data['detail']['height'] ?? '').toString();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("General user")
          .doc(widget.userDocId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _initializeData(data);
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // update profile
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {

        MyDiaologAlertLoad(
          context: context,
          desscrip: "Progessing ...",
          pop: false
        );


        await FirebaseFirestore.instance
            .collection("General user")
            .doc(widget.userDocId)
            .update({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': int.tryParse(_phoneController.text.trim()) ?? 0,
          'detail': {
            'gender': _selectedGender,
            'age': int.tryParse(_ageController.text.trim()),
            'weight': double.tryParse(_weightController.text.trim()),
            'height': double.tryParse(_heightController.text.trim()),
          }
        });

        Navigator.pop(context);

        MyDiaologAlertSuccess(
          context: context,
          whenSuccess: "Update profile success!",
        );
      } catch (e) {
        Navigator.pop(context);
        MyDiaologAlertFail(
          context: context,
          whenFail: "Update profile error! ,please try again",
        );
      }
    }
  }

  void _showToast(String title, String description, ToastificationType type) {
    toastification.show(
      context: context,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(description, style: TextStyle(color: Colors.grey, fontSize: 12)),
      type: type,
      style: ToastificationStyle.flat,
      autoCloseDuration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [BgColor.Bg2Gradient.color_code, BgColor.Bg2.color_code],
            stops: [0.0, 0.1],
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 50,right: 50,top: 0),
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                                      
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.arrow_back_rounded,color: Colors.white,size: 35,),
                                      SizedBox(width: 10,),
                                      Text("Account",style: TextStyle(color: Colors.white,fontSize: 32.5),),
                                    ],
                                  )
                                )
                              ],
                            ),
                          ),
                          
                                      
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              )
                            ),
                            child: Icon(Icons.person,color: Colors.white,size: 170,),
                          ),
                          SizedBox(height: 30),
                      
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20,horizontal: 0),
                            child: Column(
                              children: [
                                
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white70,
                                      width: 0.75
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    children: [
                      
                                      // username
                                      ProfileEdit(
                                        title: "Username",
                                        inputcontroller: _usernameController,
                                        hide: false,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.text,
                                      ),
                      
                                      ProfileEdit(
                                        title: "Email",
                                        inputcontroller: _emailController,
                                        hide: false,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.text,
                                      ),
                                      
                                      // passsword
                                      ProfileEdit(
                                        title: "Password",
                                        inputcontroller: _passwordController,
                                        hide: true,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.text,
                                      ),
                      
                                      ProfileEdit(
                                        title: "Phone number",
                                        inputcontroller: _phoneController,
                                        hide: false,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.number,
                                      ),
                      
                                    ],
                                  )
                                ),
                      
                                SizedBox(height: 30,),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white70,
                                      width: 0.75
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    children: [
                                      
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 12.5),
                                        child: Row(
                                          children: [
                                            
                                            Text("Gender : ",style: TextStyle(color: Colors.white,fontSize: 27.5),),
                                            SizedBox(width: 10,),
                                            
                                            Expanded(
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: _selectedGender,
                                                  hint: Text("Select Gender",style: TextStyle(color: Colors.white70,fontSize: 27.5),),
                                                  dropdownColor: BgColor.Bg2.color_code,
                                                  isExpanded: true,
                                                  items: _genders.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value,style: TextStyle(color: Colors.white,fontSize: 27.5),),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _selectedGender = newValue;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          
                                            Padding(
                                              padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                                              child: IconButton(
                                                style: IconButton.styleFrom(
                                                  foregroundColor: Colors.transparent,
                                                ),
                                                icon: Icon(Icons.edit,color: Colors.white,size: 32,),
                                                onPressed: (){},
                                              ),
                                            ),                                     
                                          ],
                                        ),
                                      ),
                      
                      
                                      // age
                                      ProfileEdit(
                                        title: "Age",
                                        inputcontroller: _ageController,
                                        hide: false,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.number,
                                      ),
                      
                                      // weight
                                      ProfileEdit(
                                        title: "Weight",
                                        inputcontroller: _weightController,
                                        hide: false,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.number,
                                      ),
                                      
                                      // height
                                      ProfileEdit(
                                        title: "Height",
                                        inputcontroller: _heightController,
                                        hide: false,
                                        userdocId: widget.userDocId,
                                        type: TextInputType.number,
                                      ),
                      
                         
                      
                                    ],
                                  )
                                ),
                      
                                SizedBox(height: 30,),
                      
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 87, 141, 203),
                                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 90),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)
                                    ),
                                  ),
                                  onPressed: () async {
                                    _updateProfile();
                                  },
                                  child: Text("Update Profile",style: TextStyle(color: Colors.white,fontSize: 30),)
                                ),
                      
                               
                              ],
                            )
                          )
                          
                          
                        ],
                      ),
                    ),
                  ),
              ),
            ),
      ),
    );
  }
}



  // Future<void> _pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  //   if (image != null) {
  //     setState(() {
  //       _imageFile = File(image.path);
  //     });
  //     _uploadImage();
  //   }
  // }

  // Future<void> _uploadImage() async {
  //   if (_imageFile == null) return;

  //   try {
  //     String fileName = 'profile_images/${widget.userDocId}.jpg';
  //     Reference ref = FirebaseStorage.instance.ref().child(fileName);
  //     UploadTask uploadTask = ref.putFile(_imageFile!);
      
  //     TaskSnapshot snapshot = await uploadTask;
  //     String downloadUrl = await snapshot.ref.getDownloadURL();

  //     await FirebaseFirestore.instance
  //         .collection("General user")
  //         .doc(widget.userDocId)
  //         .update({'profile_img': downloadUrl});

  //     setState(() {
  //       _profileImgUrl = downloadUrl;
  //     });

  //     _showToast("Success", "Profile image updated!", ToastificationType.success);
  //   } catch (e) {
  //     _showToast("Error", "Failed to upload image: $e", ToastificationType.error);
  //   }
  // }

  // -----------------------------------

  // InputTextForm(
  //   icon: Icon(Icons.person),
  //   hintText: "Username",
  //   hideinput: false,
  //   inputype: TextInputType.text,
  //   controller: _usernameController,
  //   validate: RequiredValidator(errorText: "Required"),
  //   onsaved: (val) {},
  // ),

  // InputTextForm(
  //   icon: Icon(Icons.phone),
  //   hintText: "Phone Number",
  //   hideinput: false,
  //   inputype: TextInputType.phone,
  //   controller: _phoneController,
  //   validate: RequiredValidator(errorText: "Required"),
  //   onsaved: (val) {},
  // ),

  // SizedBox(height: 10),

  // // Gender Dropdown
  // Container(
  //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //   decoration: BoxDecoration(
  //     color: Colors.white,
  //     borderRadius: BorderRadius.circular(22),
  //     border: Border.all(color: Color(0xFFB2D3E4), width: 2.0),
  //   ),
  //   child: DropdownButtonHideUnderline(
  //     child: DropdownButton<String>(
  //       value: _selectedGender,
  //       hint: Text("Select Gender"),
  //       isExpanded: true,
  //       items: _genders.map((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value),
  //         );
  //       }).toList(),
  //       onChanged: (newValue) {
  //         setState(() {
  //           _selectedGender = newValue;
  //         });
  //       },
  //     ),
  //   ),
  // ),

  // SizedBox(height: 15),

  // Row(
  //   children: [
  //     Expanded(
  //       child: InputTextForm(
  //         icon: Icon(Icons.cake),
  //         hintText: "Age",
  //         hideinput: false,
  //         inputype: TextInputType.number,
  //         controller: _ageController,
  //         validate: (val) => null, // Optional
  //         onsaved: (val) {},
  //       ),
  //     ),
  //     SizedBox(width: 10),
  //     Expanded(
  //       child: InputTextForm(
  //         icon: Icon(Icons.monitor_weight),
  //         hintText: "Weight (kg)",
  //         hideinput: false,
  //         inputype: TextInputType.number,
  //         controller: _weightController,
  //         validate: (val) => null, // Optional
  //         onsaved: (val) {},
  //       ),
  //     ),
  //   ],
  // ),

  // InputTextForm(
  //   icon: Icon(Icons.height),
  //   hintText: "Height (cm)",
  //   hideinput: false,
  //   inputype: TextInputType.number,
  //   controller: _heightController,
  //   validate: (val) => null, // Optional
  //   onsaved: (val) {},
  // ),

  // SizedBox(height: 20),

  // LogAndSignButton(
  //   text: "Update Profile",
  //   onpressed: _updateProfile,
  // ),

  // SizedBox(height: 10),

  // TextButton(
  //   onPressed: _changePassword,
  //   child: Text("Change Password", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
  // ),