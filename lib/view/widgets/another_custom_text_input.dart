import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/constants/color_palette.dart';
import 'package:movie_app/view/widgets/custom_container_widget.dart';


import 'animation_widgets/easein_anim.dart';

typedef CustomCallBack = String Function(String value);

class AnotherCustomTextField extends StatefulWidget {
  final TextInputType? textInputType;
  final String? hintText;
  final bool? ignoreCursor;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? contentPadding;
  final String? defaultText;
  final FocusNode? focusNode;
  late final bool? obscureText;
  final bool togglePassword;
  final bool? enforceLength;
  final int? maxLength;
  final bool enabled;
  final bool? autofocus;
  final dynamic Function(String)? onChange;
  final Function? validator;
  final TextEditingController? controller;
  final String? Function(String)? functionValidate;
  final String? parametersValidate;
  final int? maximumLines;
  final TextInputAction? actionKeyboard;
  final Function? onSubmitField;
  final Function? onFieldTap;
  final String? label;
  final bool isLoading;
  List<TextInputFormatter>? inputFormatters;

  AnotherCustomTextField(
      {required this.hintText,
      this.focusNode,
      this.textInputType,
      this.defaultText,
      this.ignoreCursor = false,
      this.maximumLines = 1,
      this.onTap,
      this.autofocus = false,
      this.enabled = true,
      this.obscureText = false,
      this.togglePassword = false,
      this.controller,
      this.validator,
      this.functionValidate,
      this.parametersValidate,
      this.actionKeyboard = TextInputAction.next,
      this.onSubmitField,
      this.onFieldTap,
      this.prefixIcon,
      this.suffixIcon,
      this.label,
      this.contentPadding,
      this.maxLength = 100,
      this.enforceLength = false,
      this.isLoading = false,
      this.inputFormatters,
      this.onChange});

  @override
  State<AnotherCustomTextField> createState() => _AnotherCustomTextFieldState();
}

class _AnotherCustomTextFieldState extends State<AnotherCustomTextField> {
  double bottomPaddingToError = 12;
  late bool _obscureText;

  @override
  void initState() {
    _obscureText = widget.obscureText!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: primaryColor,
      ),
      child: EaseInAnimationWidget(
        child: CustomContainer(
          backgroundColor: inputBackgroundColor,
          borderRadius: 10,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.label != null
                  ? Text(
                      widget.label!,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).dividerColor,
                        fontSize: 10.0,
                      ),
                    )
                  : Container(),
              widget.label != null
                  ? const SizedBox(
                      height: 0.0,
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  obscureText: _obscureText,
                  keyboardType: widget.textInputType,
                  readOnly: widget.ignoreCursor!,
                  enabled: widget.isLoading ? false : widget.enabled,
                  autofocus: widget.autofocus!,
                  onChanged: (value) => widget.onChange != null
                      ? widget.onChange!(value)
                      : commonValidation(value, widget.label!),
                  maxLength: widget.maxLength,
                  textInputAction: widget.actionKeyboard,
                  maxLines: widget.maximumLines,
                  focusNode: widget.focusNode,
                  style: TextStyle(
                      fontSize: 13.0,
                      height: 0,
                      color: widget.isLoading
                          ? Colors.grey[400]
                          : Theme.of(context).hintColor),
                  initialValue: widget.defaultText,
                  decoration: InputDecoration(
                    counterText: "",
                    fillColor: inputBackgroundColor2,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.isLoading
                        ? spinner()
                        : widget.suffixIcon ??
                            (widget.togglePassword ? visible() : null),
                    suffixIconConstraints: widget.isLoading
                        ? const BoxConstraints(minHeight: 14)
                        : null,
                    filled: true,
                    hintText: widget.hintText,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Colors.transparent, width: 0.0),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    hintStyle: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400),
                    contentPadding: EdgeInsets.only(
                        top: 0,
                        bottom: bottomPaddingToError,
                        left: widget.contentPadding ?? 5.0,
                        right: widget.contentPadding ?? 0.0),
                    isDense: true,
                    errorStyle:
                        const TextStyle(color: Colors.red, fontSize: 12.0),
                    errorBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(13.0),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: primaryColor),
                    ),
                  ),
                  controller: widget.controller,
                  inputFormatters: widget.inputFormatters,
                  validator: (value) => widget.functionValidate != null
                      ? widget.functionValidate!(value!)
                      : commonValidation(value!, widget.label!),
                  onFieldSubmitted: (value) {
                    if (widget.onSubmitField != null) widget.onSubmitField!();
                  },
                  onTap: () {
                    if (widget.onFieldTap != null) widget.onFieldTap!();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconButton visible() {
    return IconButton(
      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
      onPressed: () {
        setState(() {
       
          _obscureText = !_obscureText;
        });
      },
    );
  }

  SizedBox spinner() {
    return const SizedBox(
      height: 14,
      width: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

String? commonValidation(String value, String fieldName) {
  var required = requiredValidator(value, fieldName);
  if (required != null) {
    return required;
  }
  return null;
}

String? requiredValidator(value, messageError) {
  if (value.isEmpty) {
    return "$messageError is required";
  }
  return null;
}

void changeFocus(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}
