# Magnet 🧲

Magnet is your ultimate scraping engine designed specifically for Daystar University, crafted as an open-source package tailored for Academia, an open-source application. Created by students for students, Magnet simplifies the process of fetching crucial data from Daystar University's online portal, empowering students with easy access to their academic information. 🎓

## Features ✨

- **Seamless Authentication**: Magnet handles the authentication process effortlessly, ensuring secure access to your academic data. 🔐
- **Catering Token Retrieval**: Fetch your catering token hassle-free, making sure you never miss a meal! 🍔
- **Academic Calendar**: Stay updated with the latest academic events and timelines. 📅
- **Transcript Retrieval**: Get your transcript with just a few lines of code, saving you time and effort. 📜
- **Student Audit**: Access your student audit conveniently, keeping track of your academic progress. 📊
- **Fee Statement**: Easily retrieve your fee statement for financial planning. 💰
- **Class Attendance**: Keep tabs on your class attendance with ease. 📝
- **User Details**: Access your user details swiftly, ensuring accurate personal information. 📋
- **User Timetable**: Stay organized with your user timetable readily available. 🕒
- **Timetable**: Fetch the complete timetable effortlessly. ⏰

## Usage 🚀

```dart
import 'package:magnet/magnet.dart';

void main() async {
  // Initialize Magnet with your admission number and password
  final magnet = Magnet('your_admission_number', 'your_password');

  // Authenticate
  final loginResult = await magnet.login();
  if (loginResult.isLeft()) {
    print('Failed to authenticate: ${loginResult.left}');
    return;
  }

  // Fetch Catering Token
  final cateringTokenResult = await magnet.fetchCateringToken();
  if (cateringTokenResult.isLeft()) {
    print('Failed to fetch catering token: ${cateringTokenResult.left}');
    return;
  }
  final cateringToken = cateringTokenResult.right;

  // Fetch Academic Calendar
  final academicCalendarResult = await magnet.fetchAcademicCalendar();
  if (academicCalendarResult.isLeft()) {
    print('Failed to fetch academic calendar: ${academicCalendarResult.left}');
    return;
  }
  final academicCalendar = academicCalendarResult.right;

  // Add more operations as needed...

  print('Catering Token: $cateringToken');
  print('Academic Calendar: $academicCalendar');
}
```

## Get started 🛠️
As per now you have to directly depend on it from github
```yaml

magnet:
 git:
   url: https://github.com/IamMuuo/magnet
     ref: master
```
## Contribution 🤝
Contributions are welcome! Feel free to fork the repository, make changes, and submit pull requests to enhance Magnet and make it even more useful for Daystar University students.

Let's make academic life at Daystar easier and more enjoyable together with Magnet! 🌟

