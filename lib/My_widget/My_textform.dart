import 'package:flutter/material.dart';

class InputTextForm extends StatefulWidget {

  final Icon icon;
  final String hintText;
  final bool hideinput;
  final TextInputType inputype;
  final String? Function(String?)? validate;
  final String? Function(String?)? onsaved;

  const InputTextForm({
    super.key,
    required this.icon,
    required this.hintText,
    required this.hideinput,
    required this.inputype,
    required this.validate,
    required this.onsaved,
  });

  @override
  State<InputTextForm> createState() => _InputTextFormState();
}

class _InputTextFormState extends State<InputTextForm> {
  late bool _obscureText;
  late bool inerror;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.hideinput; 
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 67.5,

      child: TextFormField(
        keyboardType: widget.inputype,
        obscureText: _obscureText,
        cursorColor: Color(0xFFB2D3E4),
        style: TextStyle(fontSize: 16,color: Color.fromARGB(255, 81, 128, 152),fontWeight: FontWeight.w500),
      
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB2D3E4),width: 2.0),
            borderRadius: BorderRadius.circular(22),
            
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB2D3E4),width: 2.0),
            borderRadius: BorderRadius.circular(22)
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color.fromARGB(255, 215, 60, 49),width: 1.5),
            borderRadius: BorderRadius.circular(22)
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color.fromARGB(255, 215, 60, 49),width: 1.5),
            borderRadius: BorderRadius.circular(22)
          ),
          
          errorStyle: TextStyle(color: Color.fromARGB(255, 215, 60, 49) ,height: 0.75),
      
          prefixIcon: widget.icon,
          prefixIconColor: Color(0xFF4E87C8),
      
          suffixIcon: widget.hideinput ? 
            IconButton(
              style: IconButton.styleFrom(
                overlayColor: Colors.transparent,
              ),
              icon: Icon( _obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: (){
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ) : null,
          suffixIconColor: Color(0xFF4E87C8),
      
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          hint: Text(widget.hintText,style:  TextStyle(fontSize: 15,color: Color(0xFF61889C)),),
        ),
      
        validator: widget.validate,
        
        onSaved: widget.onsaved,
        
      ),
    );
  }
}




