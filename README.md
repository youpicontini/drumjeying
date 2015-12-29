# Drumjing

Play drum with Live recorded video clips based drum.

This project was design by @youpicontini, @raphaelbastide and @ldliquid for their 2016 new year’s party. Drumjing was conceived to let partiers be recorded and “play” the record like pro drumers.

Drumjing is a Processing sketch. It needs a capture device (any webcam), a midi drumkit (can be adapted for any keyboard as well), and a beamer.


## Setup

- Be sure you have [ffmpeg] installed on your system, and the Processing Video library
- Run the script and replace the camera id with capture device, you also may replace the sketch with and height of your capture device
- Replace the absolute path of your Processing sketch in `basePath`

![plan](https://rawgit.com/youpicontini/drumjeying/master/documentation/plan.svg)

1. A cam is activated by a button,
2. A comptuter will record 3sec (defaiult) of the cam’s image and then will add it to a clip list
3. The drummer will be able to play the last 3 recorded clips, and 1 random clip from the clip list
4. What the drumer plays is projected on the wall in real time

## License

[MIT](http://opensource.org/licenses/MIT)
