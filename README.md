# Crouton thermal control script

Default max temp is 51 degrees celsius (125 degrees fahrenheit)<br>
(When running Ubuntu 14.04 with unity Toshiba Chromebook 2 does not operate over 125 degrees but when operating with gnome 3.10 and higher i would reccomend this script as it idles with no use around 135 to 140 degrees and Chromebook gets hot.)<br>

I created this script for my Toshiba Chromebook 2 while running crouton because it would run really warm doing simple things like running firefox. And using Chrome OS it wouldnt so even though its probably fine to run it without this i made it just because my electronics are like my babys i treat them very well. Also this script will be going though lots of changes for the next week until i get it perfect to allow you to play Minecraft without the Chromebook getting super warm or hot.

# What to do if you get temp error

If you get an error cant find temp data please open an issue and tell me your temp directory expamples below.

Example(Toshiba Chromebook 2 temp files in crouton):<br>
/sys/class/hwmon/hwmon0/device/temp2_input<br>
/sys/class/hwmon/hwmon0/device/temp3_input<br>
There will be a temp_input for each processor core so make sure you tell me all of your temp_input files.
