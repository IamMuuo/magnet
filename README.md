# 🧲 Magnet - Your Academic Data Scraping Superhero! 🦸‍♂️

![Magnet Logo](assets/logo.png)

Welcome to Magnet, your trusty sidekick in the world of web scraping! 🌍

## What is Magnet?

Magnet is a powerful and versatile web scraping engine specifically designed to extract academic data from Daystar University's student portal. It's here to save the day and provide you with the data you need for your academia mobile app. 📚

## Features 🚀

- **Effortless Scraping**: With Magnet, you can effortlessly extract student data from the Daystar University portal. No more manual data entry!

- **Data on Demand**: Get access to a wealth of academic information, from course schedules to student profiles, at the tip of your fingers.

- **Customizable**: Magnet is flexible and customizable to your specific needs. Want to extract more data? No problem! Magnet has your back.

- **Easy Integration**: Seamlessly integrate the scraped data into your academia mobile app and provide a seamless user experience.

## How to Use Magnet 🧲

1. **Installation**: Depend on it on your flutter / Dart project

2. **Configuration**: Configure Magnet with the necessary credentials and settings for Daystar University's student portal.

3. **Scrape Away**: Run Magnet and watch it work its magic! It will scrape the data you need and store it in a format you can use.

4. **Integrate**: Integrate the scraped data into your academia mobile app and provide your users with valuable insights.

## Example Code 📝

```dart
import 'package:magnet/magnet.dart';

void main() {
  final magnet = Magnet("your-username", "your-password");


  // Start scraping data
  final loginState = await magnet.login();

  // Get student Data
  final studentData = await magnet.fetchUserData();

  // Work with the data
   dosomethingWithData(studentData);
}
```

## Support 💪

If you run into any issues, have questions, or just want to chat about web scraping and academia apps, feel free to reach out to our friendly support team at DITA.
