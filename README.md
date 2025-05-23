# EZ2 COOP 
My copy of a mishmash of the COOP mods for E:Z2 available here:

https://steamcommunity.com/sharedfiles/filedetails/?id=2856851374

https://github.com/met-nikita/ez2_coop_mapfixes

https://github.com/met-nikita/source-sdk-2013

# What do I need to do after downloading?

- Make sure Entropy Zero 2 is installed 
- Make sure folder is put into your `sourcemods` folder
- Verify folder name is simply `ez2coop`
- Run the `OPEN_THIS_FIRST.bat` file
- Restart Steam


# What's different? 
So what I did here was take the newest changes from the source sdk 2013 repo and compiled (as of 05/20/2025). I also changed the `server.dll` to say `EZ2 Coop` as the game when you are hosting.

I then combined it with the ez2 coop mapfixes repo and the very out of date repo on the EZ2 workshop.

On top of that, I wanted the ez2 coop folder to be available in the real sourcemods folder but also have a way for people to be able to run something similar to the batch file that was included in the workshop item.

So what I did was set this up within the folder itself and made the new batch file based on the one from their steam workshop to be as user friendly as possible.

So yeah the `OPEN_THIS_FIRST.bat` file will find your EZ2 folder and change your gameinfo to be hard-coded to mount your EZ2 assets. This file will need to be re-run if you move your EZ2 installation.

If you have any changes that you'd like to make, please make a PR! My batch file change is a gigantic mess so I'd like that and any other changes that could make this a better experience.

Please also consider working on the linked repositories to make this project better for everyone! 

# Some notes

- Things like sprays don't work at the moment. 
- X is bound by default for voice chat (yes voicechat works!) 
- Y is bound for chat which also works! 
- Nothing for the original game was compiled for Linux so I can't make a native Linux port as much as I would love to do so :( the amount of programming it would take to fix it for Linux is beyond me.
- I tried to replace the icon for within Steam and when you launch the mod itself, but I can't quite figure it out for whatever reason. Help would be appreciated. 
- I need to figure out how to change the "Start Server" dialog to show EZ2COOP as the name and to remove mounted HL2 maps that could cause a good bit of issues if you try to play (or just dumb ones like backgrounds)

Oh and uhh

have fun!
