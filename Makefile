OUT = out
BUILD = build
UNAME = $(shell uname)

#Build Settings
APPNAME = StarUpdater
APPDESC = StarUpdater for Luma3DS
APPAUTHOR = astronautlevel
APPVER = 1.5.3
APPTITLEID = 0x9998
OFFICIAL = true

#Targets
3DSXBIN = $(OUT)/$(APPNAME).3dsx
CIABIN = $(OUT)/$(APPNAME).cia
BANNERFILE = $(BUILD)/$(APPNAME).smdh

#Resources
RESDIR = resources
SRCDIR = source
LOGOFILE = $(RESDIR)/starlogo.png
ICONFILE = $(RESDIR)/icon.bin
ROMFSFILE = $(RESDIR)/romfs.bin
LPPELF = $(RESDIR)/lpp-3ds.elf
MAINSCRIPT = $(SRCDIR)/index.lua
RSFFILE = $(RESDIR)/StarUpdater.rsf
VEREXP = local sver = "!!VERSIONSTRING!!"
TIDEXP = !!TITLEID!!
TITLEEXP = !!APPNAME!!

ifeq ($(OFFICIAL), true)
	TRUEVER = local sver = "$(APPVER)"
else
	APPNAME = $(APPNAME)-UN
	APPTITLEID = 0xA546
	APPAUTHOR = $(APPAUTHOR)/gnmmarechal
	APPDESC = StarUpdater-UN for Luma3DS
	TRUEVER = local sver = "$(APPVER)-UN"
endif

#Tools
ifeq ($(UNAME),Linux)
	TOOLDIR = buildtools/linux
else
	TOOLDIR = buildtools/win
endif

MAKEROM = ./$(TOOLDIR)/makerom
3DSTOOL = ./$(TOOLDIR)/3dstool
3DSXTOOL = ./$(TOOLDIR)/../win/3dsxtool.exe
BANNERTOOL = ./$(TOOLDIR)/bannertool



all: setver cia 3dsx resetver

cia: setver setAppTitle settitleID cia2 resetver resetAppTitle resettitleID

3dsx: setver 3dsx2 resetver

cia2: outdir banner icon romfs
	$(MAKEROM) -f cia -o $(CIABIN) -elf $(LPPELF) -rsf $(RSFFILE) -icon $(ICONFILE) -banner $(BANNERFILE) -exefslogo -target t -romfs $(ROMFSFILE)
romfs: outdir
	$(3DSTOOL) -cvtf romfs $(ROMFSFILE) --romfs-dir $(SRCDIR)
icon:
	$(BANNERTOOL) makesmdh -s "$(APPNAME)" -l "$(APPDESC)" -p "$(APPAUTHOR)" -i $(LOGOFILE) -o $(ICONFILE)

3dsx2: outdir banner
	$(3DSXTOOL) $(LPPELF) "$(3DSXBIN)" --romfs="$(ROMFSFILE)" --smdh="$(BANNERFILE)"

banner: outdir
	$(BANNERTOOL) makesmdh -s "$(APPNAME)" -l "$(APPDESC)" -p "$(APPAUTHOR)" -i $(LOGOFILE) -o $(BANNERFILE)
outdir:
	mkdir -p $(OUT) $(BUILD)

setver:
	sed -i -e 's/$(VEREXP)/$(TRUEVER)/g' $(MAINSCRIPT)
resetver:
	sed -i -e 's/$(TRUEVER)/$(VEREXP)/g' $(MAINSCRIPT)

settitleID:
	sed -i -e 's/$(TIDEXP)/$(APPTITLEID)/g' $(RSFFILE)
resettitleID:
	sed -i -e 's/$(APPTITLEID)/$(TIDEXP)/g' $(RSFFILE)

setAppTitle:
	sed -i -e 's/$(TITLEEXP)/$(APPNAME)/g' $(RSFFILE)
resetAppTitle:
	sed -i -e 's/$(APPNAME)/$(TITLEEXP)/g' $(RSFFILE)


clean: resetAppTitle resetver resettitleID
	rm -rf $(OUT) $(BUILD)
