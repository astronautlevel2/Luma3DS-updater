StarUpdater : Bootstrapper Documentation
~gnmmarechal


Adding a bootstrapper that will make StarUpdater behave similarly to Corbenik CFW Updater: RE.
The bootstrapper will be very simple, and will only be updated for required LPP binary updates
or small updates to the bootstrapper script. Those *shouldn't* occur often. Hopefully never.
The bootstrapper will ALWAYS fetch the most recent script from the internet.
This means we can remove the "Latest StarUpdater" and "Current StarUpdater" strings and perhaps
replace it with a simple "StarUpdater: CORE/SCRIPT", where CORE is the version of the bootstrapper
and SCRIPT the version of StarUpdater.

Removing the StarUpdater self-updater from the menu will also be required.
Auto-updating will be handled at the start of the script, as well.

--

The auto-updater (original code) and the updater option have been removed from StarUpdater.
