import 'package:flutter/cupertino.dart';

import '../../constants/images.dart';

class SectionPartnershipImageWithHeader extends StatelessWidget {
  final String headerTitle;
  final String imageString;

  const SectionPartnershipImageWithHeader({Key? key, required this.headerTitle, required this.imageString})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: AssetImage(imageString), fit: BoxFit.fitWidth)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                headerTitle,
                style: TextStyle(fontSize: 13.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
