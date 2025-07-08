import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godly_seed_app/constants/color_palette.dart';
import 'package:godly_seed_app/view/profile_setup/controller/profile_controller.dart';
import 'package:godly_seed_app/view/profile_setup/model/profile_model.dart';

class ProfileSetupScreen extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Set Up Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
       
       
      ),
      body: Obx(() {
        final isKidsProfile = controller.profile.value.type == ProfileType.kids;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isKidsProfile ? Colors.pink[100] : Colors.orange[100],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isKidsProfile ? Colors.pink[300]! : Colors.orange[300]!,
                          width: 2,
                        ),
                      ),
                     
                    ),
                  
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              Center(
                child: Text(
                  isKidsProfile ? 'Kids Profile' : 'Adult Profile',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 32),
           
              _buildFormField(
                label: 'Profile Name',
                child: TextField(
                  controller: controller.nameController,
                  onChanged: controller.updateName,
                  decoration: _getInputDecoration(
                    hintText: 'FullName',
                  ),
                ),
                isRequired: true,
              ),
              
            
              if (isKidsProfile) ...[
                _buildFormField(
                  label: 'Date of Birth',
                  child: TextField(
                    controller: controller.dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _getInputDecoration(
                      hintText: '00-00-0000',
                      suffixIcon: const Icon(Icons.calendar_today, size: 20),
                    ),
                  ),
                  isRequired: true,
                ),
                
                _buildFormField(
                  label: 'Gender',
                  child: DropdownButtonFormField<Gender>(
                    value: controller.profile.value.gender,
                    onChanged: (Gender? value) {
                      if (value != null) {
                        controller.selectGender(value);
                      }
                    },
                    decoration: _getInputDecoration(hintText: 'Select Gender'),
                    items: Gender.values.map((Gender gender) {
                      return DropdownMenuItem<Gender>(
                        value: gender,
                        child: Text(
                          gender == Gender.female ? 'Female' : 'Male',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ),
                  isRequired: true,
                ),
                
                _buildFormField(
                  label: 'Screen Limit',
                  child: TextField(
                    controller: controller.screenTimeController,
                    onChanged: controller.updateScreenTime,
                    decoration: _getInputDecoration(
                      hintText: '3pm - 7pm',
                      suffixIcon: const Icon(Icons.access_time, size: 20),
                    ),
                  ),
                  isRequired: true,
                
                ),
              ],
              
              const SizedBox(height: 40),
            
              
              const SizedBox(height: 24),
              
      
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isLoading.value 
                      ? Colors.grey[400] 
                      : primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Saving Profile...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                ),
              )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormField({
    required String label,
    required Widget child,
    bool isRequired = false,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  InputDecoration _getInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.brown[400]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.selectDateOfBirth(picked);
    }
  }
}