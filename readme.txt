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
	This sprite uses 6 8x8 OAM tiles, so that the animation can be performed seamlessly:
		-2 8x8s for the button cap that moves up and down
		-2 8x8s for the orange-colored base frame the button cap sinks directly in to.
		-2 8x8s for the masking 8x8 tile, so if you have the switch sprite in front of a scenery and do not want the button cap to poke through
		 the bottom of the sprite
	Note that this ONLY occurs when the button is anywhere in between the pressed fully and not pressed fully (essentially, when the button cap is
	moving; pressing and unpressing animation). Otherwise they use 2 OAM tile graphics that only consists of the button cap and the	base frame.
	This is an optimization technique so that it prevents OAM overdraw on the scanline (SNES cannot draw more than 280 pixels total in a scanline).
	
	If you want to adjust the height of the button cap's Y position or you edit the graphic for the fully pressed and fully not pressed, you have to
	do both the cap's Y position and the graphic else the graphic for the switch will seemingly jump around.

-Changelog
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