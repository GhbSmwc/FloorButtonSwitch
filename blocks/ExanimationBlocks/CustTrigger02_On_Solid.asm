;Settings
 !CustTriggerBitToRead = $02		;>What custom trigger number to read, only use $00-$0F.
 !SolidOn = 1				;>0 = Solid if custom trigger is "off", 1 = solid when on.
;Don't touch
 ;Get what custom trigger byte and bit
  !CustTrigger_7FC0FC_LowOrHigh #= !CustTriggerBitToRead/8
  !CustTrigger_7FC0FC_WhatBit #= !CustTriggerBitToRead%8
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
	macro CustomTriggerSolid(CustomTrigger)
		LDA <CustomTrigger>
		BIT.b #(1<<!CustTrigger_7FC0FC_WhatBit)
		if !SolidOn == 0
			BEQ .Solid
		else
			BNE .Solid
		endif
		RTL			;>Leave it to act like whatever block behavior was set to by GPS's block list or LM.
		.Solid
			LDY #$01		;\
			LDA #$30		;|Act like a solid block, tile $130 (cement block)
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
		%CustomTriggerSolid($3100)
	else
		%CustomTriggerSolid($7FC0FC+!CustTrigger_7FC0FC_LowOrHigh)
	endif
MarioCape:
RTL
if !sa1 != 0
	WramAccess:
		LDA $7FC0FC+!CustTrigger_7FC0FC_LowOrHigh	;\Store a copy of $7FC0FC (cannot be accessed via SA-1) to a scratch RAM that is accessible to SA-1
		STA $3100					;/
		RTL
endif

print "Solid if custom trigger $", hex(!CustTriggerBitToRead, 2), " is ", bin(!SolidOn)