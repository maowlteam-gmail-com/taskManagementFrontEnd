import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maowl/screens/siteScreen/widgets/customNumButton.dart';

class CustomNumContainer extends StatelessWidget {
  const CustomNumContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 555.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            SizedBox(height: 30.h,),
            Text(
              'We Take Pride in Our Numbers',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w700,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 44.h,
            ),
            Wrap(
             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
             spacing: 20, // Adjust the spacing between the widgets
          runSpacing: 10,
              children: [
                CustomNumButtom(text1: '7+', text2: 'Years of\nExperience'),
             //   SizedBox(width: 30,),
                CustomNumButtom(text1: '30+', text2: 'Business\nPartners'),
              //  SizedBox(width: 30,),
                CustomNumButtom(text1: '50+', text2: 'Products\nDeveloped'),
               // SizedBox(width: 30,),
                CustomNumButtom(text1: '1000+', text2: 'Clients\nServed'),
              //  SizedBox(width: 30,),
                CustomNumButtom(text1: '7+', text2: 'Field’s of\nExpertise'),
              ],
            ),
        
          ],
        ),
      ),
    );
  }
}
