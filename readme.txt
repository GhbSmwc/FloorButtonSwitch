If you open "FloorButton.asm", this floor switch sprite have a crapload of features and settings. Go read the comments that lists out the functions.
You can also open "BinaryHex_SwitchSetting.html" using a browser (tested using chrome and firefox), that makes handling bitwise with hex values with
the setting of the sprite.

-Tutorial for testing
	To insert the test demo included in this package, I provided a MWL file (level and exanimations), graphics, and map16 blocks, all can be inserted
	via Lunar Magic.
	
	For blocks, you need GPS version 1.4.4 or higher (just in case). I also provided a list file for where the blocks should be on the map 16.
	Make sure you copy the FOLDER, "ExanimationBlocks" not the individual ASM files it contains.
	
	For sprites, Have this: "02	FloorButton.json" in pixi's sprite list. Why $02? Because I was testing other sprites, and replacing every sprite
	in LM is tedious.
Notes:
	This sprite uses each frame for every unique Y position of the button cap. If you change the Y position, you must also edit the graphic so that:
	-No glitch tiles get displayed
	-The Y position of its hitbox is aligned with the graphic (i.egraphic is off if Mario is a pixel off from standing on top of the switch)

-Changelog
	2023-09-17 v1.4
		-Sprite no longer uses OAM tricks and masking but rather having each frame graphic for every Y position of the button cap. This means
		 the button switch now ALWAYS uses 2 8x8 OAM tiles on the screen even during the moving animation of the button cap. Reason for
		 choosing that is because it had 5 unique 8x8 tiles: The moving button cap, the base frame, the masking tile, and the fully pressed
		 and fully unpressed graphic, and that this method, assuming you didn't adjust the height of the switch cap's range, would require 4 tiles
		 representing a sequence of the pressing animation.
	2023-09-15 v1.3
		-Reduced the OAM usage down to just 2 8x8 OAM tiles when the switch is 0% or 100% pressed but not in between. This will dam the
		 potential OAM scanline overdraw since most of the time the switch is either fully pressed or fully not.
		-Fixed the upsidedown button being a pixel lower than it should.
		-Fixed an oversight that a Silver p-switch mode fails to turn sprites into coins.
		-Fixed exanimation being out of sync.
	2023-03-07 v1.2
		-Made a minor bugfix with the upside-down floor switch having an oddly small hitbox. I also made setting the Y position of the player
		 to be below the switch dependent on the sprite's hitbox height rather than adding by #$0010 before storing the Y position of the
		 player, removing the "jank" that the player snapping a few pixels downwards.
		-Minor graphic change: the masking sprite have corner pixels removed as they were giving the base frame graphic the appearance of
		 the said corner pixels.
	2023-03-06 v1.1
		-Slight graphical improvements on the button cap (a rounder top needs to have the shades of color sloped with that roundness)
		-Changed the way the button base frame (the orange ring the cap sinks into) appears. Previously both the base frame and the masking
		 graphic were the same graphic, and was intended so if you wanted decoration tiles behind that switch, you would have a floating
		 switch cap and need to have the base of the switch have tile priority and have the layer 1/2 tile have priority to cover that.
		 Now, the base frame graphic and the masking graphic are separate tiles, with the base frame having priority and the masking
		 graphic behind layer 1 and 2. This also renders
	2023-03-05 v1.0: First release