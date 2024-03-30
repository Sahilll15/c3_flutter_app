import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final String hintText;
  final String placeholderText;
  final RegExp validationRegEx;
  final void Function(String?) onSaved;


  const CustomFormField({Key? key, required this.hintText,required this.placeholderText, 
  required this.validationRegEx,
  required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:MediaQuery.sizeOf(context).height * 0.1,
      child: TextFormField(
        onSaved: onSaved,
        validator: (value){
          if(value != null && validationRegEx.hasMatch(value)){
            return null;
          }
          return "Please enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: hintText,
          labelText: placeholderText,
        ),
      ),
    );
  }
}