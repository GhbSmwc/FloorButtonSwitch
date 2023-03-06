;Key
;This is a disassembly of sprite 80 in SMW - Key.
;By RussianMan. Please give credit if used.
;Requested by Hamtaro126.

;Modified to act as a wall button
;sprite by HammerBrother.
;extra_byte_1: bitwise information %0LHUSBDP, see BinaryHex_SwitchSetting.html for easy conversion
;-P = permanent flag: 0 = Can press again, 1 = pressed permanently (will write a bit in freeram,
;     based on extra_byte_4)
;-D = Require pressing down on D-pad: 0 = no, 1 = yes (only applies to
;     right-side-up switch). Good for if you have a bunch of switches on the floor and close to
;     each other and do not want the player to accidentally trigger them.
;-B = Base of switch in front of layer 1 flag: 0 = behind, 1 = in front (but
;     behind tiles with priority). Have this set to 1 if you plan on having the
;     switch in front of decoration tiles to avoid the switch cap from being
;     masked (cut off) by the behind-the-foreground switch base.
;-S = Activate by carryable/kicked sprites: 0 = no, 1 = yes.
;-U = Upside down flag: 0 = on floor facing upwards, 1 = ceiling facing downwards.
;-H = Solid hitbox to player: 0 = no, 1 = yes.
;     NOTE: When upside-down placed underneath solid blocks and isn't solid to
;     the player, the "hit head" sound effect is on the same channel as $1DF9
;     as the on/off switch, which cancels the on/off switch SFX when hit by the
;     player hitting the bottom of the solid block. Have this set to 0 if you
;     have 1-block tall tight spaces just in case.
;-L = Move with layer 2: 0 = no, 1 = yes
; Recommend settings or settings you normally want: $28 ("normal" switch), $38 ("upside down normal switch").
;
;extra_byte_2: color for YXPPCCCT switch cap:
; $00 = Palette 0 (LM row number $08, Default color: Brown)
; $02 = Palette 1 (LM row number $09, Default color: Grey)
; $04 = Palette 2 (LM row number $0A, Default color: Yellow)
; $06 = Palette 3 (LM row number $0B, Default color: Blue)
; $08 = Palette 4 (LM row number $0C, Default color: Red)
; $0A = Palette 5 (LM row number $0D, Default color: green)
; $0C = Palette 6 (LM row number $0E, Default color: Depends on what sprite palette)
; $0E = Palette 7 (LM row number $0F, Default color: Depends on what sprite palette)
;extra_byte_3: Custom switch action (see macro below).
;extra_byte_4: When extra_byte_1'ss P bit is set, this acts as a "flag number" to determine what bit to set
; on !Freeram_PressedSwitchMemory.

;Freeram
 !Freeram_PressedSwitchMemory = $60
  ;^[NumberOfBytes = ceiling(NumberOfFlags / 8)]
  ; "ceiling" is a function that rounds a number up to an integer (9 bits used / 8 = 1.125 -> 2 bytes)
  ; "NumberOfFlags" is the highest number of flags being used in your entire game (e.g if you have 2 levels, one uses 4 flags and another uses
  ; 12, then assume NumberOfFlags uses 12).
  ;
  ; A RAM that is only used when this sprite is running AND having extra_byte_1's bit 0 (P bit) being set. Contains bitwise information
  ; so that when the switch is to remain pressed even if it disappears offscreen, will remember this state when it respawns.
  ;
  ; To find out what byte a given flag number is on, it is [!Freeram_PressedSwitchMemory + floor(FlagNumber / 8)]
  ; "floor" is a function that rounds a number down to an integer (7/8 = 0.875 -> 0)
  ; And what flag within a byte is simply [FlagNumber % 8] where the "%" represents a modulo operator
;Settings
 !Tile_ButtonCap = $85			;>tile to display the button (note: this tile moves up and down to display non-pressed and pressed states)
 !Tile_ButtonBase = $86			;>The part of the switch the button cap sits on (mostly covered by layer 1 unless 0LHUSBDP's B bit is set.)
 
 !GFXPage = 1				;>0 = Page 0, 1 = page 1 (don't use any other values).
 !PressedTimer = 15			;>How many frames the button remains pressed before popping out (1 second is 60 frames) (use only $01-$FF).
 
 ;Pro tip: Asar allows entering hexadecimal signed numbers without using two's complement ("$FF" can be entered as "-$01"), you don't need to convert.
 ;NOTE: These below are "inverted" when upsidedown mode is used, as in, the !Button_PressedOffset refers to how far the button cap goes into the base.
  !Button_NotPressedOffset = $01	;>Y position (relative to sprite's origin) of button cap when not pressed (can be negative ($80-$FF) for higher positions).
  !Button_PressedOffset = $04		;>Y position (relative to sprite's origin) of button cap that is the lowest when pressing (can be negative ($80-$FF) for higher positions).
 
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
  ;MarioVsDK switches and blocks
   !ManuelExanimationSlotToUse = $00	;>Exanimation slot to use. Use only $00-$0F.

;Sprite defines
 ;Best not to modify these
  ;Sprite tables
   !ButtonState = !1534			;>This RAM holds these values: $00 = not pressed, $01 = temporally pressed (also held down), $02 = permanently pressed
   !ButtonPressedTimer = !1540		;>Timer for when the switch is temporally pressed before popping back out (measured when the button cap starts moving downwards, not when it reaches the bottom)
   !ButtonCapOffset = !1504		;>How far down the switch moved, in pixels. NOTE: If switch is upside down, the values are also inverted, increasing would have the cap of the button moves upwards towards the base of the switch.
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
	; -$00 = Toggle on/off
	; -$01 = Toggle blue p-switch
	; -$02 = Toggle silver p-switch
	; -$03 = Toggle LM custom trigger $00
	; -$04 = Toggle LM custom trigger $01
	; -$05 = Toggle LM custom trigger $02
	; -$06 = Toggle LM custom trigger $03
	; -$07 = Toggle LM custom trigger $04
	; -$08 = Toggle LM custom trigger $05
	; -$09 = Toggle LM custom trigger $06
	; -$0A = Toggle LM custom trigger $07
	; -$0B = Toggle LM custom trigger $08
	; -$0C = Toggle LM custom trigger $09
	; -$0D = Toggle LM custom trigger $0A
	; -$0E = Toggle LM custom trigger $0B
	; -$0F = Toggle LM custom trigger $0C
	; -$10 = Toggle LM custom trigger $0D
	; -$11 = Toggle LM custom trigger $0E
	; -$12 = Toggle LM custom trigger $0F
	;
	; -These below (all the "--" entries before the non-"--" text) uses code at
	;  "EveryFrameCode" (also executes on init) so that when they spawn or at every frame,
	;  be in its pressed state if the switch action is already in that state.
	;
	; --$13 = Set on/off switch to ON (if already, should be in its pressed state)
	; --$14 = Set on/off switch to OFF (if already, should be in its pressed state)
	; --$15 = Activate blue P-Switch (if blue P-switch already on, should be in its pressed state)
	; --$16 = Activate silver P-switch (if silver P-switch already on, should be in its pressed state)
	; --$17 = Deactivate blue P-Switch (if blue P-switch already off, should be in its pressed state)
	; --$18 = Deactivate silver P-switch (if silver P-switch already off, should be in its pressed state)
	; --$19 = Activate LM custom trigger $00
	; --$1A = Activate LM custom trigger $01
	; --$1B = Activate LM custom trigger $02
	; --$1C = Activate LM custom trigger $03
	; --$1D = Activate LM custom trigger $04
	; --$1E = Activate LM custom trigger $05
	; --$1F = Activate LM custom trigger $06
	; --$20 = Activate LM custom trigger $07
	; --$21 = Activate LM custom trigger $08
	; --$22 = Activate LM custom trigger $09
	; --$23 = Activate LM custom trigger $0A
	; --$24 = Activate LM custom trigger $0B
	; --$25 = Activate LM custom trigger $0C
	; --$26 = Activate LM custom trigger $0D
	; --$27 = Activate LM custom trigger $0E
	; --$28 = Activate LM custom trigger $0F
	; --$29 = Deactivate LM custom trigger $00
	; --$2A = Deactivate LM custom trigger $01
	; --$2B = Deactivate LM custom trigger $02
	; --$2C = Deactivate LM custom trigger $03
	; --$2D = Deactivate LM custom trigger $04
	; --$2E = Deactivate LM custom trigger $05
	; --$2F = Deactivate LM custom trigger $06
	; --$30 = Deactivate LM custom trigger $07
	; --$31 = Deactivate LM custom trigger $08
	; --$32 = Deactivate LM custom trigger $09
	; --$33 = Deactivate LM custom trigger $0A
	; --$34 = Deactivate LM custom trigger $0B
	; --$35 = Deactivate LM custom trigger $0C
	; --$36 = Deactivate LM custom trigger $0D
	; --$37 = Deactivate LM custom trigger $0E
	; --$38 = Deactivate LM custom trigger $0F
	;
	; -Switch palace flags. Switch palace blocks will only update on level load.
	;
	; --$39 = Toggle green switch palace
	; --$3A = Toggle yellow switch palace
	; --$3B = Toggle blue switch palace
	; --$3C = Toggle red switch palace
	;
	; -Activate and deactivate switch palace flags. Same rule as $13-$38
	;
	; --$3D = Activate green switch palace
	; --$3E = Activate yellow switch palace
	; --$3F = Activate blue switch palace
	; --$40 = Activate red switch palace
	; --$41 = Deactivate green switch palace
	; --$42 = Deactivate yellow switch palace
	; --$43 = Deactivate blue switch palace
	; --$44 = Deactivate red switch palace
	;
	; -Mario vs. Donkey kong switches
	;  Notes:
	;  -ManuelExanimationValue == $00: Blue
	;  -ManuelExanimationValue == $01: Red
	;  -ManuelExanimationValue == $02: Yellow
	;  How this works is when activating any of these colors will have all other colors deactivated, functioning as a mutually exclusive activated colors.
	;  Because of this, it also utilizes the same rule as $13-$38
	;
	; --$45 = Blue mode
	; --$46 = Red mode
	; --$47 = Yellow mode
	;
		;[List of switch action]
		;On SA-1, because the code is much longer, code is more prone to branch bound issues.
		LDA !extra_byte_3,x
		BEQ .OnOffFlip			;>$00: on/off toggle
		CMP #$03		
		BCC .PSwitchToggle		;>$01: blue p-switch, $02: silver
		CMP #$13		
		BCC .CustomTriggersToggle	;>$03-$12: custom triggers
		;BEQ .SetOnOffOn			;>$13: Set on/off to on
		BNE +
		JMP .SetOnOffOn
		+
		CMP #$14
		;BEQ .SetOnOffOff		;>$14: Set on/off to off
		BNE +
		JMP .SetOnOffOff
		+
		CMP #$17
		;BCC .ActivatePSwitch		;>$15-$16: you know what, the label should say everything
		BCS +
		JMP .ActivatePSwitch
		+
		CMP #$19
		;BCC .DeactivatePSwitch		;>$17-$18
		BCS +
		JMP .DeactivatePSwitch
		+
		CMP #$39
		;BCC .CustomTriggersToggle	;>$19-$38 ($19-$28 and $29-$38)
		BCS +
		JMP .CustomTriggersToggle
		+
		CMP #$45
		;BCC .SwitchPalaceToggle		;>$39-$44
		BCS +
		JMP .SwitchPalaceToggle
		+
		CMP #$48
		BCS +				;>Branch out of range
		JMP .MVDKSwitch			;>$45-$47
		+
		RTS				;>Anything else, return (failsafe)
		
		.OnOffFlip
			LDA $14AF|!addr
			EOR #$01
			STA $14AF|!addr
			RTS ;>Keep this RTS here else game will crash.
			
		.PSwitchToggle
			DEC			;\Map $01-$02 to $00-$01, for offsetting from $14AD
			TAY			;/
			LDA $14AD|!addr,y	;>Y: $00 = blue, $01 = silver
			CMP #$02		;>A p-switch timer value of 1 is considered "off" and we do not want an overlap (we deactivate the switch by setting it to $01 to prevent music glitches)
			BCC ..Activate
			
			
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
		.CustomTriggersToggle		;>$03-$12, $19-$28 and $29-$38
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
				;$03-$12, $19-$28 and $29-$38
				LDY #$00
				LDA !extra_byte_3,x
				CMP #$13
				BCC ...Toggle		;>Y = $00, $03-$12
				INY
				CMP #$29
				BCC ...Toggle		;>Y = $01, $19-$28
				INY			;>Y = $02, $29-$38
				
				...Toggle
				LDA !extra_byte_3,x
				SEC
				SBC ...CustomTriggerRanges,y
				STA $00					;>Store custom trigger flags numbering $00-$0F into scratch RAM $00
				LSR #3					;>divide by 8, and round down to obtain which of the 2 bytes of custom triggers to write to
				TAX					;>X = $00 for $7FC0FC and X = $01 for $7FC0FD
				LDA $00
				AND.b #%00000111			;>Modulo by 8 to make it wraparound 0-7, the bit numbering range of 1-byte
				TAY					;>Y = $00-$07, corresponding to what bit number of the custom trigger
				LDA $7FC0FC,x				;\Toggle custom trigger flags
				EOR ReadBitPosition,y			;|
				STA $7FC0FC,x				;/
				LDX $15E9|!addr				;>Restore sprite slot
				
				if !sa1 == 0
					RTS
				else
					PLB
					RTL
				endif
				...CustomTriggerRanges
				db $03		;\Subtract by these values to map them to $00-$0F, the valid range of custom trigger flag numbers.
				db $19		;|
				db $29		;/
		.SetOnOffOn
			STZ $14AF|!addr
			RTS
		.SetOnOffOff
			LDA #$01
			STA $14AF|!addr
			RTS
		.ActivatePSwitch
			SEC
			SBC #$15			;>$15-$16 becomes $00-$01
			TAY
			JMP .PSwitchToggle_Activate
		.DeactivatePSwitch
			SEC
			SBC #$17			;>$17-$18 becomes $00-$01
			TAY
			JMP .PSwitchToggle_Deactivate
		.SwitchPalaceToggle
			LDY #$00
			CMP #$3D
			BCC ..ToggleMode	;>$39-$3C
			INY
			CMP #$41
			BCC ..ActivateMode	;>$3D-$40
			INY
			..DeactivateMode	;>$41-$44
			..ToggleMode
			..ActivateMode
			SEC
			SBC ..SwitchPalaceModeOffset,y
			TAY
			LDA $1F27|!addr,y
			EOR #$01
			STA $1F27|!addr,y
			RTS
			..SwitchPalaceModeOffset
				db $39
				db $3D
				db $41
		.MVDKSwitch
			if !sa1 != 0
				%invoke_snes(..WramAccess)
				RTS
			endif
			
			..WramAccess
				if !sa1 != 0
					PHB
					PHK
					PLB
					LDX $15E9|!addr
				endif
				LDA !extra_byte_3,x
				SEC
				SBC #$45		;$45-$47 -> $00-$02
				STA $7FC070+!ManuelExanimationSlotToUse
				if !sa1 == 0
					RTS
				else
					PLB
					RTL
				endif
endmacro
macro EveryFrameCode()
	EveryFrameCode:
		;Input:
		;-RAM $00 (1 byte): Is running under init:
		; -$00 = no
		; -$01 = yes (switch will appear instantly pressed or not). $14C8 cannot be used to check if the sprite is running on init or main.
		; This is so that switches appear pressed when they spawn.
		
		.PressedPermanentlyBit
			;This code is placed here rather than on init so if you have 2 switches on-screen on the same permanent flag, both will be pressed, rather than
			;only one pressed with the other being pressed when despawning and then respawning.
			LDA !extra_byte_1,x
			BIT.b #%00000001
			BEQ ..NotPermanent
			LDA !extra_byte_4,x			;\BitIndex = FlagNumber % 8
			AND.b #%00000111			;|
			TAY					;/
			LDA !extra_byte_4,x			;\ByteIndex = floor(FlagNumber / 8)
			LSR #3					;|
			TAX					;/
			LDA !Freeram_PressedSwitchMemory,x	;\If the flag we are checking...
			AND ReadBitPosition,y			;/
			LDX $15E9|!addr				;>Restore current sprite slot
			CMP #$00				;>Compare with A, not X
			BNE .Pressed				;>...Clear, then spawn as "not pressed"
			
			..NotPermanent
		;[List of switch action]
		;On SA-1, because the code is much longer, code is more prone to branch bound issues.
		LDA !extra_byte_3,x			;\Check if extra byte would make the switch perform action that would make other switches be pressed
		CMP #$13				;|
		BCC .No					;|
		BEQ .BePressedWhenOnOffIsOn		;|
		CMP #$14				;|
		BEQ .BePressedWhenOnOffIsOff		;/
		CMP #$17
		BCC .BePressedWhenPSwitchIsOn		;>$15-$16
		CMP #$19
		BCC .BePressedWhenPSwitchIsOff		;>$17-$18
		CMP #$29
		BCC .BePressedWhenCustTriggerIsOn	;>$19-$28
		CMP #$39
		BCC .BePressedWhenCustTriggerIsOff	;>$29-$38
		CMP #$3D
		BCC .No					;>$39-$3C
		CMP #$41
		;BCC .BePressedWhenSwitchPalaceIsOn	;>$3D-$40
		BCS +
		JMP .BePressedWhenSwitchPalaceIsOn
		+
		CMP #$45
		;BCC .BePressedWhenSwitchPalaceIsOff	;>$41-$44
		BCS +
		JMP .BePressedWhenSwitchPalaceIsOff
		+
		CMP #$48
		;BCC .BePressedIfMVDKSwitchModeMatch	;>$45-$47
		BCS +
		JMP .BePressedIfMVDKSwitchModeMatch
		+
		.No
		RTS
		
		.BePressedWhenOnOffIsOn
			LDA $14AF|!addr
			BNE .NonPressed			;\if On/off switch is ON, be non-pressed
			BRA .Pressed			;/(pressed if ON)
		.BePressedWhenOnOffIsOff
			LDA $14AF|!addr
			BEQ .NonPressed			;\if On/off switch is OFF, be non-pressed
			BRA .Pressed			;/(pressed if OFF)
		.Pressed
			JSR BeInPressedState
			RTS
		.NonPressed
			JSR BeInNonPressedState
			RTS
		.BePressedWhenPSwitchIsOn
			SEC
			SBC #$15
			TAY
			LDA $14AD|!addr,y
			CMP #$02
			BCC .NonPressed
			BRA .Pressed
		.BePressedWhenPSwitchIsOff
			SEC
			SBC #$17
			TAY
			LDA $14AD|!addr,y
			CMP #$02
			BCC .Pressed
			BRA .NonPressed
		.BePressedWhenCustTriggerIsOn	;>$19-$28
		.BePressedWhenCustTriggerIsOff	;>$29-$38
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
				LDY #$00
				LDA !extra_byte_3,x
				CMP #$29
				BCC ...Activate	;>If $19-$28
				...Deactivate ;>Otherwise $29-$38
					INY
				...Activate
				SEC
				SBC ...MapFlagNumberingToZero,y
				STA $01
				LDA !extra_byte_3,x
				CMP #$29
				BCC ...PressedIfActivated
				
				...PressedIfDeactivated
					JSR ReadCustomTriggerBit
					BEQ ...Pressed
					BRA ...NotPressed
				...PressedIfActivated
					JSR ReadCustomTriggerBit
					BNE ...Pressed
				...NotPressed
					JSR BeInNonPressedState
					BRA ...Done
				...Pressed
					JSR BeInPressedState
				...Done
				if !sa1 == 0
					RTS
				else
					PLB
					RTL
				endif
				
				...MapFlagNumberingToZero
				db $19	;>$19-$28 becomes $00-$0F
				db $29	;>$29-$38 becomes $00-$0F
		.BePressedWhenSwitchPalaceIsOn
			SEC
			SBC #$3D
			TAY
			LDA $1F27|!addr,y
			BNE ..Pressed
			..NotPressed
				JSR BeInNonPressedState
			RTS
			..Pressed
				JSR BeInPressedState
			RTS
		.BePressedWhenSwitchPalaceIsOff
			SEC
			SBC #$41
			TAY
			LDA $1F27|!addr,y
			BEQ .BePressedWhenSwitchPalaceIsOn_Pressed
			BRA .BePressedWhenSwitchPalaceIsOn_NotPressed
		.BePressedIfMVDKSwitchModeMatch
			if !sa1 != 0
				%invoke_snes(..WramAccess)
				RTS
			endif
			
			..WramAccess
				if !sa1 != 0
					PHB
					PHK
					PLB
					LDX $15E9|!addr
				endif
				LDA !extra_byte_3,x
				SEC
				SBC #$45		;$45-$47 -> $00-$02
				CMP $7FC070+!ManuelExanimationSlotToUse
				BNE ...NotPressed
				...Pressed
					JSR BeInPressedState
					BRA ...Done
				...NotPressed
					JSR BeInNonPressedState
				...Done
				if !sa1 == 0
					RTS
				else
					PLB
					RTL
				endif
endmacro
if !Held_Down_Function != 0
	macro SwitchActionHeldDown()
		SwitchActionHeldDown:
		RTS
	endmacro
endif

Print "INIT ",pc
	InitCode:
		PHB
		PHK
		PLB
		LDA #!Button_NotPressedOffset	;\So that button caps aren't position weirdly when they spawn on the screen as the player
		STA !ButtonCapOffset,x		;/comes out of a pipe
		LDA #$01
		STA $00
		JSR EveryFrameCode		;>should be initially pressed?
		.SwitchOffsetBasedOnUpsidedownOrNot		;\Switch position itself to be mounted on surfaces
			LDY #$00				;|
			LDA !extra_byte_1,x			;|
			BIT.b #%00010000			;|
			BEQ +					;|
			INY					;|
			+					;|
			LDA !D8,x				;|
			CLC					;|
			ADC.b SwitchSpriteYSpawnOffset,y	;|
			STA !D8,x				;|
			LDA !14D4,x				;|
			ADC SwitchSpriteYSpawnOffsetHigh,y	;|
			STA !14D4,x				;/
	
		.HandleLayer2SpawnPosition	;>Same as above but on moving layer 2
			LDA !extra_byte_1,x
			BIT.b #%01000000
			BEQ ..NotLayer2
			;SpriteYPosL2 = SpriteYPos - (Layer2YPos - Layer1YPos)
			REP #$20
			LDA $1468|!addr
			SEC
			SBC $1464|!addr
			STA $00			;HAD to store to $00 or some other RAM so the high byte is handled properly
			SEP #$20
			LDA !D8,x
			SEC
			SBC $00
			STA !D8,x
			LDA !14D4,x
			SBC $01
			STA !14D4,x
			
			;SpriteXPosL2 = SpriteXPos - (Layer2XPos - Layer1XPos)
			REP #$20
			LDA $1466|!addr
			SEC
			SBC $1462|!addr
			STA $00			;HAD to store to $00 or some other RAM so the high byte is handled properly
			SEP #$20
			LDA !E4,x
			SEC
			SBC $00
			STA !E4,x
			LDA !14E0,x
			SBC $01
			STA !14E0,x
			..NotLayer2
		PLB
		RTL
	
	SwitchSpriteYSpawnOffset:
	db $08-1		;Sprites appear 1 pixel lower than their original Y position.
	db $F8
	SwitchSpriteYSpawnOffsetHigh:
	db $00
	db $FF
	
	ReadBitPosition:
	db %00000001
	db %00000010
	db %00000100
	db %00001000
	db %00010000
	db %00100000
	db %01000000
	db %10000000

Print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Button
	PLB
	RTL

Button:
	%SubOffScreen()			;>We don't want the switch sprite to potentially fill up all the sprite slots.
	LDA !extra_byte_1,x
	BIT.b #%00010000
	BNE +
	JSR HandleGFX			;Handle graphics
	BRA ++
	
	+
	JSR HandleGFXUpsideDown
	
	++
	LDA $9D				;freeze flag
	;BNE .Done			;
	BEQ +
	RTS
	+
	
	.RunMain
		STZ $00
		JSR EveryFrameCode
		..ButtonCapPopOut
			LDA !ButtonState,x		;\If switch isn't temporally pressed down, skip
			BEQ ...NoPop			;/
			CMP #$02
			BEQ ...NoPop
			LDA !extra_byte_1,x		;\If set to allow pressing without the Dpad, skip (this would allow player to use the switch without having to get off of it)
			AND.b #%00000010		;/
			BNE ...SkipPlayerHoldingItDown	;>If switch requires D-pad pressing down, allow switch to pop back out even if player is touching it
			JSL $03B664|!BankB		;>Get player hitbox info (clipping B)
			JSL $03B69F|!BankB		;>Get sprite hitbox info (clipping A)
			JSL $03B72B|!BankB		;>Check contact
			BCS ...NoPop			;>If player is inside the switch, don't allow it to pop (when set to activate without pressing down on D-pad)
		
			...SkipPlayerHoldingItDown
			LDA !extra_byte_1,x
			AND.b #%00001000
			BEQ ...IgnoreOtherSprites
			JSR SpriteTouchSwitchCheck
			BCS ...NoPop
			...IgnoreOtherSprites
			LDA !ButtonPressedTimer,x	;\If timer runs out, revert switch
			BNE ...NoPop			;|
			STZ !ButtonState,x		;/
			...NoPop
		..MarioRelativePosToSpr
			LDA !extra_byte_1,x
			BIT.b #%00010000
			BNE ...UpsideDownPosition
			
			...RightSideUp
				LDY #$00			;\Y = $00 if displacement is positive, $FF if negative (allows 8-bit signed value to represent signed 16-bit)
				LDA !ButtonCapOffset,x		;|
				BPL ....NonNegativeOffset	;|
				INY				;/
				....NonNegativeOffset
				LDA !D8,x			;\Make hitbox of button cap move with the position of the cap
				CLC				;| (SwitchCapSpriteY = SpriteY + Displacement)
				ADC !ButtonCapOffset,x		;| $00-$01: Position of button cap
				STA $00				;|
				LDA !14D4,x			;|
				ADC ButtonCapHighByteDisp,y	;|
				STA $01				;/
				BRA +
			 ...UpsideDownPosition
				LDA !D8,x
				STA $00
				LDA !14D4,x
				STA $01
			+
			REP #$20			;\$00-$01: Mario's Y position relative to button cap, previous frame (this must be performed before ALL forms of movement (including calling $01ABCC/$01801A/$018022/$01802A) to account his final position)
			LDA $D3				;| (MarioYRelativePrev = MarioYPrev - SwitchCapSpriteYPrev)
			SEC				;| Thanks to RAM $D1-$D4 for storing Mario's previous XY.
			SBC $00				;|
			STA $00				;/
			SEP #$20
		..MoveWithLayer2
			LDA !extra_byte_1,x
			BIT.b #%01000000
			BEQ ..CapMovement
			
			...YMove
				LDY #$00
				LDA $17BE|!addr
				BPL ....Positive
				....Negative
					INY
				....Positive
				LDA !D8,x
				SEC
				SBC $17BE|!addr
				STA !D8,x
				LDA !14D4,x
				SBC PositiveNegativeHighByte,y
				STA !14D4,x
			...XMove
				LDY #$00
				LDA $17BF|!addr
				BPL ....Positive
				....Negative
					INY
				....Positive
				LDA !E4,x
				SEC
				SBC $17BF|!addr
				STA !E4,x
				LDA !14E0,x
				SBC PositiveNegativeHighByte,y
				STA !14E0,x
		..CapMovement
			LDA !ButtonState,x
			BNE ...MoveDown
			
			...MoveUp
				LDA !ButtonCapOffsetFixedPoint,x
				SEC
				SBC.b #!ButtonUpSpeed
				STA !ButtonCapOffsetFixedPoint,x
				LDA !ButtonCapOffset,x
				SBC.b #!ButtonUpSpeed>>8
				STA !ButtonCapOffset,x
				LDA.b #!Button_NotPressedOffset		;\If top limit is above the switch cap's position, (or cap is below the limit), move upwards
				CMP !ButtonCapOffset,x			;|(placed here to prevent 1-frame of exceeding limit)
				BMI ...MoveDone				;/
				STA !ButtonCapOffset,x			;>Otherwise set its position at the limit
				BRA ...MoveDone
			...MoveDown
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
				BPL ...MoveDone				;/
				+
				STA !ButtonCapOffset,x			;>Otherwise set its position at the limit
				BRA ...MoveDone
				
			...MoveDone
		..CollisionWithMario
			LDA !D8,x		;Temporary move the sprite so that the solid hitbox ($01B44F) account for the moved button cap
			PHA
			LDA !14D4,x
			PHA
			
			LDA !extra_byte_1,x
			BIT.b #%00010000
			BEQ ...HitboxWithPlayer
			JMP ...UpSideDownHitboxWithPlayer
			...HitboxWithPlayer
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
				BNE ....NoClipFix					;/
				;LDA $7D						;\If player going upward, don't boost him
				;BMI ....NoClipFix					;/this is buggy like I said before.
				REP #$20
				LDA $02						;\Mario's Y position delta relative to the sprite position delta (if negative, player is moving upwards against sprite, 0, player and sprite moving at same pixels per frame, positive, player moves downwards against sprite)
				SEC						;|Effectively, this is the "speed" (in pixels per frame) of Mario moving against the sprite.
				SBC $00						;/
				SEP #$20					;\This is a "platform pass fix": https://www.smwcentral.net/?p=section&a=details&id=13557 - this time, instead of using [MarioXYSpeedRelativeToSprite = MarioXYSpeed - SpriteXYspeed], we do
				BMI ....NoClipFix				;/[MarioXYRelativeToSprite = MarioXYPos - SpriteXYPos] twice, before and after moving the cap up and down. If Mario is moving upwards against, don't apply the set-y-position.
				;^While this fixes a bug where the sprite and Mario moves in the same direction and the
				; sprite moves faster and catches mario, another, it doesn't work if the sprite goes
				; too fast, especially when set to move with layer 2 and uses "Layer 2, Smash 2"
				; (sprite $E9 in LM) and on phase 3 (when the entire 4th block in screen $0B is
				; on-screen). This is because collision check only checks at the starting and ending
				; positions (positions are actually broken up into individual steps of positions, each
				; frame) once per frame of the two things but not in between ("mid-movement" does not
				; exist) within a frame. This speed-phasing bug pretty much exists in all games with
				; physics btw.
				
				;Sprite clipping (the button cap), box A
				JSL $03B69F|!BankB			;>Get sprite clipping A (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
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
				LDA !extra_byte_1,x
				BIT.b #%00100000
				BEQ ....NoClipFix
				JSL $03B72B|!BankB			;\If not touching, don't snap Y position
				BCC ....NoClipFix			;/
				;Place player on top of switch
				LDA !D8,x				;\Snap player Y position
				SEC					;|
				SBC PlayerOnTopOfSwitchYPos,y		;|
				STA $96					;|
				LDA !14D4,x				;|
				SBC #$00				;|
				STA $97					;/
				....NoClipFix
				LDA !extra_byte_1,x
				BIT.b #%00100000
				BNE ....SolidSwitch
				....NonSolidSwitch
					JSL $03B72B|!BankB
					BCS +
					JMP ...NotPressingSwitch
				....SolidSwitch
					JSL $01B44F|!BankB			;>Solid sprite subroutine (stand on top of the switch)
				;BCC ...NotPressingSwitch		;>If not even touching switch, skip
				BCS +
				JMP ...NotPressingSwitch
				+
				....MoveHorizontallyWithL2
					LDA !extra_byte_1,x
					AND.b #%01100000		;>BIT does not work properly (does not modify value in Accumulator), so AND is used instead
					CMP.b #%01100000		
					BNE .....Done			;>If not both solid and move with layer 2, skip
					
					LDY #$00
					LDA $17BF|!addr
					BPL .....Positive
					.....Negative
						INY
					.....Positive
					LDA $94
					SEC
					SBC $17BF|!addr
					STA $94
					LDA $95
					SBC PositiveNegativeHighByte,y
					STA $95
					
					.....Done
				LDA !extra_byte_1,x
				BIT.b #%00000010
				BEQ ....NoDownNeeded	;>If D flag set, player can activate switch by touching the top and press down
				LDA $16
				BIT.b #%00000100
				BNE +
				;BEQ ...NotPressingSwitch	;>If not pressing down, skip
				JMP ...NotPressingSwitch
				+
				....NoDownNeeded
				JSR TriggerSwitch
				JMP ...PlayerCollisionDone
			...UpSideDownHitboxWithPlayer
				LDA !ButtonState,x
				BEQ +
				JMP ...NotPressingSwitch
				+
				
				LDA $96			;\$02-$03: Mario's Y position relative to the button cap, after frame of movement (this must be performed after ALL forms of movement (including calling $01ABCC/$01801A/$018022/$01802A) to account his final position)
				SEC			;|(MarioYRelativeCurrent = MarioYCurrent - SwitchCapSpriteYCurrent)
				SBC !D8,x		;|
				STA $02			;|
				LDA $97			;|
				SBC !14D4,x		;|
				STA $03			;/
				REP #$20
				LDA $02						;\Mario's Y position delta relative to the sprite position delta (if negative, player is moving upwards against sprite, 0, player and sprite moving at same pixels per frame, positive, player moves downwards against sprite)
				SEC						;|Effectively, this is the "speed" (in pixels per frame) of Mario moving against the sprite.
				SBC $00						;/
				STA $0E
				SEP #$20					;\This is a "platform pass fix": https://www.smwcentral.net/?p=section&a=details&id=13557 - this time, instead of using [MarioXYSpeedRelativeToSprite = MarioXYSpeed - SpriteXYspeed], we do
				BEQ +						;>Bugfix if cape mario sticks to the ceiling, his Y speed is set to $00 and not trigger switches.
				BPL ...NotPressingSwitch			;/[MarioXYRelativeToSprite = MarioXYPos - SpriteXYPos] twice, before and after moving the cap up and down. But this is upside down.
				+
				;I'm avoiding using JSL $01B44F (solid sprite subroutine) because the hitbox of that may have a flaw the player could clip into a layer 1 block and trigger the "mario stands on top" and be able to 1-frame jump off, akin to the walljump glitch
				JSL $03B69F|!BankB			;>Get sprite clipping A (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
				LDA $05					;\Modify Y position of sprite
				CLC					;|
				ADC #$08				;|
				STA $05					;|
				LDA $0B					;|
				ADC #$00				;|
				STA $0B					;/
				LDA #$08				;\Modify height
				STA $07					;/
				JSL $03B664|!BankB			;>Get Mario clipping (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
				LDA #$07				;\Only check Mario's head part for collision so that any part of his body wouldn't result in teleporting the player at large distance.
				STA $03					;/(if Big Mario's head hitbox created here was 8 pixels tall, the two hitboxes would be edge-to-edge touching each other, which register as a collision, if the area is in is a 1-block tall space (normally push mario left) with the switch in that space)
				JSL $03B72B|!BankB			;>Check for contact
				BCC ...PlayerCollisionDone
				;My own "solid" code
				;After $03B664 finishes, we have $01 and $09 containing the position of the hitbox of mario, located at the top edge of that box
				;This is offset from a value from the player's Y position, $96-$97. To compute so that the player's Y position is touching the bottom of the switch
				;is PlayerYPosSetTo = (SpriteY + $0010) - (MarioHitboxY - MarioY)
				;Which can be rearranged into:  SpriteY + $0010 - MarioHitboxY + MarioY
				
				LDA !extra_byte_1,x
				BIT.b #%00100000
				BEQ +
				LDA !D8,x				;\(SpriteY + $0010), stored in $0A-$0B (must be stored to properly handle high byte)
				CLC					;|
				ADC #$10				;|
				STA $0A					;|
				LDA !14D4,x				;|
				ADC #$00				;|
				STA $0B					;/
				LDA $0A					;\... - MarioHitboxY 
				SEC					;|
				SBC $01					;|
				STA $0A					;|
				LDA $0B					;|
				SBC $09					;|
				STA $0B					;/
				LDA $0A					;\... + MarioY
				CLC					;|
				ADC $96					;|
				STA $96					;|
				LDA $0B					;|
				ADC $97					;|
				STA $97					;/
				STZ $7D					;>Zero out the Y speed
				+
				JSR TriggerSwitch
			...NotPressingSwitch
			...PlayerCollisionDone
		
		..CollisionWithOtherSprite
			LDA !extra_byte_1,x
			AND.b #%00001000
			BEQ ...NotTouchingSwitch
			LDA !ButtonState,x
			BNE ...SpriteAlreadyPressed	;>If switch pressed, don't allow sprite to re-trigger it (although following subroutine to be executed already checks this, this skips unnecessary looping with pressed)
			JSR SpriteTouchSwitchCheck
			BCC ...NotTouchingSwitch
			JSR TriggerSwitch
			
			...NotTouchingSwitch
			...SpriteAlreadyPressed
		
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
	PlayerFeetOffset:
		db $18		;>Not on yoshi
		db $28		;\On yoshi
		db $28		;/
	PlayerOnTopOfSwitchYPos:
		db $20		;>Not on yoshi
		db $30		;\On yoshi
		db $30		;/
	ButtonCapHighByteDisp:
	PositiveNegativeHighByte:
		db $00		;>If Displacement is $00-$7F (positive value)
		db $FF		;>f Displacement is $80-$FF (negative value)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Graphics routine (JSR)
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
		LDA #!Tile_ButtonBase		;\Tile
		STA.w ($0302+(0*4))|!Base2,y	;|>Left half
		STA.w ($0302+(1*4))|!Base2,y	;/>Right half
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
FinishOAM:
	LDY #$00			;tile size = 8x8
	LDA #$03			;tiles to display minus 1 = 3 (4 tiles, minus 1 = 3)
	JSL $01B7B3|!BankB		;
	RTS				;
HandleGFXUpsideDown:
	%GetDrawInfo()			;
	;Switch base
		LDA $00				;\X position
		STA.w ($0300+(0*4))|!Base2,y	;|>Left half
		CLC				;|
		ADC #$08			;|
		STA.w ($0300+(1*4))|!Base2,y	;/>Right half
		LDA $01				;\Y position
		CLC				;|
		ADC.b #$00+2			;|
		STA.w ($0301+(0*4))|!Base2,y	;|>Left half
		STA.w ($0301+(1*4))|!Base2,y	;/>Right half
		LDA #!Tile_ButtonBase		;\Tile
		STA.w ($0302+(0*4))|!Base2,y	;|>Left half
		STA.w ($0302+(1*4))|!Base2,y	;/>Right half
		LDA.b #($80|(!SwitchBasePalette<<1)|!GFXPage)
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
			SEC					;|
			SBC !ButtonCapOffset,x			;|
			CLC					;|
			ADC #$08				;|
			STA.w ($0301+(2*4))|!Base2,y		;|>Left half
			STA.w ($0301+(3*4))|!Base2,y		;/>Right half
		LDA #!Tile_ButtonCap			;\Tile
		STA.w ($0302+(2*4))|!Base2,y		;|>Left half
		STA.w ($0302+(3*4))|!Base2,y		;/>Right half
		LDA !extra_byte_2,x		;>Palette as extra byte 2
		AND.b #%00001110		;>Ignore X flips, page (forcibly set to 0 or 1), and priority
		ORA.b #(%10100000|!GFXPage)	;>Force only some bits of the PP to be set (should not appear behind layers without priority.)
		STA.w ($0303+(2*4))|!Base2,y	;\Properties ;>Left half
		ORA.b #%01000000		;|X-flip it
		STA.w ($0303+(3*4))|!Base2,y	;/>Right half
	JMP FinishOAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Trigger switch (JSR)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TriggerSwitch:
	LDA !ButtonState,x
	BNE .Done		;>If switch pressed, don't allow re-triggers
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
		LDA !extra_byte_4,x		;\BitIndex = FlagNumber % 8
		AND.b #%00000111		;|
		TAY				;/
		LDA !extra_byte_4,x		;\ByteIndex = floor(FlagNumber / 8)
		LSR #3				;|
		TAX				;/
		LDA !Freeram_PressedSwitchMemory,x
		ORA ReadBitPosition,y
		STA !Freeram_PressedSwitchMemory,x
		LDX $15E9|!addr		;>Restore current sprite slot
	.SwitchFunction
		JSR SwitchAction
	.Done
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Sprite touch switch check (JSR)
;Output:
; -Carry: Clear if no contact with dropped/kicked sprite, set
;  otherwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SpriteTouchSwitchCheck:
	;Get hitbox A (the switch hitbox, self sprite)
	JSL $03B69F|!BankB		;>Get sprite hitbox info (clipping A)
	LDA #$08			;\Modify hitbox height
	STA $07				;/
	LDY #$00			;\Y position of hitbox depending if the switch is upside down or not
	LDA !extra_byte_1,x		;|
	BIT.b #%00010000		;|
	BEQ +				;|
	INY				;|
	+				;|
	LDA $05				;|
	CLC				;|
	ADC .UpsideDownSwitchHitbox,y	;|
	STA $05				;|
	LDA $0B				;|
	ADC #$00			;|
	STA $0B				;/
	LDX.b #!SprSize-1			;>Start at last index of sprite and loop counting until X=$FF (loops from 11/21 to 0)
	.Loop
		..CheckCollision
			CPX $15E9|!addr		;\If itself, then skip
			BEQ ..Next		;/
			LDA !14C8,x		;\If other sprite is kicked/carryable/carried, proceed
			CMP #$09		;|
			BCC ..Next		;|
			CMP #$0C		;|
			BCS ..Next		;/
			...Carryable
			...Kicked
				;Hitbox B
				JSL $03B6E5|!BankB		;>Hitbox B
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
	.UpsideDownSwitchHitbox
	db $00					;>Hitbox Y position for floor switches
	db $08					;>Same as above but for ceiling switches
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Pressed states (JSR), had to be its own subroutine for SA-1
;compatibility reasons (if access to WRAM is needed, such as
;LM's custom trigger flags).
;
;Input:
; -RAM $00: $00 = not init, $01 = init (buttons appear pressed
;   or not pressed instantly)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BeInPressedState:
	LDA #$02			;\Pressed state (stays pressed)
	STA !ButtonState,x		;/
	LDA $00				;>When spawning, appear pressed
	BEQ .NotInit
	.Init
		LDA.b #!Button_PressedOffset
		STA !ButtonCapOffset,x
	.NotInit
	RTS
BeInNonPressedState:
	LDA !ButtonState,x		;\Don't forcibly pop back up under the player's feet or if it is held down by other sprite.
	BEQ .AlreadyNotPressed		;/
	LDA #$01
	STA !ButtonState,x		;\Non-pressed state (actually, it is pressed, but won't rise up until mario or sprite gets off switch)
	STZ !ButtonPressedTimer,x	;/
	LDA $00				;>When spawning, appeared non-pressed
	BEQ .NotInit
	.Init
		LDA.b #!Button_NotPressedOffset
		STA !ButtonCapOffset,x
	.NotInit
	.AlreadyNotPressed
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read custom trigger flags
;
; Input:
;  -$01: What bit number to check ($00-$0F)
; Output:
;  -A: Use BEQ/BNE to check:
;   $00: If checked bit is clear
;   Nonzero_Value: If checked bit is set.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadCustomTriggerBit:
	LDA $01					;\X = what byte of custom triggers, Y = what bit of custom triggers
	AND.b #%00000111			;|
	TAY					;|
	LDA $01					;|
	LSR #3					;|
	TAX					;|
	LDA $7FC0FC,x				;|
	AND ReadBitPosition,y			;/
	LDX $15E9|!addr				;>Restore sprite slot
	CMP #$00				;>Compare with A, not X
	RTS