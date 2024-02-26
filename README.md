# Flutter Autozoom
![Static Badge](https://img.shields.io/badge/GSoC'24%20Qualification%20Task-8A2BE2)


A Flutter app which detects the objects using Tensor Flow's [tflite_flutter](https://pub.dev/packages/tflite_flutter) plugin & zooms in when tapped on any object detected.

Also saves the zoomed in image to the photos or DCIM folder on IOS & Android respectively.

 - [Android APK download from here](https://drive.google.com/file/d/1wYmIvahszKV9sy-XYFArbeKz0GrJkmZR/view?usp=sharing)
 - Currently, for IOS, you need to build for your own device locally. I have submitted the app for test Flight, once approved, I will share the link with you can directly install app from test flight. OR send me your email on slack DM, I can send you the invite for internal testing.

## App Videos
<p align="center">
 
 ### Android 
[![Android Demo](https://img.youtube.com/vi/m4n8GqSb_yQ/0.jpg)](https://www.youtube.com/watch?v=m4n8GqSb_yQ)


### iOS
[![iOS Demo](https://img.youtube.com/vi/AkChtczrh6g/0.jpg)](https://www.youtube.com/watch?v=AkChtczrh6g)

</p>

# Building app on your machine.

 1. `git clone`
 2. `flutter pub get`
 3. connect your physical device.
 Note: for iOS:
	 pod files for tensorflow are very big, so for the first time it will take much longer to build
**To see what's happening**
 4. `cd ios`
 5. `pod repo update`
 6. `pod install --verbose`
 it will give you feedback of every step.

	

# About the App



***Flutter Packages Used***

 - camera

- permission_handler

- intl

- tflite_flutter

- image

- exif

- image_gallery_saver

  




a 0xharkirat (Harkirat Singh) 🦅 production.  

> Creating Better technologies for the greater good of Humanity.




