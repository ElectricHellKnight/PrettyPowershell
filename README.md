# PrettyPowershell #

Because why should Linux users have all the fun with their prompts?

This script allows you to easily customize your powershell prompt. You can adjust what is shown, change the colors, see time of the last command, get a warning if you're running as admin, etc.

Run `$Profile` to figure out where to put this if you are unsure.

To toggle what's show, change these values:
 ![Where to change colors[./readmepics/setoptions.png]

To change the colors, change these values (use PowerShell color names, see: https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell):
 ![Where to change colors[./readmepics/setcolors.png]
 
There is some variation on how the colors are displayed between systems, so play around and see what looks best to you.

Needless to say, scripts must be enabled.

Elevated warning:
 ![A warning shows when in elevated][./readmepics/elevated.png]
 
Date/Time:
 ![The date is displayed before the prompt][./readmepics/date.png]
 
Shorthand working path:
 ![The prompt shows the name of the working directory][./readmepics/shortpath.png]
 
Full working path:
 ![The prompt shows the full working path][./readmepics/longpath.png]
 
Original credit to: https://commandline.ninja/customize-pscmdprompt/ I took this and reworked it so it's far easier to customize.