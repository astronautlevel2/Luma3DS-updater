<p align="center">
	<img src="https://github.com/astronautlevel2/StarUpdater/blob/master/Builder/banner.png?raw=true"/>
</p>


# StarUpdater-UN for Luma3DS

This is a simple updater for Luma3DS. It uses LPP-3DS in order to work, and it is available as both a 3DSX and a CIA.

NOTE: This is discontinued and will not work with Luma3DS 6.1.3 or newer for menuhax. It should still work for arm9loaderhax, but no promises.

## Usage

Usage is simple: Either copy the 3DS folder onto the root of your SD and then use the Homebrew Launcher, or just install the CIA.

If you use a custom path, create an update.cfg file in /luma/ and put your complete path (including the forward slash) in the file. It should look like:

`/a9lh/luma.bin`

This currently supports custom paths and path changing patch, and both hourlies and stable releases! In addition, it supports making and restoring backups of arm9loaderhax.bin!

Before updating, it shows you your current Luma version and the latest available Luma version.

Recent features allow Menuhax support as well. This will always extract it to /Luma3DS.dat on the root of your SD card due to path changer limitations. If you want backup support with Menuhax, set your update.cfg file to this location.

## Building
You'll need GNU Make. The required utilities are already included. Simply do "make" inside the repository. If you use Linux, you'll also need Wine, as to run 3dsxtool.exe, which seems not to properly load the romfs.bin file in Linux.

## Credits
 * Thanks to Rinnegatamante for lpp-3ds, which this depends upon.
 * Thanks to Aurora Wright for the awesome CFW.
 * Thanks to @squee666, or /u/izylock for making the banner and icon.
 * Thanks to all the contributors, especially gnmmarechal, for helping.
