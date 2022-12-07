			area lab4code, code, readonly
			export __main
;REGISTER DEFINITIONS
SPEED		RN 11
LEDCMP		RN 10
LEVEL		RN 09
SCORE		RN 08
TEMPSCORE	rn 07
TEMPLEVEL	rn 06
;CONSTANT DECLARATIONS
BLULED		EQU 5; DFAULTSCR x 5
GREENLED	EQU 4; DFAULTSCR x 4
YLOWLED		EQU 3; DFAULTSCR x 3
ORNGLED		EQU 2; DFAULTSCR x 2
REDLED		EQU 1; DFAULTSCR x 1
DFAULTSPD	EQU	0xF000; change this to change starting speed
DFAULTINC	EQU 0x0040; change this to change how fast speed increases
DFAULTSCR	EQU	10; base score
INPUT_DELAY	EQU	0x18000; used for led flash and gameover
LOWEST_SPD	EQU	2000; The fastest speed the game will go to	
RS			equ 0x20	; P3.5
RW			equ 0x40	; P3.6
EN			equ 0x80	; P3.7
ZERO		equ 0x30
LCD_DELAY	equ	0xFFF
	
__main		proc
			;VARIABLE DEFINITIONS
			BL LCDInit
			ldr SCORE, =0;
			ldr SPEED, =DFAULTSPD; How fast the LEDs switch
			ldr LEVEL, =1; starting level should always be 0
			mov TEMPLEVEL, LEVEL
			mov TEMPSCORE, SCORE
	
rescore	    mov r2, 0x01;
			BL LCDCommand
			mov r2, 0x80;
			BL LCDCommand

			mov r3, #'L'
			BL LCDData

			mov r3, #'E'
			BL LCDData

			mov r3, #'V'
			BL LCDData

			mov r3, #'E'
			BL LCDData

			mov r3, #'L'
			BL LCDData

			mov r3, #':'
			BL LCDData

			mov r3, ZERO
			add r3, TEMPLEVEL
			BL LCDData
			
			mov r2, 0xC0;
			BL LCDCommand
			
			mov r3, #'S'
			BL LCDData

			mov r3, #'C'
			BL LCDData
			
			mov r3, #'O'
			BL LCDData

			mov r3, #'R'
			BL LCDData

			mov r3, #'E'
			BL LCDData

			mov r3, #':'
			BL LCDData

			mov r3, ZERO
			;add r3, TEMPSCORE
			BL LCDData
			
			;PORT 2 Configuration
			ldr r0, =0x40004c00; port 1 base address
			add r0, #0x01; port 2 input
			mov r1, #0xF8 ;   all of port 2 is output
			strb r1, [R0, #0x04]; p4 configuration is done
			
			;port 1 -- Configuration
			ldr r4, =0x40004c00; port 1 base address
			mov r1, #0x00 ; all port 1 are inputs
			strb r1, [r4, #0x04]; p1 output configuration is done	
			mov r1, #0xFF
			strb r1, [r4, #0x06]; p1.all resistor enabled
			strb r1, [r4, #0x02]; p1.all pullup
			
; FROM LEFT TO RIGHT
repeat		
			mov r3, #0x08; high signal to p2.3 only {0x01 is for pin0)
			strb r3, [r0, #0x02]; send/store signal out to GPIO register P4OUT
			bl delay; warps us to the delay function
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00; lo signal to all of port 2
			strb r3, [r0, #0x02]; send/store signal out to GPIO register P4OUT
			;bl delay;  The LED connected to P6.0 will blink
			
			; this block is for 2.4
			mov r3, #0x10;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
			
			; this block is for 2.5
			mov r3, #0x20;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
			
			; this block is for 2.6
			mov r3, #0x40;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
			
			; this block is for 2.7
			mov r3, #0x80;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
	
;FROM RIGHT TO LEFT
			; this block is for 2.7
			;mov r3, #0x80;
			;strb r3, [r0, #0x02];
			;bl delay;
			;bl buttonCheck; will check and distribute points as such
			;mov r3, #0x00;
			;strb r3, [r0, #0x02];
			;bl delay;
			
			; this block is for 2.6
			mov r3, #0x40;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
			
			; this block is for 2.5
			mov r3, #0x20;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck; will check and distribute points as such
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
			
			; this block is for 2.4
			orr r3, #0x10;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck;
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;
			
			;2.3 output led
			orr r3, #0x08;
			strb r3, [r0, #0x02];
			bl delay;
			bl buttonCheck;
			mov r3, #0x00;
			strb r3, [r0, #0x02];
			;bl delay;

			bl speedCheck
			
			push{r3}
			push{r2}
			push{r1}
			push{r0}
			
			ldr r0, =0x40004C20		; Port3: address of control inputs
			ldr r1, =0x40004C21		; Port4: address for data or command inputs
			
			mov r2, #0x86
			BL LCDCommand
			
			
			mov TEMPLEVEL, LEVEL
			mov TEMPSCORE, SCORE
			
			
			mov r3, ZERO
			cmp  TEMPLEVEL, #100
			blt modfirstL ; if it's smaller than 99, just leave this 

modL		sub TEMPLEVEL, #100 ; subtract by 100
			add r3, #1 ; add this value to the highest digit
			cmp TEMPLEVEL, #100 ; comparison
			bge modL
		
			BL LCDData ; final digit

			mov r3, ZERO
			cmp TEMPLEVEL, #10
			bge modfirstL
			
			BL LCDData
			b modsecondL ;if it's smaller than 9, just leave this
			
			
modfirstL	cmp TEMPLEVEL, #10
			blt modsecondL
			sub TEMPLEVEL, #10 ;subtract by 10
			add r3, #1 ;add this value to the second highest digit
			cmp TEMPLEVEL, #10 ; comparison
			bge modfirstL
			
			
			BL LCDData ; final digit
			
modsecondL	mov r3, ZERO
			add r3, TEMPLEVEL
			BL LCDData
	
			mov r2, #0xC6
			BL LCDCommand
			
			mov r3, ZERO
			cmp  TEMPSCORE, #1000
			blt modfirst ; if it's smaller than 1000, just leave this 

mod			sub TEMPSCORE, #1000 ; subtract by 1000
			add r3, #1 ; add this value to the highest digit
			cmp TEMPSCORE, #1000 ; compare again
			bge mod
			
			BL LCDData ; final digit
			
			mov r3, ZERO
			cmp TEMPSCORE, #100
			bge modfirst
			
			BL LCDData
			b modsecond ;if it's smaller than 100, just leave this
			
modfirst	cmp TEMPSCORE, #100
			blt modsecond
			sub TEMPSCORE, #100 ;subtract by 100
			add r3, #1 ;add this value to the second highest digit
			cmp TEMPSCORE, #100 ; compare again
			bge modfirst
			
			BL LCDData ; final digit
			
			mov r3, ZERO
			cmp TEMPSCORE, #10
			bge modsecond
			
			BL LCDData
			b modthird ;if it's smaller than 100, just leave this
			
modsecond	cmp TEMPSCORE, #10
			blt modthird
			sub TEMPSCORE, #10 ;subtract by 10
			add r3, #1 ;add this value to the second highest digit
			cmp TEMPSCORE, #10 ; compare again
			bge modsecond
			
			BL LCDData ; final digit
			
modthird    mov r3, ZERO
			add r3, TEMPSCORE
			BL LCDData
			
			
			pop{r0}
			pop{r1}
			pop{r2}
			pop{r3}
			
			b repeat
			endp
				
delay		function
			mov r12, SPEED;
continue	sub r12, #1; subtracts by 1 bit
			cmp r12, #0 ; if (r12-0) is not zero, continue
			bne continue; goes back to start of function
			BX lr
			endp

				
buttonCheck	function
			ldrb r5, [r4, #0x00]; input reg is loaded to r5
			and r5, #0x80; if button pressed = 0, not pressed = 1
			cmp r5, #00; if button pressed, check led. 
			beq checkled
			bx lr; will get here if button is not pressed
			
checkled; can only get here if the button is pressed
			;FLASH LEDS
			push{lr}
			bl ledFlash;
			pop{lr}
			
			add LEVEL, #1 ; increment levels. Button should have been pressed at this point
		
			;RED---------------------------------------------------------------------
			mov LEDCMP, r3;
			cmp LEDCMP, #0x08
			bne led1;  if not equal to led 0, go check led 1 
			subs SPEED, #DFAULTINC; else incr speed by x amount
			;SPEED INCR
			mov r2, #DFAULTINC
			mul r2, r2, LEVEL
			subs SPEED, r2; else incr speed by x amount
			;SCORE UPDATING
			mov r2, #REDLED; r2 = redled(1)
			mov r3, #DFAULTSCR; r3 = dfaultscr (10)
			mul r2, r2, r3; r2 = r2 * r3
			add SCORE, r2 ; add r2 to rSCORE
			;SCORE UPDATE END
			
			push{lr}
			bl speedCheck
			pop{lr}
			b repeat ;reset back to first led
			
			;ORNG-------------------------------------------------------------------
led1		mov LEDCMP, r3;
			cmp LEDCMP, #0x10
			bne led2;  if not equal to led 1, go check led 2 
			subs SPEED, #DFAULTINC; else incr speed by x amount
			;SPEED INCR
			mov r2, #DFAULTINC
			mul r2, r2, LEVEL
			subs SPEED, r2; else incr speed by x amount			
			;SCORE UPDATING
			mov r2, #ORNGLED; r2 = orngled(2)
			mov r3, #DFAULTSCR; r3 = dfaultscr (10)
			mul r2, r2, r3; r2 = r2 * r3
			add SCORE, r2 ; add r2 to rSCORE
			;SCORE UPDATE END
			
			push{lr}
			bl speedCheck
			pop{lr}
			b repeat ;reset back to first led
			
			;YLOW----------------------------------------------------------------
led2		mov LEDCMP, r3;
			cmp LEDCMP, #0x20
			bne led3;  if not equal to led 2, go check led 3 
			subs SPEED, #DFAULTINC; else incr speed by x amount
			;SPEED INCR
			mov r2, #DFAULTINC
			mul r2, r2, LEVEL
			subs SPEED, r2; else incr speed by x amount			
			;SCORE UPDATING
			mov r2, #YLOWLED; r2 = ylowled(3)
			mov r3, #DFAULTSCR; r3 = dfaultscr (10)
			mul r2, r2, r3; r2 = r2 * r3
			add SCORE, r2 ; add r2 to rSCORE
			;SCORE UPDATE END
			
			push{lr}
			bl speedCheck
			pop{lr}
			b repeat ;reset back to first led
			
			;GREEN----------------------------------------------------------------
led3		mov LEDCMP, r3;
			cmp LEDCMP, #0x40
			bne led4;  if not equal to led 3, go check led 4 
			;SPEED INCR
			mov r2, #DFAULTINC
			mul r2, r2, LEVEL
			subs SPEED, r2; else incr speed by x amount
			;SCORE UPDATING
			mov r2, #GREENLED; r2 = bluled(4)
			mov r3, #DFAULTSCR; r3 = dfaultscr (10)
			mul r2, r2, r3; r2 = r2 * r3
			add SCORE, r2 ; add r2 to rSCORE
			;SCORE UPDATE END
			
			push{lr}
			bl speedCheck
			pop{lr}
			b repeat ;reset back to first led
			
			;BLUE-------------------------------------------------------------------
led4		mov LEDCMP, r3;
			cmp LEDCMP, #0x80
			;SPEED INCR
			mov r2, #DFAULTINC
			mul r2, r2, LEVEL
			subs SPEED, r2; else incr speed by x amount
			;SCORE UPDATING
			mov r2, #BLULED; r2 = bluled(5)
			mov r3, #DFAULTSCR; r3 = dfaultscr (10)
			mul r2, r2, r3; r2 = r2 * r3
			add SCORE, r2 ; add r2 to rSCORE
			;SCORE UPDATE END
			
			push{lr}
			bl speedCheck
			pop{lr}
			b repeat ;reset back to first led
			
noLives; gets here if speed or lives are 0
			; ALL LEDs ON
			ldr SPEED, = INPUT_DELAY; return to default led speed
			mov r3, #0xF8; high signal to p2.all only {0x01 is for pin0)
			strb r3, [r0, #0x02]; send/store signal out to GPIO register P4OUT
			bl delay;

			; ALL LEDs OFF
			mov r3, #0x00; lo signal to all of port 2
			strb r3, [r0, #0x02]; send/store signal out to GPIO register P4OUT
			bl delay;
			b noLives;
			endp
				
speedCheck	function
			mov LEDCMP, SPEED;
			cmp LEDCMP, #LOWEST_SPD; check if LEDCMP, which holds speed, is less than whatever value 
			ble noLives;
			
			mov LEDCMP, SPEED;
			cmp LEDCMP, #DFAULTSPD; checks for int overflow, as speed should never be greater than default
			bgt noLives;
			
			bx lr
			endp

ledFlash function; flashes the current led that is lit
			push{lr}
			push{SPEED}
			push{r3}

			;ALL ON
			ldr SPEED, =INPUT_DELAY;
			mov LEDCMP, #0x00
			strb r3, [r0, #0x02]
			bl delay;
			
			;ALL OFF
			strb LEDCMP, [r0, #0x02]
			bl delay;
			
			;ALL ON
			strb r3, [r0, #0x02]
			bl delay;
			
			;ALL OFF
			strb LEDCMP, [r0, #0x02]
			bl delay;
		
			pop{r3}
			pop{SPEED}
			pop {lr}
			
			bx lr;
			endp
			
LCDInit		function
					
			ldr r0, =0x40004C20		; Port3: address of control inputs
			ldr r1, =0x40004C21		; Port4: address for data or command inputs 		
			
			mov r2, #0xE0			; 1110 0000 
			strb r2, [r0, #0x04]	; outputs pins for EN, RW, RS
			mov r2, #0xFF
			strb r2, [r1, #0x04]	; All of Port 4 as output pins to LCD
			
			push {LR}		
			mov r2, #0x38			; 2 lines, 7x5 characters, 8-bit mode		 
			BL LCDCommand

			mov r2, #0x01
			BL LCDCommand
			
			mov r2, #0x0F
			BL LCDCommand
			
			mov r2, #0x02
			BL LCDCommand
			
			mov r2, #0x06
			BL LCDCommand
			; add instructions to turn ON the display and cursor, clear display
			;	and move cursor right			
			
			pop {LR}			
			
			BX LR
			endp
				
LCDCommand	function				; r2 brings in the command byte
			strb r2, [r1, #0x02]
			mov r2, #0x00			; RS = 0, command register selected, RW = 0, write to LCD
			ORR r2, EN
			strb r2, [r0, #0x02]	; EN = 1
			
			push {LR}
			push {SPEED}
			mov SPEED, LCD_DELAY
			BL delay
			pop	{SPEED}
			pop {LR}
			
			mov r2, #0x00
			strb r2, [r0, #0x02]	; EN = 0 and RS = RW = 0	
	
			BX LR
			endp				
				
LCDData		function			; r3 has the character
			; complete this function referring to LCDCommand and the Table 3 from the handout
			strb r3, [r1, #0x02]
			mov r3, #0x00
			mov r2, #0x00			; RS = 0, command register selected, RW = 0, write to LCD
			ORR r2, RS
			ORR r2, EN
			strb r2, [r0, #0x02]
			
			
			
			push {LR}
			push {SPEED}
			mov SPEED, LCD_DELAY
			BL delay
			pop	{SPEED}
			pop {LR}
			
			mov r2, #0x00
			ORR r2, RS
			strb r2, [r0, #0x02]	; EN = 0 and RS = RW = 0
			
			BX LR
			endp	
			
			end