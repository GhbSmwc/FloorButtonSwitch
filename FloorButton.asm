;Key
;This is a disassembly of sprite 80 in SMW - Key.
;By RussianMan. Please give credit if used.
;Requested by Hamtaro126.

;Modified to act as a wall button
;sprite by HammerBrother.
;extra_byte_1: bitwise information %0000SBDP
;-P = permanent flag: 0 = Can press again, 1 = pressed permanently
; (resets if offscreen unless you modify the init routine to read
; a RAM to determine if !ButtonState should initially hold the value of $02).
;-D = Require pressing down on D-pad: 0 = no, 1 = yes
;-B = Base of switch in front of layer 1 flag: 0 = behind, 1 = in front (but
; behind tiles with priority). Have this set to 1 if you plan on having the
; switch in front of decoration tiles to avoid the switch cap from being
; masked (cut off) by the behind-the-foreground switch base.
;-S = Activate by carryable/kicked sprites: 0 = no, 1 = yes.
;extra_byte_2: color for YXPPCCCT switch cap:
; $00 = Palette 0 (LM row number $08)
; $02 = Palette 1 (LM row number $09)
; $04 = Palette 2 (LM row number $0A)
; $06 = Palette 3 (LM row number $0B)
; $08 = Palette 4 (LM row number $0C)
; $0A = Palette 5 (LM row number $0D)
; $0C = Palette 6 (LM row number $0E)
; $0E = Palette 7 (LM row number $0F)
;extra_byte_3: Custom switch action (see macro below).

;Settings
 !Tile_ButtonCap = $02			;>tile to display the button (note: this tile moves up and down to display non-pressed and pressed states)
 !Tile_Pedestal = $03
 
 !GFXPage = 1				;>0 = Page 0, 1 = page 1 (don't use any other values).
 !PressedTimer = 15			;>How many frames the button remains pressed before popping out (1 second is 60 frames) (use only $01-$FF).
 
 ;Pro tip: Asar allows entering hexadecimal signed numbers without using two's complement ("$FF" can be entered as "-$01"), you don't need to convert.
  !Button_NotPressedOffset = $02	;>Y position (relative to sprite's origin) of button cap when not pressed (can be negative ($80-$FF) for higher positions).
  !Button_PressedOffset = $05		;>Y position (relative to sprite's origin) of button cap that is the lowest when pressing (can be negative ($80-$FF) for higher positions).
 
 !Held_Down_Function = 0		;>0 = No, 1 = include code that runs every frame while the switch is pressed (see "SwitchActionHeldDown")
 
 !ButtonDownSpeed = $0080		;>How fast the button cap moves down when pressed, in 1/256th of a pixel per frame ($0080 is 128/256, or 0.5 pixel per frame)
 !ButtonUpSpeed = $0080			;>Same as above but when rising back up.
 
 !SwitchBasePalette = 3			;>Palette of switch base, use values 0-7, don't use any other values.
;Sound effects, see https://www.smwcentral.net/?p=viewthread&t=6665
 !SFX_SoundNumb = $0B		;>Sound effect number
 !SFX_Port = $1DF9|!addr	;>Use only $1DF9, $1DFA, or $1DFB.

 ;Misc settings
  ;P-switch mode
   !NoMusic = 0			;>0 = Allow p-switch music, 1 = no (if you've using AddmusicK and disabled the P-switch music)
   !ScreenShake = $20		;>0 = no, any number = yes and how long, in frames

;Sprite defines
 ;Best not to modify these
  ;Sprite tables
   !ButtonState = !1534			;>This RAM holds these values: $00 = not pressed, $01 = temporally pressed, $02 = permanently pressed
   !ButtonPressedTimer = !1540		;>Timer for when the switch is temporally pressed before popping back out (measured when the button cap starts moving downwards, not when it reaches the bottom)
   !ButtonCapOffset = !1504		;>How far down the switch moved, in pixels.
   !ButtonCapOffsetFixedPoint = !14EC	;>Same as above but contains fraction bits (allow movement less than a pixel -- this is only used when $01ABCC or any speed-to-position-offset subroutine is called)
  ;Other
  !SwitchBasePriority = %00100000	;>This to force switch base in front of layer 1 when extra_byte_1's B bit is set (should have all bits 0 except bits 5 and 6).
 ;Feel free to modify these
  !FrozenTile = $0165 ;>Tile that turns the tile into when touching liquids.



;Action to perform when switch is pressed.
;Notes:
;- X register must be restored after this code (become a sprite slot index) is finished to prevent bugs/crash.
;  Can be done via PHX ... PLX or LDX $15E9|!addr (PLX and LDX $15E9|!addr to be perform after done using X for something else)
;- Code must end with RTS, using RTL or not having it exist at all can lead to a crash. However, on SA-1, when using "%invoke_snes(label)"
;  (to access WRAM - $7FXXXX) The code the label points to must end with RTL since it is technically a JSL.
macro SwitchAction()
	SwitchAction:
	;Examples:
	;!extra_byte_3 values:
	; -$00 = on/off (2-way toggle)
	; -$01 = blue p-switch (2-way toggle)
	; -$02 = silver p-switch (2-way toggle)
	; -$03 = LM custom trigger $00 (2-way toggle)
	; -$04 = LM custom trigger $01 (2-way toggle)
	; -$05 = LM custom trigger $02 (2-way toggle)
	; -$06 = LM custom trigger $03 (2-way toggle)
	; -$07 = LM custom trigger $04 (2-way toggle)
	; -$08 = LM custom trigger $05 (2-way toggle)
	; -$09 = LM custom trigger $06 (2-way toggle)
	; -$0A = LM custom trigger $07 (2-way toggle)
	; -$0B = LM custom trigger $08 (2-way toggle)
	; -$0C = LM custom trigger $09 (2-way toggle)
	; -$0D = LM custom trigger $0A (2-way toggle)
	; -$0E = LM custom trigger $0B (2-way toggle)
	; -$0F = LM custom trigger $0C (2-way toggle)
	; -$10 = LM custom trigger $0D (2-way toggle)
	; -$11 = LM custom trigger $0E (2-way toggle)
	; -$12 = LM custom trigger $0F (2-way toggle)
	; -$13 = Set on/off switch to ON (if already, should be in its pressed state)*
	; -$14 = Set on/off switch to OFF (if already, should be in its pressed state)*
	;
	;*Needs code on the INIT and code that runs every frame to work properly:
	;- InitPressedStateCode: so that when the sprite spawns, will appear in its pressed state (permanently pressed) AND have
	;  !ButtonCapOffset,x set to whatever value is set by !Button_PressedOffset
	;- EveryFrameCode: checks a given RAM (in this case, the on/off switch flag, $14AF|!addr) so that other switch sprites on-screen
	;  gets pressed by themselves (they themselves not execute SwitchAction) when one of them is pressed by the player, and becomes
	;  re-pressable again.
		LDA !extra_byte_3,x
		BEQ .OnOffFlip			;>$00: on/off toggle
		CMP #$03		
		BCC .PSwitchToggle		;>$01: blue p-switch, $02: silver
		CMP #$13		
		BCC .CustomTriggersToggle	;>$03-$12: custom triggers
		BEQ .SetOnOffOn			;>$13: Set on/off to on
		CMP #$14
		BEQ .SetOnOffOff		;>$14: Set on/off to off
		RTS				;>Anything else, return (failsafe)
		
		.OnOffFlip
			LDA $14AF|!addr
			EOR #$01
			STA $14AF|!addr
			RTS ;>Keep this RTS here else game will crash.
			
		.PSwitchToggle
			DEC			;\Map $01-$02 to $00-$01, for offsetting from $14AD
			TAY			;/
			LDA $14AD|!addr,y
			BEQ ..Activate
			
			..Deactivate
				LDA #$01		;\STZ $xxxx,y does not exist. Also, setting this to $00 doesn't reset the music
				STA $14AD|!addr,y	;/since the music resetting mechanism is handled by the timer itself, thus setting it to $01 is a preferable option.
				RTS
			..Activate
				LDA #$B0		;\Activate P-switch
				STA $14AD|!addr,y	;/
				if !NoMusic = 0
					LDA #$0E		;\music
					STA $1DFB|!addr		;/
				endif
				if !ScreenShake
					LDA #!ScreenShake	;\shake timer
					STA $1887|!addr		;/
				endif
				RTS
		.CustomTriggersToggle
			if !sa1 != 0
				%invoke_snes(..WramAccess)
				RTS
			endif
			
			;SEC : SBC #$03 causes mapping the range of $03-$12 to be mapped to $00-$0F, the valid bit numbering range for 16-bit numbers and custom trigger flags.
			..WramAccess
				;Thing I learned about "%invoke_snes(label)":
				; - The "subroutine" of "label" must end with RTL
				; - Several processor-related stuff (AXY, processor flags, etc.) are seperate in SA-1, so the X register in this case doesn't carry over.
			if !sa1 != 0
				PHB
				PHK
				PLB
				LDX $15E9|!addr
			endif
			LDA !extra_byte_3,x
			SEC
			SBC #$03
			STA $00					;>Store custom trigger flags numbering $00-$0F into scratch RAM $00
			LSR #3					;>divide by 8, and round down to obtain which of the 2 bytes of custom triggers to write to
			TAX					;>X = $00 for $7FC0FC and X = $01 for $7FC0FD
			LDA $00
			AND.b #%00001111			;>Modulo by 8 to make it wraparound 0-7, the bit numbering range of 1-byte
			TAY					;>Y = $00-$07, corresponding to what bit number of the custom trigger
			LDA $7FC0FC,x				;\Toggle custom trigger flags
			EOR ..CustomTriggerFlagBitNumbering,y	;|
			STA $7FC0FC,x				;/
			LDX $15E9|!addr				;>Restore sprite slot
			
			if !sa1 == 0
				RTS
			else
				PLB
				RTL
			endif
			
			..CustomTriggerFlagBitNumbering
				db %00000001
				db %00000010
				db %00000100
				db %00001000
				db %00010000
				db %00100000
				db %01000000
				db %10000000
		.SetOnOffOn
			STZ $14AF|!addr
			RTS
		.SetOnOffOff
			LDA #$01
			STA $14AF|!addr
			RTS
endmacro
macro EveryFrameCode()
	EveryFrameCode:
		LDA !extra_byte_3,x		;\Check if extra byte would make the switch perform action that would make other switches be pressed
		CMP #$13			;|
		BEQ .BePressedWhenOnOffIsOn	;|
		CMP #$14			;|
		BEQ .BePressedWhenOnOffIsOff	;/
		RTS
		
		.BePressedWhenOnOffIsOn
			LDA $14AF|!addr
			BNE .NonPressed
			LDA #$02
			STA !ButtonState,x
			RTS
		.BePressedWhenOnOffIsOff
			LDA $14AF|!addr
			BEQ .NonPressed
			LDA #$02
			STA !ButtonState,x
			RTS
		.NonPressed
			STZ !ButtonState,x
			RTS
endmacro
macro InitPressedStateCode()
	InitPressedStateCode:
		LDA !extra_byte_3,x		;\Check if extra byte would make the switch perform action that would make other switches be pressed
		CMP #$13			;|
		BEQ .BePressedWhenOnOffIsOn	;|
		CMP #$14			;|
		BEQ .BePressedWhenOnOffIsOff	;/
		RTS
		
		.BePressedWhenOnOffIsOn
			LDA $14AF|!addr
			BNE .NotPressed
			BRA .Pressed
		.BePressedWhenOnOffIsOff
			LDA $14AF|!addr
			BEQ .NotPressed
		.Pressed
			LDA.b #!Button_PressedOffset
			STA !ButtonCapOffset,x
			RTS
		.NotPressed
			LDA.b #!Button_NotPressedOffset
			STA !ButtonCapOffset,x
			RTS
endmacro
if !Held_Down_Function != 0
	macro SwitchActionHeldDown()
		SwitchActionHeldDown:
		RTS
	endmacro
endif

Print "INIT ",pc
	LDA !D8,x
	CLC
	ADC.b #$8-1		;Sprites appear 1 pixel lower than their original Y position.
	STA !D8,x
	LDA !14D4,x
	ADC #$00
	STA !14D4,x
	JSR InitPressedStateCode
	RTL

Print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Button
	PLB
	RTL

Button:
	%SubOffScreen()			
	JSR HandleGFX			;Handle graphics
	LDA $9D				;freeze flag
	;BNE .Done			;
	BEQ +
	RTS
	+
	
	.RunMain
		JSR EveryFrameCode
		;Switch pop back out check
			LDA !ButtonState,x		;\If switch isn't temporally pressed down, skip
			CMP #$01			;|
			BNE .NoPop			;/
			LDA !extra_byte_1,x		;\If set to allow pressing without the Dpad, skip (this would allow player to use the switch without having to get off of it)
			AND.b #%00000010		;/
			BNE .SkipPlayerHoldingItDown	;>If switch requires D-pad pressing down, allow switch to pop back out even if player is touching it
			JSL $03B664|!BankB		;>Get player hitbox info (clipping B)
			JSL $03B69F|!BankB		;>Get sprite hitbox info (clipping A)
			JSL $03B72B|!BankB		;>Check contact
			BCS .NoPop			;>If player is inside the switch, don't allow it to pop (when set to activate without pressing down on D-pad)
			
			.SkipPlayerHoldingItDown
			LDA !extra_byte_1,x
			AND.b #%00001000
			BEQ .IgnoreOtherSprites
			JSR SpriteTouchSwitchCheck
			BCS .NoPop
			.IgnoreOtherSprites
			LDA !ButtonPressedTimer,x	;\If timer runs out, revert switch
			BNE .NoPop			;|
			STZ !ButtonState,x		;/
			.NoPop
		;Get previous marioYposition relative to sprite
			LDY #$00			;\Y = $00 if displacement is positive, $FF if negative (allows 8-bit signed value to represent signed 16-bit)
			LDA !ButtonCapOffset,x		;|
			BPL .NonNegativeOffset		;|
			INY				;/
			.NonNegativeOffset
			LDA !D8,x			;\Make hitbox of button cap move with the position of the cap
			CLC				;| (SwitchCapSpriteY = SpriteY + Displacement)
			ADC !ButtonCapOffset,x		;|
			STA $00				;|
			LDA !14D4,x			;|
			ADC ButtonCapHighByteDisp,y	;|
			STA $01				;/
			
			REP #$20			;\$00-$01: Mario's Y position relative to button cap, previous frame (this must be performed before ALL forms of movement (including calling $01ABCC/$01801A/$018022/$01802A) to account his final position)
			LDA $D3				;| (MarioYRelativePrev = MarioYPrev - SwitchCapSpriteYPrev)
			SEC				;| Thanks to RAM $D1-$D4 for storing Mario's previous XY.
			SBC $00				;|
			STA $00				;/
			SEP #$20
		
		;Switch cap moves vertically check
			LDA !ButtonState,x
			BNE .MoveDown
			
			.MoveUp
				LDA !ButtonCapOffsetFixedPoint,x
				SEC
				SBC.b #!ButtonUpSpeed
				STA !ButtonCapOffsetFixedPoint,x
				LDA !ButtonCapOffset,x
				SBC.b #!ButtonUpSpeed>>8
				STA !ButtonCapOffset,x
				LDA.b #!Button_NotPressedOffset		;\If top limit is above the switch cap's position, (or cap is below the limit), move upwards
				CMP !ButtonCapOffset,x			;|(placed here to prevent 1-frame of exceeding limit)
				BMI .MoveDone				;/
				STA !ButtonCapOffset,x			;>Otherwise set its position at the limit
				BRA .MoveDone
			.MoveDown
				LDA !ButtonCapOffsetFixedPoint,x
				CLC
				ADC.b #!ButtonDownSpeed
				STA !ButtonCapOffsetFixedPoint,x
				LDA !ButtonCapOffset,x
				ADC.b #!ButtonDownSpeed>>8
				STA !ButtonCapOffset,x
				LDA #!Button_PressedOffset		;\If bottom limit is below switch cap position (or cap is above the bottom limit), move downwards
				CMP !ButtonCapOffset,x			;|
				BEQ +					;|>If AT the position, don't vibrate.
				BPL .MoveDone				;/
				+
				STA !ButtonCapOffset,x			;>Otherwise set its position at the limit
				BRA .MoveDone
				
				.MoveDone
		
		LDA !D8,x		;Temporary move the sprite so that the solid hitbox ($01B44F) account for the moved button cap
		PHA
		LDA !14D4,x
		PHA
		
		LDY #$00			;\Load Y again due to a bug that if displacement went from $00 to $FF resulted mario briefly (1-frame) disconnect from the platform (shows his falling pose)
		LDA !ButtonCapOffset,x		;|and during that frame if the player presses jump, result in the player not jumping.
		BPL +				;|
		INY				;/
		+
		LDA !D8,x			;\Make hitbox of button cap move with the position of the cap
		CLC				;| (SwitchCapSpriteY = SpriteY + Displacement)
		ADC !ButtonCapOffset,x		;|
		STA !D8,x			;|
		LDA !14D4,x			;|
		ADC ButtonCapHighByteDisp,y	;|
		STA !14D4,x			;/
		
		LDA $96			;\$02-$03: Mario's Y position relative to the button cap, after frame of movement (this must be performed after ALL forms of movement (including calling $01ABCC/$01801A/$018022/$01802A) to account his final position)
		SEC			;|(MarioYRelativeCurrent = MarioYCurrent - SwitchCapSpriteYCurrent)
		SBC !D8,x		;|
		STA $02			;|
		LDA $97			;|
		SBC !14D4,x		;|
		STA $03			;/
		;This is a workaround bypassing a clipping glitch with smw's $01B44F that:
		;-If you crouch-slide as small mario into the side of the switch
		;-If you are big mario and go into the side of the switch
		;The sprite will fail to place mario on top of the switch
			LDA !ButtonState,x				;\Apply the snapping only if the switch is not pressed
			BNE .NoClipFix					;/
			;LDA $7D						;\If player going upward, don't boost him
			;BMI .NoClipFix					;/
			REP #$20
			LDA $02						;\Mario's Y position delta relative to the sprite position delta (if negative, player is moving upwards against sprite, 0, player and sprite moving at same pixels per frame, positive, player moves downwards against sprite)
			SEC						;|Effectively, this is the "speed" (in pixels per frame) of Mario moving against the sprite.
			SBC $00						;/
			SEP #$20					;\This is a "platform pass fix": https://www.smwcentral.net/?p=section&a=details&id=13557 - this time, instead of using [MarioXYSpeedRelativeToSprite = MarioXYSpeed - SpriteXYspeed], we do
			BMI .NoClipFix					;/[MarioXYRelativeToSprite = MarioXYPos - SpriteXYPos] twice, before and after moving the cap up and down. If Mario is moving upwards against, don't apply the set-y-position.
			
			;Sprite clipping (the button cap), box A
				JSL $03B69F|!BankB			;>Get sprite clipping (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
				LDA #$08				;\Modify its height
				STA $07					;/
			;Mario clipping (16x8 area of his feet), box B
				JSL $03B664|!BankB			;>Get Mario clipping (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
				LDY $187A|!addr				;>Riding yoshi flag (player is about 3 blocks tall, adds a length of 16 pixel underneath)
				LDA #$08
				STA $03					;>Modify height of player's hitbox (not that hitbox extends down and right), so we need to...
				LDA $96					;\Move his box Y position (from the info obtained from $03B664)
				CLC					;|
				ADC.w PlayerFeetOffset,y		;|
				STA $01					;|
				LDA $97					;|
				ADC #$00				;|
				STA $09					;/
			;Contact
				JSL $03B72B|!BankB			;\If not touching, don't snap Y position
				BCC .NoClipFix				;/
			;Place player on top of switch
				LDA !D8,x				;\Snap player Y position
				SEC					;|
				SBC PlayerOnTopOfSwitchYPos,y		;|
				STA $96					;|
				LDA !14D4,x				;|
				SBC #$00				;|
				STA $97					;/
		.NoClipFix
		JSL $01B44F|!BankB	;>Solid sprite subroutine
		BCC .NotPressingSwitch	;>If not even touching switch, skip
		LDA !ButtonState,x
		BNE .AlreadyPressed	;>If switch pressed, don't allow player to re-trigger it
		
		LDA !extra_byte_1,x
		BIT.b #%00000010
		BEQ .NoDownNeeded	;>If D flag set, player can activate switch by touching the top without need to press down
		LDA $16
		BIT.b #%00000100
		BEQ .NotPressingSwitch	;>If not pressing down, skip
		.NoDownNeeded
		;When player presses the switch
			LDA #!SFX_SoundNumb	;\Sound effect
			STA !SFX_Port		;/
			LDA !extra_byte_1,x	;\Permanent flag check
			BIT.b #%00000001	;|
			BNE .Permanent		;/
			.Temporary
				LDA #$01			;\temporally pressed
				STA !ButtonState,x		;/
				LDA.b #!PressedTimer		;\Set timer
				STA !ButtonPressedTimer,x	;/
				BRA .SwitchFunction
			.Permanent
				LDA #$02			;\permanently pressed
				STA !ButtonState,x		;/
			.SwitchFunction
				JSR SwitchAction
		
		.AlreadyPressed
		.NotPressingSwitch
		
		.SpriteTrigger
			LDA !extra_byte_1,x
			AND.b #%00001000
			BEQ ..NotTouchingSwitch
			LDA !ButtonState,x
			BNE ..SpriteAlreadyPressed	;>If switch pressed, don't allow sprite to re-trigger it
			JSR SpriteTouchSwitchCheck
			BCC ..NotTouchingSwitch
			LDA #!SFX_SoundNumb		;\Sound effect
			STA !SFX_Port			;/
			LDA !extra_byte_1,x		;\Permanent flag check
			BIT.b #%00000001		;|
			BNE ..Permanent			;/
			..Temporary
				LDA #$01			;\temporally pressed
				STA !ButtonState,x		;/
				LDA.b #!PressedTimer		;\Set timer
				STA !ButtonPressedTimer,x	;/
				BRA ..SwitchFunction
			..Permanent
				LDA #$02			;\permanently pressed
				STA !ButtonState,x		;/
			..SwitchFunction
				JSR SwitchAction
			
			..NotTouchingSwitch
			..SpriteAlreadyPressed
		
		PLA			;\Restore sprite position
		STA !14D4,x		;|
		PLA			;|
		STA !D8,x		;/
		if !Held_Down_Function != 0
			LDA !ButtonState,x
			CMP #$01
			BNE .Done
			;Switch function when button is held down:
				JSR SwitchActionHeldDown
		endif
	.Done
		RTS
	%SwitchAction()
	if !Held_Down_Function != 0
		%SwitchActionHeldDown()
	endif
	%EveryFrameCode()
	%InitPressedStateCode()
	PlayerFeetOffset:
		db $18		;>Not on yoshi
		db $28		;\On yoshi
		db $28		;/
	PlayerOnTopOfSwitchYPos:
		db $20		;>Not on yoshi
		db $30		;\On yoshi
		db $30		;/
	ButtonCapHighByteDisp:
		db $00		;>If Displacement is $00-$7F (positive value)
		db $FF		;>f Displacement is $80-$FF (negative value)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Graphics routine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HandleGFX:
	;Note to self:
	;An OAM slot at higher indexes appears behind ones that lower indexes.
	;This means that the Pedestal must be drawn first (at a lower OAM slot)
	;before drawing the button cap (higher OAM slot) so that the button part
	;GOES BEHIND the Pedestal part, assuming you've installed the NMSTL/SA-1
	;patch. This is inspired from wye's "Reusable Stationary Switch":
	; https://www.smwcentral.net/?p=section&a=details&id=20373 that does not have
	;a "not-pressed" and "pressed" graphic rather a moving OAM tile in relation
	;to the origin of the sprite
	%GetDrawInfo()			;
	;($03xx+(SlotOffset*4))
	;SlotOffset = 0: Base of button left half
	;SlotOffset = 1: Base of button right half
	;SlotOffset = 2: Button cap left half
	;SlotOffset = 3: Button cap right half
	;Switch base
		LDA $00				;\X position
		STA.w ($0300+(0*4))|!Base2,y	;|>Left half
		CLC				;|
		ADC #$08			;|
		STA.w ($0300+(1*4))|!Base2,y	;/>Right half
		LDA $01				;\Y position
		CLC				;|
		ADC.b #$08-2			;|
		STA.w ($0301+(0*4))|!Base2,y	;|>Left half
		STA.w ($0301+(1*4))|!Base2,y	;/>Right half
		LDA #!Tile_Pedestal		;\Tile
		STA.w ($0302+(0*4))|!Base2,y	;|>Left half
		STA.w ($0302+(1*4))|!Base2,y	;/>Right half
;		LDA !extra_byte_2,x		;>Palette as extra byte 2
;		AND.b #%00001110		;>Ignore XY flips, page (forcibly set to 0 or 1), and priority
;		ORA.b #(%00010000|!GFXPage)	;>Part of the switch base behind the layer
		LDA.b #((!SwitchBasePalette<<1)|!GFXPage)
		STA.w ($0303+(0*4))|!Base2,y	;\Properties ;>Left half
		ORA.b #%01000000		;|X-flip it
		STA.w ($0303+(1*4))|!Base2,y	;/>Right half
		LDA !extra_byte_1,x
		BIT.b #%00000100
		BEQ .NotInFront
		LDA.w ($0303+(0*4))|!Base2,y	;\Force base of switch in front of layer 1 (anti-masking to avoid cap being cut off when cap is in front of decoration tiles)
		AND.b #%11001111		;|
		ORA.b #!SwitchBasePriority	;|
		STA.w ($0303+(0*4))|!Base2,y	;|
		LDA.w ($0303+(1*4))|!Base2,y	;|
		AND.b #%11001111		;|
		ORA.b #!SwitchBasePriority	;|
		STA.w ($0303+(1*4))|!Base2,y	;/
		.NotInFront
	;Button cap
		LDA $00				;\X position (left half)
		STA.w ($0300+(2*4))|!Base2,y	;|
		CLC				;|
		ADC #$08			;|
		STA.w ($0300+(3*4))|!Base2,y	;/>X position (right half)
		;Y position, depending on pressed state
			LDA $01					;\Y position
			CLC					;|
			ADC !ButtonCapOffset,x			;|
			STA.w ($0301+(2*4))|!Base2,y		;|>Left half
			STA.w ($0301+(3*4))|!Base2,y		;/>Right half
		LDA #!Tile_ButtonCap			;\Tile
		STA.w ($0302+(2*4))|!Base2,y		;|>Left half
		STA.w ($0302+(3*4))|!Base2,y		;/>Right half
		LDA !extra_byte_2,x		;>Palette as extra byte 2
		AND.b #%00001110		;>Ignore XY flips, page (forcibly set to 0 or 1), and priority
		ORA.b #(%00100000|!GFXPage)	;>Force only some bits of the PP to be set (should not appear behind layers without priority.)
		STA.w ($0303+(2*4))|!Base2,y	;\Properties ;>Left half
		ORA.b #%01000000		;|X-flip it
		STA.w ($0303+(3*4))|!Base2,y	;/>Right half

	LDY #$00			;tile size = 8x8
	LDA #$03			;tiles to display minus 1 = 3 (4 tiles, minus 1 = 3)
	JSL $01B7B3|!BankB		;
	RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Sprite touch switch check
;Output:
; -Carry: Clear if no contact with dropped/kicked sprite, set
;  otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SpriteTouchSwitchCheck:
	;Get hitbox A (the switch hitbox, self sprite)
	JSL $03B69F|!BankB		;>Get sprite hitbox info (clipping A)
	LDA #$08
	STA $07
	LDX.b #!SprSize-1			;>Start at last index of sprite and loop counting until X=$FF (loops from 11/21 to 0)
	.Loop
		..CheckCollision
			CPX $15E9|!addr		;\If itself, then skip
			BEQ ..Next		;/
			LDA !14C8,x		;\If other sprite is kicked/carryable, proceed
			CMP #$09		;|
			BEQ ...Carryable	;|
			CMP #$0A		;|
			BEQ ...Kicked		;/
			BRA ..Next
			...Carryable
			...Kicked
				;Hitbox B
				JSL $03B6E5|!BankB
				JSL $03B72B|!BankB		;>Check contact
				BCC ..Next			;>No contact, next
				LDX $15E9|!addr			;>Restore current sprite slot
				RTS				;>Exit loop and return
		..Next
			DEX
			BPL .Loop
			CLC			;>If all 12/22 slots processed and all no contact, clear carry
			LDX $15E9|!addr		;>Restore current sprite slot
			RTS