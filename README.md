# a10cII-matric

## Installation
You will need the MATRIC server and client (preferrably a large table, phones will have a difficult time using this).
Download the deck from here: https://community.matricapp.com/deck/621/dcs-a10c-ii

Place the MFCD.lua file in your DCS installation directory/Config/MonitorSetup/.  Depending on your screen size, you may want to adjust the values (replace 300 with however many pixels you want.  Bigger = clearer on the MFCD deck, but more resource usage)

Place the matrica10cII.lua file in c:\users\<your user>\Saved Games\DCS(.openbeta)\Scripts.
If you have an Export.lua in that directory, add this line to the end of it:
`dofile(lfs.writedir()..[[Scripts\matrica10cII.lua]])`

If you don't have that file, you can copy the one from this repo.

After launching DCS, make sure to go into your settings and select the new MFCD view, and restart.  Then remember to map the buttons!
