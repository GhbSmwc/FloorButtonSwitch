If you open "FloorButton.asm", this floor switch sprite have a crapload of features and settings. Go read the comments that lists out the functions.
You can also open "BinaryHex_SwitchSetting.html" using a browser (tested using chrome and firefox), that makes handling bitwise with hex values with
the setting of the sprite.

-Tutorial for testing
	To insert the test demo included in this package, I provided a MWL file (level and exanimations), graphics, and map16 blocks, all can be inserted
	via Lunar Magic.
	
	For blocks, you need GPS version 1.4.4 or higher (just in case). I also provided a list file for where the blocks should be on the map 16.
	Make sure you copy the FOLDER, "ExanimationBlocks" not the individual ASM files it contains.
	
	For sprites, Have this: "02	FloorButton.json" in pixi's sprite list. Why $02? Because I was testing other sprites, and replacing sprites
	in LM is tedious.