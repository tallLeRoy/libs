; lk_math32_816.p8

; Parts of this library taken from this source
; and modified for Prog8 by tallLeRoy
; original found at atariwiki.org

;------------------------------------------------
; 6502 Standard Macro Library
;------------------------------------------------
; Copyright (C),1999 Andrew John Jacobs.
; All rights reserved.
;------------------------------------------------
;------------------------------------------------
; Revision History:
;
; 16-Aug-99 AJJ   Initial version.
;
; 14-Nov-01 AJJ Finally got around to filling in
;      some missing comments.
;
;------------------------------------------------

math32 {   
    %option ignore_unused

    const ubyte P_MEMORY = %00100000
    const ubyte P_INDEX  = %00010000
    const ubyte P_BOTH   = P_MEMORY | P_INDEX

    asmsub enter_816_native_mode() -> bool @A {
        ; returns true if in native mode, false if not
        %asm{{
            jsr cx16.cpu_is_65816
            cmp #0
            beq _return

            .cpu '65816'  ; tell the assembler the legal op codes
            clc           ; put this 65816 into NATIVE mode    
            xce          
            lda $01       ; set A to true 
        _return                        
            rts
        }}
    }

    asmsub exit_816_native_mode() {
        %asm{{
            sec
            xce              ; restore the emulator bit of the caller
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}        
    }

    asmsub clear(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; set the target ulong to zero
        %asm{{
            .as
            .xs
            lda #0
            sta (cx16.r0L)
            ldy #1
            sta (cx16.r0L),y
            iny
            sta (cx16.r0L),y
            iny
            sta (cx16.r0L),y
            rts
        }}
    }

    asmsub n_clear(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; set the target ulong to zero
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs

            lda #0
            sta (cx16.r0L)
            ldy #2
            sta (cx16.r0L),y

            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub copy(uword source @R0, uword destination @R1) clobbers(A,Y) -> uword @R0 {
        ; copy the source ulong into the destination ulong
        %asm{{
            .as
            .xs
            lda (cx16.r0L)
            sta (cx16.r1L)
            ldy #1
            lda (cx16.r0L),y
            sta (cx16.r1L),y
            iny
            lda (cx16.r0L),y
            sta (cx16.r1L),y
            iny
            lda (cx16.r0L),y
            sta (cx16.r1L),y
            rts
        }}
    }

    asmsub n_copy(uword source @R0, uword destination @R1) clobbers(A,Y) -> uword @R0 {
        ; copy the source ulong into the destination ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            lda (cx16.r0L)
            sta (cx16.r1L)
            ldy #2
            lda (cx16.r0L),y
            sta (cx16.r1L),y
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub asL(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; arithmatic shift left of the target ulong
        %asm{{
            .as
            .xs
            lda (cx16.r0L)
            asl a
            sta (cx16.r0L)
            ldy #1
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            rts
        }}
    }

    asmsub n_asL(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; arithmatic shift left of the target ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            lda (cx16.r0L)
            asl a
            sta (cx16.r0L)
            ldy #2
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub roL(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; rotate left of the target ulong
        %asm{{
            .as
            .xs
            lda (cx16.r0L)
            rol a
            sta (cx16.r0L)
            ldy #1
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            rts
        }}
    }

    asmsub n_roL(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; rotate left of the target ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            lda (cx16.r0L)
            rol a
            sta (cx16.r0L)
            ldy #2
            lda (cx16.r0L),y
            rol a
            sta (cx16.r0L),y
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub lsR(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; logical shift right of the target ulong
        %asm{{
            .as
            .xs
            ldy #3
            lda (cx16.r0L),y
            lsr a
            sta (cx16.r0L),y
            dey
            lda (cx16.r0L),y
            ror a
            sta (cx16.r0L),y
            dey
            lda (cx16.r0L),y
            ror a
            sta (cx16.r0L),y
            lda (cx16.r0L)
            ror a
            sta (cx16.r0L)
            rts
        }}
    }

    asmsub n_lsR(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; logical shift right of the target ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            ldy #2
            lda (cx16.r0L),y
            lsr a
            sta (cx16.r0L),y
            lda (cx16.r0L)
            ror a
            sta (cx16.r0L)
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub roR(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; rotate right of the target ulong
        %asm{{
            .as
            .xs
            ldy #3
            lda (cx16.r0L),y
            ror a
            sta (cx16.r0L),y
            dey
            lda (cx16.r0L),y
            ror a
            sta (cx16.r0L),y
            dey
            lda (cx16.r0L),y
            ror a
            sta (cx16.r0L),y
            lda (cx16.r0L)
            ror a
            sta (cx16.r0L)
            rts
        }}
    }

    asmsub n_roR(uword target @R0) clobbers(A,Y) -> uword @R0 {
        ; rotate right of the target ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            ldy #2
            lda (cx16.r0L),y
            ror a
            sta (cx16.r0L),y
            lda (cx16.r0L)
            ror a
            sta (cx16.r0L)
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub add(uword target @R0, uword difference @R1) clobbers(A,Y) -> uword @R0 { 
        ; add difference ulong to the target ulong
        %asm{{  ; this will take a lot of cycles to do that addressing
            .as
            .xs
            clc
            lda (cx16.r0L)
            adc (cx16.r1L)
            sta (cx16.r0L)
            ldy #1
            lda (cx16.r0L),y
            adc (cx16.r1L),y
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            adc (cx16.r1L),y
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            adc (cx16.r1L),y
            sta (cx16.r0L),y
            rts
        }}
    }

    asmsub n_add(uword target @R0, uword difference @R1) clobbers(A,Y) -> uword @R0 { 
        ; add difference ulong to the target ulong
        %asm{{  ; this will take a lot of cycles to do that addressing
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            clc
            lda (cx16.r0L)
            adc (cx16.r1L)
            sta (cx16.r0L)
            ldy #2
            lda (cx16.r0L),y
            adc (cx16.r1L),y
            sta (cx16.r0L),y
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub subtract(uword target @R0, uword ulong @R1) clobbers(A,Y) -> uword @R0 { ; parms are both pointers to four byte arrays
        %asm{{  ; this will take a lot of cycles to do that addressing
            .as
            .xs
            sec
            lda (cx16.r0L)
            sbc (cx16.r1L)
            sta (cx16.r0L)
            ldy #1
            lda (cx16.r0L),y
            sbc (cx16.r1L),y
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            sbc (cx16.r1L),y
            sta (cx16.r0L),y
            iny
            lda (cx16.r0L),y
            sbc (cx16.r1L),y
            sta (cx16.r0L),y  
            rts       
        }}
    }

    asmsub n_subtract(uword target @R0, uword ulong @R1) clobbers(A,Y) -> uword @R0 { ; parms are both pointers to four byte arrays
        %asm{{  ; this will take a lot of cycles to do that addressing
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            sec
            lda (cx16.r0L)
            sbc (cx16.r1L)
            sta (cx16.r0L)
            ldy #2
            lda (cx16.r0L),y
            sbc (cx16.r1L),y
            sta (cx16.r0L),y
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts       
        }}
    }

    asmsub multiply(uword first @R0, uword second @R1) clobbers(X) -> uword @AY {
        ; multiply first ulong by second ulong
        ; first and second ulongs are preserved
        ; returned uword is a temporary pointer to the product ulong in R4,R5
        %asm{{
            ; clear the result in R4,R5  -  not needed
;            stz cx16.r4L
;            stz cx16.r4H
;            stz cx16.r5L
;            stz cx16.r5H

            ; copy the first ulong to R6,R7
            .as
            .xs
            lda (cx16.r0)
            sta cx16.r6L
            ldy #1
            lda (cx16.r0),y
            sta cx16.r6H
            iny
            lda (cx16.r0),y
            sta cx16.r7L
            iny
            lda (cx16.r0),y
            sta cx16.r7H

            ; copy the second ulong to R8,R9
            lda (cx16.r1)
            sta cx16.r8L
            ldy #1
            lda (cx16.r1),y
            sta cx16.r8H
            iny
            lda (cx16.r1),y
            sta cx16.r9L
            iny
            lda (cx16.r1),y
            sta cx16.r9H

            ; number of bits to process
            ldx #31                         ; example macro was #32 ??? doubled the output
        -   ; shift the result within out
            asl cx16.r4L
            rol cx16.r4H
            rol cx16.r5L
            rol cx16.r5H

            ; shift first_number into work
            asl cx16.r6L
            rol cx16.r6H
            rol cx16.r7L
            rol cx16.r7H

            ; no carry, the top bit was not set
            bcc +

            ; add the second_number to the result in out
            clc
            lda cx16.r4L
            adc cx16.r8L
            sta cx16.r4L
            lda cx16.r4H
            adc cx16.r8H
            sta cx16.r4H
            lda cx16.r5L
            adc cx16.r9L
            sta cx16.r5L
            lda cx16.r5H
            adc cx16.r9H
            sta cx16.r5H

        +   ; next bit
            dex
            bpl - 

            ; return a pointer to the product in AY
            lda #cx16.r4L
            ldy #0

            rts
        }}
    }

    asmsub n_multiply(uword first @R0, uword second @R1) clobbers(X) -> uword @AY {
        ; multiply first ulong by second ulong
        ; first and second ulongs are preserved
        ; returned uword is a temporary pointer to the product ulong in R4,R5
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            ; copy the first ulong to R6,R7
            lda (cx16.r0)
            sta cx16.r6
            ldy #2
            lda (cx16.r0),y
            sta cx16.r7

            ; copy the second ulong to R8,R9
            lda (cx16.r1)
            sta cx16.r8
            lda (cx16.r1),y
            sta cx16.r9

            ; number of bits to process
            ldx #31                         ; example macro was #32 ??? doubled the output
        -   ; shift the result within out
            asl cx16.r4
            rol cx16.r5

            ; shift first_number into work
            asl cx16.r6
            rol cx16.r7

            ; no carry, the top bit was not set
            bcc +

            ; add the second_number to the result in out
            clc
            lda cx16.r4
            adc cx16.r8
            sta cx16.r4
            lda cx16.r5
            adc cx16.r9
            sta cx16.r5

        +   ; next bit
            dex
            bpl - 

            sep #p8c_P_MEMORY   ; return to 8 bit memory
            ; return a pointer to the product in AY
            lda #cx16.r4L
            ldy #0

            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub divide(uword dividend @R0, uword divisor @R1) clobbers(A) -> uword @XY, uword  @R2 {
        ; divide the dividend ulong by the divisor ulong
        ; returns ulong ptr to quotient in XY, ulong ptr to remainder in R2
        ; the storage used (R4-R7) for the quotient and remainder is not safe
        ; copy the values into your prograam after the call
        ; use R8,R9 as work location ; R10,R11 for the divisor
        %asm{{
            ; **** set up R4 - R11 for the division   # 92 cycles -- ZP address saves 60 cycles/loop 

            ; clear the quotient in R4,R5 - not needed
;            stz cx16.r4L
;            stz cx16.r4H
;            stz cx16.r5L
;            stz cx16.r5H

            ; clear the remainder ulong in R6,R7 #12
            .as
            .xs
            stz cx16.r6L        ; 3 cycles
            stz cx16.r6H
            stz cx16.r7L
            stz cx16.r7H

            ; copy the dividend ulong to R8,R9   #40
            lda (cx16.r0)     ; 5 cycles
            sta cx16.r8L        ; 3 cycles
            ldy #1              ; 2 cycles
            lda (cx16.r0),y
            sta cx16.r8H
            iny
            lda (cx16.r0),y
            sta cx16.r9L
            iny
            lda (cx16.r0),y
            sta cx16.r9H

            ; copy the divisor ulong to R10,R11  #40 
            lda (cx16.r1)
            sta cx16.r10L
            ldy #1              ; 2 cycles
            lda (cx16.r1),y
            sta cx16.r10H
            iny
            lda (cx16.r1),y
            sta cx16.r11L
            iny
            lda (cx16.r1),y
            sta cx16.r11H

            ; *** begin the actual division max cycles #146 or 106

            ldx #31                     ; example is #32 but has wrong result ??
        -   ; main loop
            ; shift the dividend left in R8,R9 #20
            asl cx16.r8L        ; 5 cycles
            rol cx16.r8H        ; 5 cycles
            rol cx16.r9L
            rol cx16.r9H

            ; rotate the remainder left in R6,R7   #20
            rol cx16.r6L
            rol cx16.r6H
            rol cx16.r7L
            rol cx16.r7H
 
            ; subtract the divisor R10,R11 from the remainder R6,R7 #38
            sec                 ; 2 cycles
            lda cx16.r6L
            sbc cx16.r10L       ; 3 cycles
            sta cx16.r6L
            lda cx16.r6H
            sbc cx16.r10H
            sta cx16.r6H
            lda cx16.r7L
            sbc cx16.r11L
            sta cx16.r7L
            lda cx16.r7H
            sbc cx16.r11H
            sta cx16.r7H

            ; test for a clean divisor subtraction 
            bcs +               ; 2 cycles

            ; add the divisor back in if the divisor was not cleanly subtracted  
            ; add divisor R10,R11 into the remainder R6,R7  #38
            clc                 ; 2 cycles
            lda cx16.r6L
            adc cx16.r10L       ; 3 cycles
            sta cx16.r6L
            lda cx16.r6H
            adc cx16.r10H
            sta cx16.r6H
            lda cx16.r7L
            adc cx16.r11L
            sta cx16.r7L
            lda cx16.r7H
            adc cx16.r11H
            sta cx16.r7H

            clc               ; added to the example macro
        +   
            ; rotate the carry flag into the quotient #20
            rol cx16.r4L
            rol cx16.r4H
            rol cx16.r5L
            rol cx16.r5H

            dex                 ; 2 cycles
            bpl -               ; 2 cycles
            ; set up the return codes
            lda #cx16.r6L
            sta cx16.r2L
            stz cx16.r2H
            ldx #cx16.r4L
            ldy #0
            rts
        }}
    }

    asmsub n_divide(uword dividend @R0, uword divisor @R1) clobbers(A) -> uword @XY, uword @R2 {
        ; divide the dividend ulong by the divisor ulong
        ; returns ulong ptr to quotient in XY, ulong ptr to remainder in R2
        ; the storage used (R4-R7) for the quotient and remainder is not safe
        ; copy the values into your prograam after the call
        ; use R8,R9 as work location ; R10,R11 for the divisor
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            ; **** set up R4 - R11 for the division   # 92 cycles -- ZP address saves 60 cycles/loop 
            ; clear the remainder ulong in R6,R7 #12
            stz cx16.r6        
            stz cx16.r7

            ; copy the dividend ulong to R8,R9   #40
            lda (cx16.r0)     
            sta cx16.r8        
            ldy #2              
            lda (cx16.r0),y
            sta cx16.r9

            ; copy the divisor ulong to R10,R11  #40 
            lda (cx16.r1)
            sta cx16.r10
            lda (cx16.r1),y
            sta cx16.r11

            ; *** begin the actual division 

            ldx #31                     ; example is #32 but has wrong result ??
        -   ; main loop
            ; shift the dividend left in R8,R9 #20
            asl cx16.r8       
            rol cx16.r9

            ; rotate the remainder left in R6,R7  
            rol cx16.r6
            rol cx16.r7
 
            ; subtract the divisor R10,R11 from the remainder R6,R7 
            sec                 
            lda cx16.r6
            sbc cx16.r10       
            sta cx16.r6
            lda cx16.r7
            sbc cx16.r11
            sta cx16.r7

            ; test for a clean divisor subtraction 
            bcs +               

            ; add the divisor back in if the divisor was not cleanly subtracted  
            ; add divisor R10,R11 into the remainder R6,R7 
            clc                 
            lda cx16.r6
            adc cx16.r10       
            sta cx16.r6
            lda cx16.r7
            adc cx16.r11
            sta cx16.r7

            clc               ; added to the example macro
        +   
            ; rotate the carry flag into the quotient
            rol cx16.r4
            rol cx16.r5

            dex                 
            bpl -         
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            ; set up the return codes
            lda #cx16.r6L
            sta cx16.r2L
            stz cx16.r2H
            ldx #cx16.r4L
            ldy #0
            rts
        }}
    }

    asmsub compare(uword target @R0, uword difference @R1) clobbers(A,Y) -> bool @Pz, bool @Pc { 
        ; compare the target ulong with the difference ulong
        ; return comparison in the flags
        %asm{{  ; this will take a lot of cycles to do that addressing; 
            ; returns flags
            ; ZF set R0 == R1
            ; C  set R0 > R1
            ; C  clear R0 < R1
            .as
            .xs
            sec
            ldy #3
            lda (cx16.r0L),y
            cmp (cx16.r1L),y
            bne +
            dey
            lda (cx16.r0L),y
            cmp (cx16.r1L),y
            bne +
            dey
            lda (cx16.r0L),y
            cmp (cx16.r1L),y
            bne +
            lda (cx16.r0L)
            cmp (cx16.r1L)
        +   rts       
        }}
    }

    asmsub n_compare(uword target @R0, uword difference @R1) clobbers(A,X,Y) -> bool @Pz, bool @Pc  { 
        ; compare the target ulong with the difference ulong
        ; return comparison in the flags
        %asm{{  ; this will take a lot of cycles to do that addressing; 
            ; returns flags
            ; ZF set R0 == R1
            ; C  set R0 > R1
            ; C  clear R0 < R1
            .cpu '65816'       ; tell the assembler the legal op codes
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs        
            ldy #2
            lda (cx16.r0),y
            cmp (cx16.r1),y
            bne +
            lda (cx16.r0)
            cmp (cx16.r1)
        +  
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    asmsub increment(uword target @R0) clobbers(A,Y) -> uword @R0 { 
        ; increment the target ulong
        %asm{{
            .as
            .xs
            lda (cx16.r0L)
            inc a
            sta (cx16.r0L)
            bne +
            ldy #1
            lda (cx16.r0L),y
            inc a
            sta (cx16.r0L),y
            bne +
            iny
            lda (cx16.r0L),y
            inc a
            sta (cx16.r0L),y
            bne +
            iny
            lda (cx16.r0L),y
            inc a
            sta (cx16.r0L),y
        +   rts    
        }}
    }

    asmsub n_increment(uword target @R0) clobbers(A,Y) -> uword @R0 { 
        ; increment the target ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            lda (cx16.r0L)
            inc a
            sta (cx16.r0L)
            bne +
            ldy #2
            lda (cx16.r0L),y
            inc a
            sta (cx16.r0L),y
        +   
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts    
        }}
    }

    asmsub decrement(uword target @R0) clobbers(A,Y) -> uword @R0 { 
        ; decrement the target ulong
        %asm{{
            .as
            .xs
            lda (cx16.r0L)      ; array[0]
            bne _one
            ldy #1
            lda (cx16.r0L),y    ; array[1]
            bne _two
            iny
            lda (cx16.r0L),y    ; array[2]
            bne _three
            iny
            lda (cx16.r0L),y    ; array[3]
            dec a
            sta (cx16.r0L),y    ; array[3]
            dey
            lda (cx16.r0L),y    ; array[2]
        _three
            dec a
            sta (cx16.r0L),y    ; array[2]
            dey
            lda (cx16.r0L),y    ; array[1]
        _two    
            dec a
            sta (cx16.r0L),y    ; array[1]
            lda (cx16.r0L)      ; array[0]
        _one            
            dec a
            sta (cx16.r0L)      ; array[0]
            rts       
        }}
    }

    asmsub n_decrement(uword target @R0) clobbers(A,Y) -> uword @R0 { 
        ; decrement the target ulong
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            .al
            .xs
            lda (cx16.r0L)    ; array[0-1]
            bne +
            ldy #2
            lda (cx16.r0L),y    ; array[2-3]
            dec a
            sta (cx16.r0L),y    ; array[2-3]
            lda (cx16.r0L)      ; array[0-1]      
        +
            dec a
            sta (cx16.r0L)
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts       
        }}
    }



    ubyte[11] str_out

    asmsub string(uword target @R0) clobbers(X,Y) -> uword @R1 {
        ; convert the target ulong into a decimal string in math32.str_out
        ; adapted for Prog8 by tallLeRoy
        ; from posting Grahm at codebase64.org
        ; titled 32 bit hexadecimal to decimal conversion 

        ; uses R8,R9 is used for work, to preseve the incoming value
        %asm{{
            .as
            .xs
            ; copy the target ulong into R8,R9
            lda (cx16.r0)
            sta cx16.r8L
            ldy #1
            lda (cx16.r0),y
            sta cx16.r8H
            iny
            lda (cx16.r0),y
            sta cx16.r9L
            iny
            lda (cx16.r0),y
            sta cx16.r9H

            ldx #9
        _loop
            ldy #32
            lda #0
            clc
        _1            
            rol a
            cmp #10
            bcc _2
            sbc #10
        _2
            rol cx16.r8L
            rol cx16.r8H
            rol cx16.r9L
            rol cx16.r9H
            dey
            bpl _1
            
            ora #$30
            sta p8b_math32.p8v_str_out,x
            
            dex
            bpl _loop

            ; kill leading zeros
            ldy #0
        _test  
            lda p8b_math32.p8v_str_out,y 
            cmp #$30
            bne _zerocheck
            iny
            bra _test

        _zerocheck
            cmp #0
            bne _return
            dey    

        _return
            ; point R1 to our str_out without leading zeros
            tya
            clc
            adc #<p8b_math32.p8v_str_out
            sta cx16.r1L
            lda #>p8b_math32.p8v_str_out
            adc #0
            sta cx16.r1H
            rts
        }}
    }

    asmsub n_string(uword target @R0) clobbers(X,Y) -> uword @R1 {
        ; convert the target ulong into a decimal string in math32.str_out
        ; adapted for Prog8 by tallLeRoy
        ; from posting Grahm at codebase64.org
        ; titled 32 bit hexadecimal to decimal conversion 

        ; uses R8,R9 is used for work, to preseve the incoming value
        %asm{{
            .cpu '65816'       ; tell the assembler the legal op codes
            .autsiz
            rep #p8c_P_MEMORY  ; 16 bit accumulator, memory load and store
            ; copy the target ulong into R8,R9
            lda (cx16.r0)
            sta cx16.r8
            ldy #2
            lda (cx16.r0),y
            sta cx16.r9
            sep #p8c_P_MEMORY    ; drop back to 8 bit

            ldx #9
        _loop
            ldy #32
            lda #0
            clc
        _1            
            rol a
            cmp #10
            bcc _2
            sbc #10
        _2
            rep #p8c_P_MEMORY       ; use a 16 bit ROL
            rol cx16.r8
            rol cx16.r9
            sep #p8c_P_MEMORY       ; drop back to 8 bit
            dey
            bpl _1
            
            ora #$30
            sta p8b_math32.p8v_str_out,x
            
            dex
            bpl _loop

            ; kill leading zeros
            ldy #0
        _test  
            lda p8b_math32.p8v_str_out,y 
            cmp #$30
            bne _zerocheck
            iny
            bra _test

        _zerocheck
            cmp #0
            bne _return
            dey    

        _return
            ; point R1 to our str_out without leading zeros
            tya
            clc
            adc #<p8b_math32.p8v_str_out
            sta cx16.r1L
            lda #>p8b_math32.p8v_str_out
            adc #0
            sta cx16.r1H
            sep #p8c_P_MEMORY
            .cpu 'w65c02'
            .as
            .xs
            rts
        }}
    }

    sub print_comma(uword target) {
        ; print the target ulong, with commas 
        cx16.r3 = string(target)

        when string.length(cx16.r3) {
            10 -> {
                comma(0,1)
                comma(1,3)
                comma(4,3)
                txt.print(cx16.r3+7)
            }
            9 -> {
                comma(0,3)
                comma(3,3)
                txt.print(cx16.r3+6)
            }
            8 -> {
                comma(0,2)
                comma(2,3)
                txt.print(cx16.r3+5)
            }
            7 -> {
                comma(0,1)
                comma(1,3)
                txt.print(cx16.r3+4)
            }
            6 -> {
                comma(0,3)
                txt.print(cx16.r3+3)
            }
            5 -> {
                comma(0,2)
                txt.print(cx16.r3+2)
            }
            4 -> {
                comma(0,1)
                txt.print(cx16.r3+1)
            }
            else -> txt.print(cx16.r3)
        }
    }

    sub n_print_comma(uword target) {
        ; print the target ulong, with commas 
        cx16.r3 = n_string(target)

        when string.length(cx16.r3) {
            10 -> {
                comma(0,1)
                comma(1,3)
                comma(4,3)
                txt.print(cx16.r3+7)
            }
            9 -> {
                comma(0,3)
                comma(3,3)
                txt.print(cx16.r3+6)
            }
            8 -> {
                comma(0,2)
                comma(2,3)
                txt.print(cx16.r3+5)
            }
            7 -> {
                comma(0,1)
                comma(1,3)
                txt.print(cx16.r3+4)
            }
            6 -> {
                comma(0,3)
                txt.print(cx16.r3+3)
            }
            5 -> {
                comma(0,2)
                txt.print(cx16.r3+2)
            }
            4 -> {
                comma(0,1)
                txt.print(cx16.r3+1)
            }
            else -> txt.print(cx16.r3)
        }
    }

    sub print_dollars_cents(uword target) {
        ; print the target ulong and dollars with commas and cents
        cx16.r3 = string(target)

        txt.chrout('$')
        when string.length(cx16.r3) {
            10 -> {
                comma(0,2)
                comma(2,3)
                cents(5,3)
            }
            9 -> {
                comma(0,1)
                comma(1,3)
                cents(4,3)
            }
            8 -> {
                comma(0,3)
                cents(3,3)
            }
            7 -> {
                comma(0,2)
                cents(2,3)
            }
            6 -> {
                comma(0,1)
                cents(1,3)
            }
            5 -> {
                cents(0,3)
            }
            4 -> {
                cents(0,2)
            }
            3 -> {
                cents(0,1)
            }
            2 -> {
                txt.print("0.")
                txt.print(cx16.r3)
            }
            1 -> {
                txt.print("0.0")
                txt.print(cx16.r3)
            }
        }
    }

    sub n_print_dollars_cents(uword target) {
        ; print the target ulong and dollars with commas and cents
        cx16.r3 = n_string(target)

        txt.chrout('$')
        when string.length(cx16.r3) {
            10 -> {
                comma(0,2)
                comma(2,3)
                cents(5,3)
            }
            9 -> {
                comma(0,1)
                comma(1,3)
                cents(4,3)
            }
            8 -> {
                comma(0,3)
                cents(3,3)
            }
            7 -> {
                comma(0,2)
                cents(2,3)
            }
            6 -> {
                comma(0,1)
                cents(1,3)
            }
            5 -> {
                cents(0,3)
            }
            4 -> {
                cents(0,2)
            }
            3 -> {
                cents(0,1)
            }
            2 -> {
                txt.print("0.")
                txt.print(cx16.r3)
            }
            1 -> {
                txt.print("0.0")
                txt.print(cx16.r3)
            }
        }
    }

    sub comma(ubyte start, ubyte run) {
        ; put comma in the printed output
        repeat run {
            txt.chrout(cx16.r3[start])
            start += 1
        }
        txt.chrout(',')
    } 

    sub cents(ubyte start, ubyte run) {
        ; put a comma in the printed output
        repeat run {
            txt.chrout(cx16.r3[start])
            start += 1
        }
        txt.chrout('.')
        txt.print(cx16.r3+start)
    }   

    asmsub jiffs(uword target @R0) -> uword @R0 {
        ; fill the target ulong with the current Jiffy count
        %asm {{
            .as
            .xs
            jsr cbm.RDTIM
            phy                 ; save y for later store
            ldy #0
            sta (cx16.r0),y     ; low jiffies +0
            iny
            txa
            sta (cx16.r0),y     ; mid jiffies +1
            iny
            pla                 ; retrieve y now
            sta (cx16.r0),y     ; high jiffies +2
            iny
            lda #0
            sta (cx16.r0),y     ; always 0 +3
            rts
        }}
    }
}