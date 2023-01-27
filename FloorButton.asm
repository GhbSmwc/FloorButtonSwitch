;Key
;This is a disassembly of sprite 80 in SMW - Key.
;By RussianMan. Please give credit if used.
;Requested by Hamtaro126.

;Modified to act as a wall button
;sprite by HammerBrother.
;extra_byte_1: Switch itself behavior: 000000DP
;-P = permanent flag: 0 = Can press again, 1 = pressed permanently.
;-D = Require pressing down on D-pad: 0 = no, 1 = yes
;extra_byte_2: color for YXPPCCCT:
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
 
 !Button_NotPressedOffset = $02		;>Y position (relative to sprite's origin) of button cap when not pressed
 !Button_PressedOffset = $07		;>Y position (relative to sprite's origin) of button cap when pressed
 
;Sound effects, see https://www.smwcentral.net/?p=viewthread&t=6665
 !SFX_SoundNumb = $0B		;>Sound effect number
 !SFX_Port = $1DF9		;>Use only $1DF9, $1DFA, or $1DFB.

 ;Misc settings
  ;P-switch mode
   !NoMusic = 0			;>0 = Allow p-switch music, 1 = no (if you've using AddmusicK and disabled the P-switch music)
   !ScreenShake = $20		;>0 = no, any number = yes and how long, in frames

;Sprite table defines
 ;Best not to modify
  !ButtonState = !1534
  !ButtonPressedTimer = !1540
 ;Feel free to modify these
  !FrozenTile = $0165 ;>Tile that turns the tile into when touching liquids.



;Action to perform when switch is pressed.
;Warning: X register must be restored after this code (become a sprite slot index) is finished to prevent bugs/crash.
;Can be done via PHX ... PLX or LDX $15E9|!addr (PLX and LDX $15E9|!addr to be perform after done using X for something else)
macro SwitchAction()
	SwitchAction:
	;Examples:
	;!extra_byte_3 values:
	; -$00 = on/off
	; -$01 = blue p-switch
	; -$02 = silver p-switch
	; -$03 = LM custom trigger $00
	; -$04 = LM custom trigger $01
	; -$05 = LM custom trigger $02
	; -$06 = LM custom trigger $03
	; -$07 = LM custom trigger $04
	; -$08 = LM custom trigger $05
	; -$09 = LM custom trigger $06
	; -$0A = LM custom trigger $07
	; -$0B = LM custom trigger $08
	; -$0C = LM custom trigger $09
	; -$0D = LM custom trigger $0A
	; -$0E = LM custom trigger $0B
	; -$0F = LM custom trigger $0C
	; -$10 = LM custom trigger $0D
	; -$11 = LM custom trigger $0E
	; -$12 = LM custom trigger $0F
		LDA !extra_byte_3,x
		BEQ .OnOffFlip			;>$00: on/off toggle
		CMP #$03		
		BCC .PSwitchToggle		;>$01: blue p-switch, $02: silver
		CMP #$13		
		BCC .CustomTriggersToggle	;>$03-$12: custom triggers
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
				..WramAccess
			endif
			
			;SEC : SBC #$03 causes mapping the range of $03-$12 to be mapped to $00-$0F, the valid bit numbering range for 16-bit numbers and custom trigger flags.
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
			RTS
			
			..CustomTriggerFlagBitNumbering
				db %00000001
				db %00000010
				db %00000100
				db %00001000
				db %00010000
				db %00100000
				db %01000000
				db %10000000
endmacro

Print "INIT ",pc
	;Sprites appear 1 pixel lower than their original Y position.
	LDA !D8,x
	CLC
	ADC.b #$8-1
	STA !D8,x
	LDA !14D4,x
	ADC #$00
	STA !14D4,x
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
	RTL
	+
	
	.RunMain
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
			LDA !ButtonPressedTimer,x	;\If timer runs out, revert switch
			BNE .NoPop			;|
			STZ !ButtonState,x		;/
			.NoPop
		
		LDA !D8,x		;Temporary move the sprite so that the solid hitbox ($01B44F) account for the moved button cap
		PHA
		LDA !14D4,x
		PHA
		LDY !ButtonState,x
		LDA !D8,x
		CLC
		ADC ButtonYpositonPressedState,y
		STA !D8,x
		
		;This is a workaround bypassing a clipping glitch with smw's $01B44F that:
		;-If you crouch-slide as small mario into the side of the switch
		;-If you are big mario and go into the side of the switch
		;The sprite will fail to place mario on top of the switch
			LDA !ButtonState,x				;\Apply the snapping only if the switch is not pressed
			BNE .NoClipFix					;/
			LDA $7D						;\If player going upward, don't boost him
			BMI .NoClipFix					;/
			;Sprite clipping (the button cap), box A
				JSL $03B69F|!BankB			;>Sprite clipping (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
				LDA #$08				;\Modify its height
				STA $07					;/
			;Mario clipping (16x8 area of his feet), box B
				JSL $03B664|!BankB			;>Mario clipping (had to be called again due to some bugs found, probably $03B72B overwrites certain scratch RAM)
				LDY $187A				;>Riding yoshi flag (player is about 3 blocks tall, adds a length of 16 pixel underneath)
				STA $03					;>Modify height of player's hitbox (not that hitbox extends down and right), so we need to...
				LDA $96					;\Move his box Y position (from the info obtained from $03B664)
				CLC					;|
				ADC PlayerFeetOffset,y			;|
				STA $01					;|
				LDA $97					;|
				CLC					;|
				ADC #$00				;|
				STA $09					;/
			;Contact
				JSL $03B72B|!BankB			;\If not touching, don't snap Y position
				BCC .NoClipFix				;/
			;Place player on top of switch
				LDA !D8,x
				SEC
				SBC PlayerOnTopOfSwitchYPos,y
				STA $96
				LDA !14D4,x
				SBC #$00
				STA $97
		.NoClipFix
		JSL $01B44F|!BankB	;>Solid sprite subroutine
		BCC .NotPressingSwitch	;>If not even touching switch, skip
		LDA !ButtonState,x
		BNE .AlreadyPressed	;>If switch pressed, don't allow player triggering it
		
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
		PLA			;\Restore sprite position
		STA !14D4,x		;|
		PLA			;|
		STA !D8,x		;/

	.Done
		RTS
	%SwitchAction()
	
	PlayerFeetOffset:
		db $18		;>Not on yoshi
		db $28		;\On yoshi
		db $28		;/
	PlayerOnTopOfSwitchYPos:
		db $20		;>Not on yoshi
		db $30		;\On yoshi
		db $30		;/
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
	;SlotOffset = 0: Pedestal left half
	;SlotOffset = 1: Pedestal right half
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
		LDA !extra_byte_2,x		;>Palette as extra byte 2
		AND.b #%00001110		;>Ignore XY flips, page (forcibly set to 0 or 1), and priority
		ORA.b #(%00010000|!GFXPage)	;>Part of the switch base behind the layer
		STA.w ($0303+(0*4))|!Base2,y	;\Properties ;>Left half
		ORA.b #%01000000		;|X-flip it
		STA.w ($0303+(1*4))|!Base2,y	;/>Right half
	;Button cap
		LDA $00				;\X position (left half)
		STA.w ($0300+(2*4))|!Base2,y	;|
		CLC				;|
		ADC #$08			;|
		STA.w ($0300+(3*4))|!Base2,y	;/>X position (right half)
		;Y position, depending on pressed state
			PHX					;\Y position
			LDA !ButtonState,x			;|
			TAX					;|
			LDA $01					;|
			CLC					;|
			ADC ButtonYpositonPressedState,x	;|
			STA.w ($0301+(2*4))|!Base2,y		;|>Left half
			STA.w ($0301+(3*4))|!Base2,y		;|>Right half
			PLX					;/
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
	
	ButtonYpositonPressedState:
	db !Button_NotPressedOffset-2		;>Non pressed state
	db !Button_PressedOffset-2		;>pressed (pop back out under a timer)
	db !Button_PressedOffset-2		;>pressed (permanent)