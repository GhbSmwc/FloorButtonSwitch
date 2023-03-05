;Setting
 !WhichManuelFrameSolid = $02		;>Frame number (or what "color") this block will be solid ($00 = blue, $01 = red, $02 = yellow)

;Don't touch
	incsrc "ExanimationSettings.asm"
	macro invoke_snes(addr)
		LDA.b #<addr>
		STA $0183
		LDA.b #<addr>/256
		STA $0184
		LDA.b #<addr>/65536
		STA $0185
		LDA #$D0
		STA $2209
	-	LDA $018A
		BEQ -
		STZ $018A
	endmacro
	macro MVDK_SolidBlocks(ManTrigger)
		LDA <ManTrigger>
		if !WhichManuelFrameSolid != $00	;>If statement so redundant CMP #$00 is not included 
			CMP #!WhichManuelFrameSolid
		endif
		BEQ .Solid
		RTL				;>If colors not match, be passable (or whatever default behavior set by list.txt or LM)
		.Solid
			LDY #$01		;\Act like a solid block, tile $130 (cement block)
			LDA #$30		;|
			STA $1693|!addr		;/
			RTL
	endmacro
db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37


MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:
SpriteV:
SpriteH:
MarioFireball:
	if !sa1 != 0
		%invoke_snes(WramAccess)
		%MVDK_SolidBlocks($3100)
	else
		%MVDK_SolidBlocks($7FC070+!ManuelExanimationSlotToUse)
	endif
MainCode:
MarioCape:
RTL
if !sa1 != 0
	WramAccess:
		LDA $7FC070+!ManuelExanimationSlotToUse		;\Store a copy of $7FC0FC (cannot be accessed via SA-1) to a scratch RAM that is accessible to SA-1
		STA $3100					;/
		RTL
endif

print "Sets MVDK switch mode to blue"
